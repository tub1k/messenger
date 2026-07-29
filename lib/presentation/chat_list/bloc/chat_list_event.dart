part of 'chat_list_bloc.dart';

class ChatListEvent {}

class LoadChatList extends ChatListEvent {}

class InitChatList extends ChatListEvent {}

/// since this only realistically can be used with local user 
/// it doesnt ask for a UID
class ChatListUpdateReadTime extends ChatListEvent {
  final String chatId;

  ChatListUpdateReadTime({required this.chatId});
}
