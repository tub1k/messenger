import 'dart:async';

import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class MockChatRepository implements IChatRepository {

  final List<MessageModel> _messagesDb = [];

  final _messagesController = StreamController<List<MessageModel>>.broadcast();

  @override
  Future<ChatModel> getChatObject(String chatID) {
    return Future.value(
      ChatModel(
        chatName: 'sigma chat',
        chatId: 'dasdsadsahodhsakd',
        lastMessage: MessageModel(
          id: 'asas132jk',
          text: '23',
          senderId: 'faaaha',
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
        loadedMessages: [],
      ),
    );
  }

  @override
  Stream<List<ChatModel>> getChats() {
    print('msg sent');
    return Stream.value([
      ChatModel(
        chatName: 'sigma chat',
        chatId: 'dasdsadsahodhsakd',
        lastMessage: MessageModel(
          id: 'asas132jk',
          text: '23',
          senderId: 'faaaha',
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
        loadedMessages: [],
      ),
    ]);
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    Future.microtask(() => _messagesController.add(List.unmodifiable(_messagesDb)));
    _startFakeBot();
    return _messagesController.stream;
    // return Stream.periodic(Duration(seconds: 1), (index) => [
    //   MessageModel(
    //     id: 'asas132jk',
    //     text: index.toString(),
    //     senderId: 'faaaha',
    //     timestamp: DateTime.now(),
    //     type: MessageType.text,
    //   ),
    // ]);
  }

  @override
  Future<List<MessageModel>> loadMessages(int messageAmount) {
    return Future.value([
      MessageModel(
        id: 'asas132jk',
        text: '23',
        senderId: 'faaaha',
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    ]);
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newMessage = MessageModel(id: DateTime.now().toString(), text: text, senderId: senderId, timestamp: DateTime.now(), type: type);
    _messagesDb.insert(0, newMessage);
    _messagesController.add(List.unmodifiable(_messagesDb));
    print('a message has been sent!!!!!!!');
    return Future.value();
  }
  
  @override
  Future<List<ChatModel>> getSavedChats() {
    return Future.delayed(const Duration(milliseconds: 200),  () {return [ChatModel(
        chatName: 'sigma chat',
        chatId: 'dasdsadsahodhsakd',
        lastMessage: MessageModel(
          id: 'asas132jk',
          text: '23',
          senderId: 'faaaha',
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
        loadedMessages: [],
      ),];});
  }

  void _startFakeBot() {
  Timer.periodic(const Duration(seconds: 5), (timer) {
    final botMessage = MessageModel(
      id: DateTime.now().toString(),
      text: "Бот ответил: ${timer.tick}",
      senderId: "bot_id", // чтобы isMe было false
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _messagesDb.insert(0, botMessage);
    _messagesController.add(List.unmodifiable(_messagesDb));
  });
}
}

