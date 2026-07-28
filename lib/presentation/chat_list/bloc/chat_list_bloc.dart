import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    List<ChatModel> lastChats = [];

    on<InitChatList>((event, emit) async {
      emit(ChatListLoading());
      final cachedChats = await _repository.getCachedChats(myId);
      final sortedChats = _sortChats(cachedChats);
      lastChats = sortedChats;
      emit(ChatListLoaded(chatList: sortedChats, localSave: true));
      Stream<List<ChatModel>> chatListStream = _repository.getChats(myId);
      await emit.forEach<List<ChatModel>>(
        chatListStream,
        onData: (data) {
          final sortedChats = _sortChats(data);
          lastChats = sortedChats;
          return ChatListLoaded(
            chatList: sortedChats,
            localSave: false,
            key: 'serverData',
          );
        },
        onError: (error, stackTrace) {
          log(error.toString());
          return ChatListFailed(
            error,
            chatList: lastChats,
            errorText: error.toString(),
          );
        },
      );
    }, transformer: restartable());
  }
}

List<ChatModel> _sortChats(List<ChatModel> chats) {
  return chats.sorted(
    (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
  );
}
