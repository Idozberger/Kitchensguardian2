import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
      final savedPath = await _saveImagePermanently(File(filePath));
      await sharedPreferences.setString(_profileImageKey, savedPath);
      return savedPath;
    } catch (e) {
      throw Exception("Failed to save profile image path: $e");
    }
  }

  @override
  Future<String?> getProfileImage() async {
    final savedPath = sharedPreferences.getString(_profileImageKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      return savedPath;
    }
    return null;
  }

  @override
  Future<void> clearProfileImage() async {
    await sharedPreferences.remove(_profileImageKey);
  }

  Future<String> _saveImagePermanently(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage = await image.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      throw Exception("Error saving image permanently: $e");
    }
  }
}
