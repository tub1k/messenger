import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:messenger/data/repository/i_image_repository.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepositoryImpl implements IImageRepository {
  final Dio _dio;

  ImageRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<void> saveImageToGallery(String url) async {
    try {
      // check/request permissions
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) throw Exception('galleryPermissionDenied');
      }

      // setup temporary path
      final tempDir = await getTemporaryDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${tempDir.path}/$fileName';

      // download the file
      await _dio.download(url, filePath);

      // change datetime in file metadata to make it appear the latest in gallery
      final file = File(filePath);
      final exif = await Exif.fromPath(filePath);
      final format = DateFormat('yyyy:MM:dd HH:mm:ss');
      await exif.writeAttribute('DateTimeOriginal', format.format(DateTime.now()));
      await exif.close();

      await Gal.putImage(filePath);
      
      // clean up the temporary cache file
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
} 