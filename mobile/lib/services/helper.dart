import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrefHelper {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  static const _secureStorage = FlutterSecureStorage();

  // ── Token storage (encrypted) ──

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearAll() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
