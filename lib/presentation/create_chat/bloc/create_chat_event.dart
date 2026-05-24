part of 'create_chat_bloc.dart';

class CreateChatEvent {}

class AddToCreateChatList extends CreateChatEvent {
  final String username;

  AddToCreateChatList({required this.username});
}

class RemoveFromCreateChatList extends CreateChatEvent {
  final String username;

  RemoveFromCreateChatList({required this.username});
}

class GoToSecondPage extends CreateChatEvent {
  final List<BaseUserModel> addedUsers;

  GoToSecondPage({required this.addedUsers});
}

class CreateChat extends CreateChatEvent {
  final List<BaseUserModel> addedUsers;
  final String? chatName;
  final Uint8List? photo;

  CreateChat({required this.addedUsers, this.chatName, this.photo});
}