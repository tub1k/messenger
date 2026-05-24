import 'package:equatable/equatable.dart';

enum MessageType { text, image, system, unknown }

class MessageModel extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final MessageType type;
  final bool? isPending;

  const MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.type,
    this.isPending,
  });

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String? documentId, {
    bool? isPending,
  }) {
    String stringType = map['type'].toString();
    MessageType returnType;
    switch (stringType) {
      case ('system'):
        returnType = MessageType.system;
      case ('image'):
        returnType = MessageType.image;
      case ('text'):
        returnType = MessageType.text;
      default:
        returnType = MessageType.unknown;
    }
    return MessageModel(
      id: documentId ?? '',
      text: map['text'] ?? 'failed to load messages',
      senderId: map['senderId'] ?? '',
      timestamp: map['createdAt']?.toDate() ?? DateTime.now(),
      type: returnType,
      isPending: isPending ?? false,
    );
  }

  @override
  List<Object?> get props => [id, text, type, senderId, timestamp];
}

class ChatModel extends Equatable {
  final String chatName;
  final String chatId;
  final MessageModel lastMessage;
  final List<MessageModel> loadedMessages;
  final String photoUrl;

  const ChatModel({
    required this.chatName,
    required this.chatId,
    required this.lastMessage,
    required this.loadedMessages,
    required this.photoUrl,
  });

  factory ChatModel.fromFirebase({
    required Map<String, dynamic> data,
    required String docId,
    required String myId,
  }) {
    final lastMessageMap = data['lastMessage'] as Map<String, dynamic>?;

    String? chatName = 'Групповой чат';
    String? photoUrl = '';
    final participantsList = List<String>.from(data['participants'] ?? []);

    String otherId = '';
    if (participantsList.length == 2) {
      otherId = (participantsList[0] == myId) ? participantsList[1] : participantsList[0];
    }

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
      chatId: docId,
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

  @override
  List<Object?> get props => [chatName, chatId, lastMessage, loadedMessages];
}
