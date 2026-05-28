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

  MessageModel.empty()
    : id = '',
      text = 'Нет сообщений',
      senderId = '',
      timestamp = DateTime(1970),
      type = MessageType.system,
      isPending = false;

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
