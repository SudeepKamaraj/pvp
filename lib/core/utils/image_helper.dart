import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAndConvertToBase64() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (image == null) return null;

      final File file = File(image.path);
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      return "data:image/jpeg;base64,$base64Image";
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  Future<List<String>> pickMultiImageAndConvertToBase64() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
      List<String> base64Images = [];

      for (var image in images) {
        final File file = File(image.path);
        final List<int> imageBytes = await file.readAsBytes();
        base64Images.add("data:image/jpeg;base64,${base64Encode(imageBytes)}");
      }
      return base64Images;
    } catch (e) {
      print("Error picking images: $e");
      return [];
    }
  }

  /// Pick a video and return the File (not base64)
  /// This should be uploaded to Firebase Storage instead
  Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      print("Error picking video: $e");
      return null;
    }
  }

  /// Pick multiple videos and return list of Files
  Future<List<File>> pickMultipleVideos() async {
    try {
      List<File> videos = [];
      
      // Since pickMultiVideo doesn't exist, pick one at a time
      // In a real app, you might want to show a dialog asking if user wants to add more
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        videos.add(File(video.path));
      }
      
      return videos;
    } catch (e) {
      print("Error picking videos: $e");
      return [];
    }
  }
}
