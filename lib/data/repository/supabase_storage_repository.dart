import 'dart:typed_data';

import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageRepository implements IStorageRepository {
  final _supabase = Supabase.instance.client;
  @override
  Future<String> uploadImage(Uint8List image, String bucketName, String path) async {
    try {
      final storageResponse = await _supabase.storage.from(bucketName).uploadBinary(path, image);
      return storageResponse;
    } catch (e) {throw e.toString();} // TODO: FIX
  }
  
  @override
  Future<String> getGroupPhotoUrl(String uid) async {
    final storageResponse = _supabase.storage.from('groupAvatars').getPublicUrl(uid);
    return storageResponse;
  }
}