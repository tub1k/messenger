import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';

abstract class IChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);

  Future<String> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required MessageType type,
    required ChatModel chat,
    required String messageId,
    int? imageAmount,
  });

  Future<ChatModel?> getChatObject(String chatID, String myId);

  Future<List<MessageModel>> loadOlderMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    required int limit,
  });

  Stream<List<ChatModel>> getChats(String myId);

  Future<List<ChatModel>> getCachedChats(String myId);

  Future<String> createChat({String? chatName, required List<String> userUids});

  /// returns a base user model from username. contains only base info.
  Future<BaseUserModel> getBaseUserByUsername(String username);

  /// gets a chat model by UIDs of users. If chat doesnt exist yet, returns null.
  /// assumes that only one DM chat can exist between users at a time.
  Future<ChatModel?> getDms(String uid1, String uid2, String myId);

  /// returns a base user model from uid. contains only base info.
  Future<BaseUserModel> getBaseUserByUID(String uid, {bool? getFromCache});

  /// get baseusermodels from all users from a list of UIDs.
  /// mainly used for creating a chat model after downloading user UIDs from firebase.
  Future<List<BaseUserModel>> getBaseUsersFromListOfUIDs(List<String> uidList);

  Future<void> sendSafePush({
    required String targetFcmToken,
    required String title,
    required String body,
    required String type, // type of the action we do on click
    required String id, // id of the chat or any other additional info
  });
}
