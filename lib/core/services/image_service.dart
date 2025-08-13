import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  // Singleton pattern
  ImageService._privateConstructor();
  static final ImageService _instance = ImageService._privateConstructor();
  factory ImageService() => _instance;

  final ImagePicker _picker = ImagePicker();

  // Picks an image from the gallery or camera, compresses it, and saves it locally.
  // Returns the path to the saved file.
  Future<String?> pickAndSaveImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImagePath = '${appDir.path}/$fileName';

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        savedImagePath,
        quality: 60, // Adjust quality as needed
      );

      return compressedFile?.path;
    } catch (e) {
      debugPrint('Error picking and saving image: $e');
      return null;
    }
  }

  // Deletes an image file from local storage.
  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  // Deletes a list of images.
  Future<void> deleteMultipleImages(List<String> paths) async {
    for (final path in paths) {
      await deleteImage(path);
    }
  }
}