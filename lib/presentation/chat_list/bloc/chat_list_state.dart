part of 'chat_list_bloc.dart';

abstract class ChatListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatModel> chatList;
  final bool localSave;
  final String? errorText; 
  final String? key;

  ChatListLoaded({required this.chatList, required this.localSave, this.errorText, this.key});

  @override
  List<Object?> get props => [chatList, localSave, errorText];

}

class ChatListFailed extends ChatListState {
  
  final List<ChatModel> chatList;
  final Object? exception;
  final String? errorText;

  ChatListFailed(this.exception, {required this.chatList, this.errorText});
}

