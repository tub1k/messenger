import 'package:messenger/data/models/message_model.dart';

abstract class IChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
  });

  Future<ChatModel> getChatObject(String chatID);

  Future<List<MessageModel>> loadMessages(int messageAmount);

  Stream<List<ChatModel>> getChats();

  Future<List<ChatModel>> getSavedChats();
}