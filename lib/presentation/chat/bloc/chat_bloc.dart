import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;
  final String myId;
  final String chatId;
  ChatBloc({
    required IChatRepository repository,
    required this.myId,
    required this.chatId,
  }) : _repository = repository,
       super(ChatInitial()) {
    on<ChatEvent>((event, emit) {});
    on<ChatStarted>((event, emit) async {
      print('Блок запущен для чата: ${event.chatId}');
      await emit.forEach(
        _repository.getMessages(chatId),
        onData: (messages) => ChatLoaded(messages: messages),
        onError: (error, _) =>
            ChatLoaded(messages: const [], errorText: error.toString()),
      );
    });
    on<ChatMessageSent>((event, emit) async {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      final optimisticMessage = MessageModel(id: DateTime.now().toString(), text: event.text, senderId: myId, timestamp: DateTime.now(), type: event.messageType, isPending: true);

      emit(ChatLoaded(messages: [optimisticMessage]+currentState.messages));

      await _repository.sendMessage(
        chatId: chatId,
        text: event.text,
        senderId: myId,
        type: MessageType.text,
      );
    });
  }
}
