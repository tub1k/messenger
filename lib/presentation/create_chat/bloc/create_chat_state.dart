  part of 'create_chat_bloc.dart';

  abstract class CreateChatState {
    final String? errorText;
    CreateChatState({this.errorText});
  }

  class CreateChatInitial extends CreateChatState {
    final List<BaseUserModel> addedUsers;
    

    CreateChatInitial({super.errorText, required this.addedUsers});
  }

  class CreateChatSecond extends CreateChatState {
    final List<BaseUserModel> addedUsers;

    CreateChatSecond({super.errorText, required this.addedUsers});
  }

  class CreateChatMoveToChat extends CreateChatState {
    final ChatModel chat;

    CreateChatMoveToChat({super.errorText, required this.chat});
  }

  class CreateChatLoading extends CreateChatState {}