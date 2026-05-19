part of 'create_chat_bloc.dart';

class CreateChatEvent {}

class AddToCreateChatList extends CreateChatEvent {
  final String username;

  AddToCreateChatList({required this.username});
}