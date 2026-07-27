import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final IChatRepository _repository;
  final String myId;

  ChatListBloc(this._repository, {required this.myId})
    : super(ChatListInitial()) {
    on<InitChatList>((event, emit) async {
      emit(ChatListLoading());
      final cachedChats = await _repository.getCachedChats(myId);
      final sortedChats = cachedChats.sorted((a, b) {
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
      emit(ChatListLoaded(chatList: sortedChats, localSave: true));
      Stream<List<ChatModel>> chatListStream = _repository.getChats(myId);
      await emit.forEach<List<ChatModel>>(
        chatListStream,
        onData: (data) {
          final sortedChats = data.sorted((a, b) {
            return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
          });
          return ChatListLoaded(
            chatList: sortedChats,
            localSave: false,
            key: 'serverData',
          );
        },
        onError: (error, stackTrace) {
          return ChatListFailed(
            error,
            chatList: [],
            errorText: error.toString(),
          );
        },
      );
    });
  }
}
