import 'dart:typed_data';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseStorageRepository implements IStorageRepository {
  final _supabase = Supabase.instance.client;
  final Map<String, List<String>> _urlsCache = {};
  @override
  Future<String> uploadImage(
    Uint8List image,
    String bucketName,
    String path,
  ) async {
    try {
      final storageResponse = await _supabase.storage
          .from(bucketName)
          .uploadBinary(path, image).timeout(const Duration(seconds: 30));
      return storageResponse;
    } catch (e) {
      rethrow;
    } 
  }

  @override
  Future<String> getGroupPhotoUrl(String uid) async {
    try {
  final url = _supabase.storage
      .from('groupAvatars')
      .getPublicUrl('public/$uid/avatar.png');
  if (FastCachedImageConfig.isCached(imageUrl: url)) return url;
  return await checkIfUrlExists(url);
  } catch (e) {
  return '';
  }
  }

  @override
  Future<String> getProfilePhotoUrl(String uid) async {
    try {
  final url = _supabase.storage
      .from('userAvatars')
      .getPublicUrl('public/$uid/avatar.png');
  if (FastCachedImageConfig.isCached(imageUrl: url)) return url;
  return await checkIfUrlExists(url);
  } catch (e) {
  return '';
  }
  }

  

  Future<String> checkIfUrlExists(String url) async {
    final response = await http.head(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return url;
    } else {
      return '';
    }
  }
  
  @override
  List<String> getMessagePhotos(String chatId, MessageModel msg) {
    if (_urlsCache.containsKey(msg.id)) {
      return _urlsCache[msg.id]!;
    }
    if (msg.type != MessageType.image || msg.imageAmount == null || msg.imageAmount == 0) {
      return [];
    }
    final urls = List.generate(msg.imageAmount!, (index) {
      return _supabase.storage
          .from('chatMedia')
          .getPublicUrl('public/$chatId/${msg.id}/$index.png');
    });

    _urlsCache[msg.id] = urls;

    return urls;
  }
}
