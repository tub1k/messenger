import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';

abstract class IChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
  });

  Future<ChatModel> getChatObject(String chatID);

  Future<List<MessageModel>> loadOlderMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    required int limit,
  });

  Stream<List<ChatModel>> getChats(String myId);

  Future<List<ChatModel>> getSavedChats();

  Future<void> createChat({
    String? chatName,
    required List<String> userUids,
  });

  Future<BaseUserModel> getBaseUserByUsername(String username);
}