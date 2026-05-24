import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<ChatModel?> getChatObject(String chatId, String myId) async {
    final snapshot = await _firestore.collection('chats').doc(chatId).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    return data != null ? ChatModel.fromFirebase(data: data, docId: chatId, myId: myId) : null;
  }

  @override
  Stream<List<ChatModel>> getChats(String myId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatModel.fromFirebase(
              data: data,
              docId: doc.id,
              myId: myId,
            );
          }).toList();
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
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
  }) async {
    final msg = {
      'text': text,
      'senderId': senderId,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
    _firestore.collection('chats').doc(chatId).collection('messages').add(msg);
    _firestore.collection('chats').doc(chatId).update({'lastMessage': msg});
  }

  @override
  Future<String> createChat({
    String? chatName,
    required List<String> userUids,
  }) async {
    final Map<String, String> memberNames = {};
    final Map<String, String> memberPhotos = {};

    final futures = userUids.map(
      (uid) => _firestore.collection('users').doc(uid).get(),
    );
    final snapshots = await Future.wait(futures);

    for (var i in snapshots) {
      final uid = i.id;
      final userMap = i.data();
      memberNames[uid] = userMap?['displayName'] as String? ?? 'unknown_user';
      memberPhotos[uid] = userMap?['photoUrl'] as String? ?? '';
    }

    final chatToAddMap = {
      'participants': userUids,
      'memberNames': memberNames,
      'memberPhotos': memberPhotos,
    };
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
      final chatSnapshot = results.firstOrNull;
      final doc = chatSnapshot?.docs.first;
      if (doc != null) {
        final data = doc.data(); // getting data of that one chat. assuming only one DM chat can exist between users
        return ChatModel.fromFirebase(data: data, docId: doc.id, myId: myId);
      }
      else {return null;}
    } catch (e) {
      throw 'failed to check if DMs exist: $e';
    }
  }
}
