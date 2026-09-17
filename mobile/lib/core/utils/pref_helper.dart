import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  static const _secureStorage = FlutterSecureStorage();

  // ── Token storage ──

  // flutter_secure_storage has no reliable web implementation (needs a
  // secure context + WebCrypto and can hang/throw on Chrome), so on web
  // we fall back to shared_preferences (localStorage). Mobile keeps the
  // encrypted store.
  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    try {
      return await _secureStorage.read(key: key).timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  static Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _secureStorage.delete(key: key);
  }

  static Future<void> saveToken(String token) => _write(_tokenKey, token);

  static Future<String?> getToken() => _read(_tokenKey);

  static Future<void> clearToken() => _delete(_tokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _write(_refreshTokenKey, token);

  static Future<String?> getRefreshToken() => _read(_refreshTokenKey);

  static Future<void> clearRefreshToken() => _delete(_refreshTokenKey);

  static Future<void> clearAll() async {
    await _delete(_tokenKey);
    await _delete(_refreshTokenKey);
  }
}
