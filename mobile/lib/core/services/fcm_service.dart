import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';

/// Background message handler – must be a top-level function.
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  developer.log('FCM background: ${message.messageId}', name: 'FCM');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _pendingToken;
  ApiService? _api;

  FcmService();

  /// Request permission + get token. Safe to call at startup (no auth needed).
  Future<void> requestPermissionAndGetToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log('FCM permission: ${settings.authorizationStatus}',
        name: 'FCM');

    final token = await _messaging.getToken();
    if (token != null) {
      _pendingToken = token;
      developer.log('FCM token obtained (pending registration)', name: 'FCM');
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _pendingToken = newToken;
      _tryRegisterToken();
    });

    FirebaseMessaging.onMessage.listen((message) {
      developer.log('FCM foreground: ${message.notification?.title}',
          name: 'FCM');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log('FCM opened app: ${message.data}', name: 'FCM');
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      developer.log('FCM terminated tap: ${initial.data}', name: 'FCM');
    }

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  /// Call after login so we have an auth token to register the device.
  void registerWithBackend(ApiService api) {
    _api = api;
    _tryRegisterToken();
  }

  Future<void> _tryRegisterToken() async {
    if (_pendingToken == null || _api == null) return;
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _api!.post(
        endPoint: Endpoints.deviceTokens,
        body: {'token': _pendingToken, 'platform': platform},
      );
      developer.log('FCM token registered with backend', name: 'FCM');
    } catch (e) {
      developer.log('FCM token register failed: $e', name: 'FCM');
    }
  }
}
