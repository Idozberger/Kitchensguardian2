import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProfileLocalDataSource {
  Future<String> setProfileImage({required String filePath});
  Future<String?> getProfileImage();
}

class ProfileLocalDatasourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDatasourceImpl({required this.sharedPreferences});

  static const _profileImageKey = "profile_image_path";

  @override
  Future<String> setProfileImage({required String filePath}) async {
    try {
      await sharedPreferences.setString(_profileImageKey, filePath);
      return filePath;
    } catch (e) {
      throw Exception("Failed to save profile image path: $e");
    }
  }

  @override
  Future<String?> getProfileImage() async {
    return sharedPreferences.getString(_profileImageKey);
  }
}
