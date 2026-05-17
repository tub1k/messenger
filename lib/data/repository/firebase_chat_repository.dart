import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<ChatModel> getChatObject(String chatId) {
    // TODO: implement getChatObject
    throw UnimplementedError();
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
            final lastMessageMap = data['lastMessage'] as Map<String, dynamic>?;

            String? chatName = 'Групповой чат';
            String? photoUrl = '';
            final participantsList = (data['participants'] as List<dynamic>);
            final otherId = (participantsList.length == 2) ? participantsList.firstWhere((id) => id != myId, orElse: () => myId) : '';

            if (data['chatName'] != null) {
              chatName = data['chatName'];
            } else if (participantsList.length == 2) {
              chatName = data['memberNames']?[otherId];
            }

            if (data['photoUrl'] != null) {
              photoUrl = data['photoUrl'];
            } else if (participantsList.length == 2) {
              photoUrl = data['memberPhotos']?[otherId];
            }

            return ChatModel(
              photoUrl: photoUrl ?? '',
              chatId: doc.id,
              chatName: chatName ?? 'Групповой чат',
              loadedMessages: const [],
              lastMessage: lastMessageMap != null
                  ? MessageModel.fromMap(lastMessageMap, '')
                  : MessageModel(
                      id: '',
                      text: 'Нет сообщений',
                      senderId: '',
                      timestamp: DateTime.now(),
                      type: MessageType.system,
                    ),
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
  Future<void> createChat({
    String? chatName,
    required List<String> userUids,
  }) async {
    final Map<String, String> memberNames = {};
    final Map<String, String> memberPhotos = {};

    final futures = userUids.map((uid) => _firestore.collection('users').doc(uid).get());
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

    await _firestore.collection('chats').add(chatToAddMap);
    return Future.value();
  }
}