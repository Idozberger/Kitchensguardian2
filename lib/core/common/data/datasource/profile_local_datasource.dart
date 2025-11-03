import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProfileLocalDataSource {
  Future<String> setProfileImage({required String filePath});

  Future<String?> getProfileImage();

  Future<void> clearProfileImage();
}

class ProfileLocalDatasourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDatasourceImpl({required this.sharedPreferences});

  static const _profileImageKey = "profile_image_path";

  @override
  Future<String> setProfileImage({required String filePath}) async {
    try {
      final base64Image = await convertImageToBase64(File(filePath));

      await sharedPreferences.setString(_profileImageKey, base64Image);
      return base64Image;
    } catch (e) {
      throw Exception("Failed to save profile image path: $e");
    }
  }

  @override
  Future<String?> getProfileImage() async {
    final imageBytes = sharedPreferences.getString(_profileImageKey);
    if (imageBytes != null) {
      return imageBytes;
    }
    return null;
  }

  @override
  Future<void> clearProfileImage() async {
    await sharedPreferences.remove(_profileImageKey);
  }

  Future<String> convertImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }
}
