import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final IChatRepository _repository;

  ChatListBloc(this._repository) : super(ChatListInitial()) {
    on<InitChatList>((event, emit) async {
      emit(ChatListLoading());
      List<ChatModel> savedChats = await _repository.getSavedChats();
      bool savedChatsLocal = true;
      // emit(ChatListLoaded(chatList: savedChats, localSave: true));
      Stream<List<ChatModel>> chatListStream = _repository.getChats();
      await emit.forEach<List<ChatModel>>(
        chatListStream,
        onData: (data) {
          savedChats = data;
          savedChatsLocal = false;
          return ChatListLoaded(chatList: data, localSave: false);
        },
        onError: (error, stackTrace) {
          return ChatListLoaded(chatList: savedChats, localSave: savedChatsLocal, errorText: error.toString());
        },
      );
    });
    on<LoadChatList>((event, emit) {});
  }
}
