import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, BaseUserModel> _memoryUserCache = {};
  final IStorageRepository _storageRepository;

  FirebaseChatRepository({required IStorageRepository storageRepository})
    : _storageRepository = storageRepository;

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
        lastMessageSender: (data['lastMessage']?['senderId'] != null)
            ? await getBaseUserByUID(data['lastMessage']['senderId'])
            : null,
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

            return await _getChatModelFromData(data, doc.id, myId);
          }).toList();

          return await Future.wait(chatFutures);
        });
  }

  Future<ChatModel> _getChatModelFromData(
    Map<String, dynamic> data,
    String docId,
    String myId,
  ) async {
    final participants = List<String>.from(data['participants'] ?? []);
    final List<BaseUserModel> userModels;
    try {
      userModels = await getBaseUsersFromListOfUIDs(participants);
    } on Exception catch (_) {
      return ChatModel.empty();
    }

    data['photoUrl'] = await _storageRepository.getGroupPhotoUrl(docId);

    final lastMessageSender = (data['lastMessage']?['senderId'] != null)
        ? await getBaseUserByUID(data['lastMessage']['senderId'])
        : null;

    return ChatModel.fromFirebase(
      data: data,
      docId: docId,
      myId: myId,
      userModels: userModels,
      lastMessageSender: lastMessageSender,
    );
  }

  @override
  Future<List<ChatModel>> getCachedChats(String myId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: myId)
          .get(const GetOptions(source: Source.cache));

      if (snapshot.docs.isEmpty) return [];

      final chatFutures = snapshot.docs.map((DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);

        final List<BaseUserModel> userModels;
        try {
          userModels = await getBaseUsersFromListOfUIDs(
            participants,
            getFromCache: true,
          );
        } catch (_) {
          return ChatModel.empty();
        }

        try {
          data['photoUrl'] = await _storageRepository.getGroupPhotoUrl(doc.id);
        } catch (_) {
          data['photoUrl'] = null;
        }

        final lastMessageSender = (data['lastMessage']?['senderId'] != null)
            ? await getBaseUserByUID(
                data['lastMessage']['senderId'],
                getFromCache: true,
              )
            : null;

        return ChatModel.fromFirebase(
          data: data,
          docId: doc.id,
          myId: myId,
          userModels: userModels,
          lastMessageSender: lastMessageSender,
        );
      }).toList();

      final results = await Future.wait(chatFutures);
      return results;
    } catch (e) {
      log('retrieving cached chats error');
      return [];
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
          final messageFutures = snapshot.docs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            final isPending = doc.metadata.hasPendingWrites;

            final sender = await getBaseUserByUID(data['senderId']);
            return MessageModel.fromMap(
              data,
              doc.id,
              isPending: isPending,
              sender: sender,
            );
          });

          return Future.wait(messageFutures);
        });
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

    final messageFutures = query.docs.map((doc) async {
      final data = doc.data();
      final senderId = data['senderId'] ?? '';

      final sender = await getBaseUserByUID(senderId);

      return MessageModel.fromMap(data, doc.id, sender: sender);
    }).toList();

    final List<MessageModel> messages = await Future.wait(messageFutures);

    return messages;
  }

  @override
  Future<String> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
    required ChatModel chat,
    required String messageId,
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
        .doc(messageId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    batch.set(messageRef, msg);
    batch.update(chatRef, {'lastMessage': msg});

    await batch.commit();
    await Future.wait(
      chat.userModels.map((model) {
        if (model.uid != senderId && chat.isMuted?[model.uid] != true) {
          return sendSafePush(
            targetFcmToken: model.fcmToken,
            title: chat.chatName,
            body: (type == MessageType.text)
                ? text
                : 'Attachment, click to view.',
            type: 'chat',
            id: chatId,
          );
        }
        return Future.value(); // just so linter accepts our "nulls"
      }).toList(),
    );
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
          lastMessageSender: (data['lastMessage']?['senderId'] != null)
              ? await getBaseUserByUID(data['lastMessage']['senderId'])
              : null,
        );
      } else {
        return null;
      }
    } catch (e) {
      throw 'failed to check if DMs exist: $e';
    }
  }

  @override
  Future<BaseUserModel> getBaseUserByUID(
    String uid, {
    bool? getFromCache,
  }) async {
    if (_memoryUserCache.containsKey(uid)) {
      final cachedUser = _memoryUserCache[uid]!;
      if (cachedUser.uid.isNotEmpty && cachedUser.username.isNotEmpty) {
        return cachedUser;
      }
    }

    final source = (getFromCache ?? false)
        ? Source.cache
        : Source.serverAndCache;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get(GetOptions(source: source));
      final data = snapshot.data();

      if (data == null) {
        throw 'failed to get user, make sure this UID exists. ($uid)';
      }
      try {
          data['photoUrl'] = await _storageRepository.getProfilePhotoUrl(uid);
        } catch (_) {
          data['photoUrl'] = null;
        }
      final user = BaseUserModel.fromFirebase(data: data);
      if (user.uid.length > 7) {
        _memoryUserCache[uid] = user;
      }

      return user;
    } catch (e) {
      log(e.toString());
      return BaseUserModel.empty();
    }
  }

  @override
  Future<List<BaseUserModel>> getBaseUsersFromListOfUIDs(
    List<String> uidList, {
    bool? getFromCache,
  }) async {
    return Future.wait(
      uidList.map((uid) {
        return getBaseUserByUID(uid, getFromCache: getFromCache);
      }).toList(),
    );
  }

  static const _serverUrl =
      'https://messenger-microserver.onrender.com/send-push';

  @override
  Future<void> sendSafePush({
    required String? targetFcmToken,
    required String title,
    required String body,
    required String type, // type of the action we do on click
    required String id, // id of the chat or any other additional info
  }) async {
    if (targetFcmToken == null) {
      log("push not sent, fcm token is null!");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': targetFcmToken,
          'title': title,
          'body': body,
          'data': {
            'type': type,
            'id': id,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        }),
      );

      if (response.statusCode == 200) {
        log('push sent successfully');
      } else {
        log('push sending error: ${response.body}');
      }
    } catch (e) {
      log('network error: $e');
    }
  }

  @override
  Stream<BaseUserModel> streamUserPresence(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data != null) {
        final user = BaseUserModel.fromFirebase(data: data);
        _memoryUserCache[uid] = user;
        return user;
      }
      return BaseUserModel.empty();
    });
  }

  @override
  Future<void> updateMyReadTime(String chatId, String myId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'lastReads.$myId': Timestamp.now(),
    });
  }

  @override
  Future<void> muteChat(String chatId, String myId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isMuted.$myId': true,
    });
  }

  @override
  Future<void> unmuteChat(String chatId, String myId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isMuted.$myId': false,
    });
  }

  @override
  Stream<ChatModel> streamChatData(String chatId, String myId) {
    return _firestore.collection('chats').doc(chatId).snapshots().asyncMap((
      DocumentSnapshot snapshot,
    ) async {
      final data = snapshot.data() as Map<String, dynamic>;
      return await _getChatModelFromData(data, chatId, myId);
    });
  }

  @override
  Future<void> changeBio(String newBio, String myId) async {
    await _firestore.collection('users').doc(myId).update({"aboutMe": newBio});
  }
}
