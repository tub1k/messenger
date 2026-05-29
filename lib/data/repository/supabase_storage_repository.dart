import 'dart:typed_data';

import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseStorageRepository implements IStorageRepository {
  final _supabase = Supabase.instance.client;
  @override
  Future<String> uploadImage(
    Uint8List image,
    String bucketName,
    String path,
  ) async {
    try {
      final storageResponse = await _supabase.storage
          .from(bucketName)
          .uploadBinary(path, image);
      return storageResponse;
    } catch (e) {
      throw e.toString();
    } 
  }

  @override
  Future<String> getGroupPhotoUrl(String uid) async {
    final url = _supabase.storage
        .from('groupAvatars')
        .getPublicUrl('public/$uid/avatar.png');
    final response = await http.head(Uri.parse(url));

    if (response.statusCode == 200) {
      return url;
    } else {
      return '';
    }
  }
}
