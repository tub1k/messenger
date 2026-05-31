abstract class IImageRepository {
  Future<void> saveImageToGallery(String url);
}