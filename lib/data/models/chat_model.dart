import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';

class ChatModel extends Equatable {
  final String chatName;
  final String chatId;
  final MessageModel lastMessage;
  final List<MessageModel> loadedMessages;
  final String photoUrl;
  final List<String> participants;
  final List<BaseUserModel> userModels;
  final Map<String, DateTime> lastReads;

  const ChatModel({
    required this.chatName,
    required this.chatId,
    required this.lastMessage,
    required this.loadedMessages,
    required this.photoUrl,
    required this.participants,
    required this.userModels,
    required this.lastReads,
  });

  ChatModel.empty()
    : chatName = '',
      photoUrl = '',
      chatId = '',
      participants = [''],
      lastMessage = MessageModel.empty(),
      loadedMessages = [],
      userModels = [],
      lastReads = {};
  
  factory ChatModel.fromFirebase({
    required Map<String, dynamic> data,
    required String docId,
    required String myId,
    required List<BaseUserModel> userModels,
    required BaseUserModel? lastMessageSender
  }) {
    final lastMessageMap = data['lastMessage'] as Map<String, dynamic>?;

    String? chatName = 'Групповой чат';
    String? photoUrl = '';

    final participantsList = List<String>.from(data['participants'] ?? []);

    BaseUserModel? otherUser = BaseUserModel.empty();
    if (userModels.length == 2) {
      otherUser = (userModels[0].uid == myId) ? userModels[1] : userModels[0];
    }

    if (data['chatName'] != null) {
      chatName = data['chatName'];
    } else if (userModels.length == 2) {
      chatName = otherUser.displayName;
    }

    if (data['photoUrl'] != null) {
      photoUrl = data['photoUrl'];
    } else if (userModels.length == 2) {
      photoUrl = otherUser.photoUrl;
    }

    final rawLastReads = data['lastReads'] as Map<String, dynamic>?;

    final Map<String, DateTime> lastReads = {
      for (final id in participantsList)
        id: (rawLastReads?[id] as Timestamp?)?.toDate() ?? DateTime(1970),
    };


    return ChatModel(
      photoUrl: photoUrl ?? '',
      chatId: docId,
      chatName: chatName ?? 'Групповой чат',
      loadedMessages: const [],
      lastMessage: (lastMessageMap != null && lastMessageSender != null)
          ? MessageModel.fromMap(lastMessageMap, '', sender: lastMessageSender)
          : MessageModel.empty(),
      participants: participantsList,
      userModels: userModels,
      lastReads: lastReads,
    );
  }

  String get lastMessagePreview {
    if (lastMessage.type == MessageType.text) {
      return lastMessage.text;
    } else if (lastMessage.type == MessageType.image) {
      return 'Image';
    } else {
      return '???';
    }
  }

  BaseUserModel? getFirstUserThatIsntUID(String uid) {
    if (userModels.length >= 2) {
      return userModels.firstWhereOrNull((userModel) {
        return userModel.uid != uid;
      });
    }
    return null;
  }

  @override
  List<Object?> get props => [chatName, chatId, lastMessage, loadedMessages, lastReads, userModels, photoUrl, participants, lastReads.entries.firstOrNull?.value];
}
