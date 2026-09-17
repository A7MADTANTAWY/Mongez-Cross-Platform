import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  developer.log('FCM background: ${message.messageId}', name: 'FCM');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  ApiService? _api;

  FcmService();

  /// Call after login: request permission, get token, register with backend.
  Future<void> initAfterLogin(ApiService api) async {
    _api = api;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      developer.log('FCM permission: ${settings.authorizationStatus}',
          name: 'FCM');
    } catch (e) {
      developer.log('FCM permission failed: $e', name: 'FCM');
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        developer.log('FCM token: $token', name: 'FCM');
        await _registerToken(token);
      }
    } catch (e) {
      developer.log('FCM getToken failed: $e', name: 'FCM');
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _registerToken(newToken);
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

  Future<void> _registerToken(String token) async {
    if (_api == null) return;
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _api!.post(
        endPoint: Endpoints.deviceTokens,
        body: {'token': token, 'platform': platform},
      );
      developer.log('FCM token registered with backend', name: 'FCM');
    } catch (e) {
      developer.log('FCM token register failed: $e', name: 'FCM');
    }
  }
}
