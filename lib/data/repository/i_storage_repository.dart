import 'dart:typed_data';

abstract class IStorageRepository {
  Future<String> uploadImage(Uint8List image, String bucketName, String path);

  Future<String> getGroupPhotoUrl(String uid);
}