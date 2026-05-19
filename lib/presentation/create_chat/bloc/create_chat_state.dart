part of 'create_chat_bloc.dart';

class CreateChatState {}

class CreateChatInitial extends CreateChatState {
  final List<BaseUserModel> addedUsers;
  final String? errorText;

  CreateChatInitial({required this.addedUsers, this.errorText});
}