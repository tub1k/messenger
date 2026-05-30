import 'dart:typed_data';

import 'package:messenger/data/models/message_model.dart';

abstract class IStorageRepository {
  Future<String> uploadImage(Uint8List image, String bucketName, String path);

  Future<String> getGroupPhotoUrl(String uid);

  List<String> getMessagePhotos(String chatId, MessageModel message);
}