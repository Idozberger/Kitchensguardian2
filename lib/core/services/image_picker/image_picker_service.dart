import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestPermissions(BuildContext context) async {
    await [
      Permission.camera,
      Platform.isAndroid ? Permission.storage : Permission.photos,
    ].request();

    return true;
  }

  static Future<File?> pickFromGallery(BuildContext context) async {
    final hasPermission = await _requestPermissions(context);
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 1,
    );
    return image != null ? File(image.path) : null;
  }
}
