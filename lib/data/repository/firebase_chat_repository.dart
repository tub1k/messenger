import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, BaseUserModel> _memoryUserCache = {};
  final IStorageRepository _storageRepository;

  FirebaseChatRepository({required IStorageRepository storageRepository}) : _storageRepository = storageRepository;

  @override
  Future<ChatModel?> getChatObject(String chatId, String myId) async {
    final snapshot = await _firestore.collection('chats').doc(chatId).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data != null) {
      final participants = List<String>.from(data['participants'] ?? []);
      final userModels = await getBaseUsersFromListOfUIDs(participants);
      data['photoUrl'] = await _storageRepository.getGroupPhotoUrl(chatId);
      return ChatModel.fromFirebase(
        data: data,
        docId: chatId,
        myId: myId,
        userModels: userModels,
      );
    } else {
      return null;
    }
  }

  @override
  Stream<List<ChatModel>> getChats(String myId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
          final chatFutures = snapshot.docs.map((DocumentSnapshot doc) async {
            final data = doc.data() as Map<String, dynamic>;

            final participants = List<String>.from(data['participants'] ?? []);
            final List<BaseUserModel> userModels;
            try {
                 userModels = await getBaseUsersFromListOfUIDs(participants);
              } on Exception catch (_) {
                return ChatModel.empty();
              }

            data['photoUrl'] = await _storageRepository.getGroupPhotoUrl(doc.id);

            return ChatModel.fromFirebase(
              data: data,
              docId: doc.id,
              myId: myId,
              userModels: userModels,
            );
          }).toList();

          return await Future.wait(chatFutures);
        });
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isPending = doc.metadata.hasPendingWrites;
            return MessageModel.fromMap(data, doc.id, isPending: isPending);
          }).toList();
        });
  }

  @override
  Future<List<ChatModel>> getSavedChats() {
    // TODO: implement getSavedChats
    throw UnimplementedError();
  }

  @override
  Future<List<MessageModel>> loadOlderMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    required int limit,
  }) async {
    final firebaseTimestamp = Timestamp.fromDate(beforeTimestamp);

    final query = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('createdAt', isLessThan: firebaseTimestamp)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<String> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
    int? imageAmount,
  }) async {
    final msg = {
      'text': text,
      'senderId': senderId,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (imageAmount != null) {
      msg['imageAmount'] = imageAmount;
    }

    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    final chatRef = _firestore.collection('chats').doc(chatId);

    batch.set(messageRef, msg);
    batch.update(chatRef, {'lastMessage': msg});

    await batch.commit();
    return messageRef.id;
  }

  @override
  Future<String> createChat({
    String? chatName,
    required List<String> userUids,
  }) async {
    Map<String, dynamic> chatToAddMap = {'participants': userUids};
    if (chatName != null) {
      chatToAddMap['chatName'] = chatName;
    }

    final docRef = await _firestore.collection('chats').add(chatToAddMap);
    return docRef.id;
  }

  @override
  Future<BaseUserModel> getBaseUserByUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      final data = snapshot.docs.firstOrNull?.data();

      if (data == null) {
        throw 'failed to get user, make sure this username exists.';
      }

      return BaseUserModel.fromFirebase(data: data);
    } catch (e) {
      throw 'failed to get user: $e';
    }
  }

  // TODO: debug and fix this
  @override
  Future<ChatModel?> getDms(String uid1, String uid2, String myId) async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('chats')
            .where('participants', isEqualTo: [uid1, uid2])
            .get(),
        _firestore
            .collection('chats')
            .where('participants', isEqualTo: [uid2, uid1])
            .get(),
      ]);

      final allDocs = results[0].docs + results[1].docs;

      final doc = allDocs.firstOrNull;
      if (doc != null) {
        final participants = List<String>.from(doc['participants'] ?? []);
        final userModels = await getBaseUsersFromListOfUIDs(participants);
        var data = doc.data();
        data['photoUrl'] = await _storageRepository.getGroupPhotoUrl(doc.id);
        return ChatModel.fromFirebase(
          data: data,
          docId: doc.id,
          myId: myId,
          userModels: userModels,
        );
      } else {
        return null;
      }
    } catch (e) {
      throw 'failed to check if DMs exist: $e';
    }
  }

  @override
  Future<BaseUserModel> getBaseUserByUID(String uid) async {
    if (_memoryUserCache.containsKey(uid)) {
      return _memoryUserCache[uid]!;
    }

    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final data = snapshot.data();

      if (data == null) {
        throw 'failed to get user, make sure this UID exists. ($uid)';
      }
      final user = BaseUserModel.fromFirebase(data: data);
      _memoryUserCache[uid] = user;

      return user;
    } catch (e) {
      throw 'failed to get user: $e';
    }
  }

  @override
  Future<List<BaseUserModel>> getBaseUsersFromListOfUIDs(
    List<String> uidList,
  ) async {
    return Future.wait(
      uidList.map((uid) {
        return getBaseUserByUID(uid);
      }).toList(),
    );
  }
}
