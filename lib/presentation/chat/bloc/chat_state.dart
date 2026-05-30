part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {}

class ChatInitial extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String? errorText;
  final List<Uint8List> images;

  ChatLoaded({required this.messages, this.errorText, required this.images});
  
  @override
  List<Object?> get props => [messages, errorText, images.length, images.hashCode];
}