part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {}

class ChatInitial extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String? errorText;

  ChatLoaded({required this.messages, this.errorText});
  
  @override
  List<Object?> get props => [messages, errorText];
}