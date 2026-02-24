import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // Use explicit bucket reference
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://pvp-traders-app-5ed1e.appspot.com'
  );

  /// Upload an image to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadImage(File file, String folder) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${file.path.split('/').last}';
      final ref = _storage.ref().child(folder).child(fileName);
      
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> uploadImages(List<File> files, String folder) async {
    List<String> urls = [];
    
    for (var file in files) {
      final url = await uploadImage(file, folder);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Upload a video to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadVideo(File file, String folder) async {
    try {
      // Verify file exists
      if (!await file.exists()) {
        print('Error: Video file does not exist at path: ${file.path}');
        return null;
      }
      
      final fileSize = await file.length();
      print('Starting video upload from path: ${file.path}');
      print('Video file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_$timestamp.mp4';
      
      print('Storage bucket: ${_storage.bucket}');
      print('Upload path: $folder/$fileName');
      
      final ref = _storage.ref(folder).child(fileName);
      
      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      print('Starting upload task...');
      final uploadTask = ref.putFile(file, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(1);
        print('Upload progress: $progress% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)');
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => print('Upload complete'));
      print('Upload task completed. State: ${snapshot.state}');
      
      // Get download URL
      final url = await ref.getDownloadURL();
      print('Video uploaded successfully. URL: $url');
      return url;
    } catch (e, stackTrace) {
      print('Error uploading video: $e');
      print('Stack trace: $stackTrace');
      
      // Provide more specific error messages
      if (e.toString().contains('object-not-found')) {
        print('ERROR: Firebase Storage bucket not found or not initialized.');
        print('Please ensure Firebase Storage is enabled in Firebase Console:');
        print('https://console.firebase.google.com/project/pvp-traders-app-5ed1e/storage');
      } else if (e.toString().contains('unauthorized')) {
        print('ERROR: Permission denied. Check Firebase Storage rules.');
      } else if (e.toString().contains('quota-exceeded')) {
        print('ERROR: Storage quota exceeded.');
      }
      
      return null;
    }
  }

  /// Upload multiple videos to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> uploadVideos(List<File> files, String folder) async {
    List<String> urls = [];
    
    for (var file in files) {
      final url = await uploadVideo(file, folder);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Delete a file from Firebase Storage using its URL
  Future<bool> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
