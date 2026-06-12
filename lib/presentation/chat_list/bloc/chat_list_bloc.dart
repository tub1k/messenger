import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final IChatRepository _repository;
  final String myId;

  ChatListBloc(this._repository, {required this.myId}) : super(ChatListInitial()) {
    on<InitChatList>((event, emit) async {
      emit(ChatListLoading());
      final cachedChats = await _repository.getCachedChats(myId);
      emit(ChatListLoaded(chatList: cachedChats, localSave: true));
      Stream<List<ChatModel>> chatListStream = _repository.getChats(myId);
      await emit.forEach<List<ChatModel>>(
        chatListStream,
        onData: (data) {
          return ChatListLoaded(chatList: data, localSave: false);
        },
        onError: (error, stackTrace) {
          return ChatListFailed(error, chatList: [], errorText: error.toString());
        },
      );
    });
  }
}
