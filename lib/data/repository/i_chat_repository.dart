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

  Future<ChatModel?> getChatObject(String chatID, String myId);

  Future<List<MessageModel>> loadOlderMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    required int limit,
  });

  Stream<List<ChatModel>> getChats(String myId);

  Future<List<ChatModel>> getSavedChats();

  Future<String> createChat({
    String? chatName,
    required List<String> userUids,
  });

  /// returns a base user model from username. contains only base info.
  Future<BaseUserModel> getBaseUserByUsername(String username);

  /// gets a chat model by UIDs of users. If chat doesnt exist yet, returns null.
  /// assumes that only one DM chat can exist between users at a time.
  Future<ChatModel?> getDms(String uid1, String uid2, String myId);
}