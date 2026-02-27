import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from gallery or camera
  /// Built-in compression: maxWidth/maxHeight/imageQuality
  Future<File?> pickImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800, // Limit resolution to prevent large files
      maxHeight: 800,
      imageQuality: 85, // Good balance of quality and size
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Uploads a file to Firebase Storage and returns the download URL
  Future<String> uploadAvatar({
    required String memberId,
    required File file,
  }) async {
    try {
      // Validate Check (5MB)
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        throw Exception('File is too large. Maximum size is 5MB.');
      }

      final String fileName = 'avatars/${memberId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);

      // Upload the file
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload not successful. State: ${snapshot.state}');
      }
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (e is FirebaseException) {
         // Log the full error to debug console
         debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
         throw Exception('Upload failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Uploads a generic image and returns download URL
  Future<String> uploadImage({
    required String path,
    required File file,
  }) async {
    try {
      final Reference ref = _storage.ref().child('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
