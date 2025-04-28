import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

   // UserID methods
static Future<void> saveUserId(int userId) async {

  await _storage.write(key: 'userId', value: userId.toString());
}


  static Future<int?> getUserId() async {
    final userIdString = await _storage.read(key: 'userId');
    if (userIdString == null) {
      return null;
    }
    return int.tryParse(userIdString);
  }

  static Future<void> clearUserId() async {
    await _storage.delete(key: 'userId');
  }
}
