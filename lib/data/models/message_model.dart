import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:messenger/data/models/user_model.dart';

enum MessageType { text, image, system, unknown }

class MessageModel extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final MessageType type;
  final bool? isPending;
  final int? imageAmount;
  final List<Uint8List>? optimisticImages;
  final BaseUserModel sender;

  const MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.type,
    this.isPending,
    this.imageAmount,
    this.optimisticImages,
    required this.sender,
  });

  MessageModel.empty()
    : id = '',
      text = 'Нет сообщений',
      senderId = '',
      timestamp = DateTime(1970),
      type = MessageType.system,
      isPending = false,
      imageAmount = 0,
      optimisticImages = null,
      sender = BaseUserModel.empty();

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String? documentId, {
    bool? isPending,
    required BaseUserModel sender,
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
      imageAmount: map['imageAmount'],
      sender: sender
    );
  }
  @override
  List<Object?> get props => [id, text, type, senderId, timestamp];
}
