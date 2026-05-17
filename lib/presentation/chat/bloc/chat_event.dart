part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  final String chatId;
  const ChatStarted(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatMessageSent extends ChatEvent {
  final String text;
  final MessageType messageType;

  const ChatMessageSent(this.text, {required this.messageType});

  @override
  List<Object?> get props => [text];
}