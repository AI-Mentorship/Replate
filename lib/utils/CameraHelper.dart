import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Opens the camera and returns the captured image as a File.
  static Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        print('No image selected.');
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
