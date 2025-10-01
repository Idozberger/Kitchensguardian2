import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage
  final storage = FlutterSecureStorage();

  Future<void> writeInSecureStroage({
    required String key,
    required String value,
  }) async {
    await storage.write(key: key, value: value);
  }

  // Read value
  Future<String?> readInSecureStorage({required String key}) async {
    String? value = await storage.read(key: key);
    if (value != null) {
      return value;
    }
    return null;
  }
}
