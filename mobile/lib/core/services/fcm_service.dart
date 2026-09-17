import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';

/// Background message handler – must be a top-level function.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  developer.log('FCM background: ${message.messageId}', name: 'FCM');
}

class FcmService {
  final ApiService _api;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FcmService(this._api);

  /// Call once after login / app start.
  Future<void> init() async {
    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log('FCM permission: ${settings.authorizationStatus}',
        name: 'FCM');

    // Get token
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_registerToken);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap (app in background, user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Terminated state tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _onMessageOpenedApp(initial);
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  void _onForegroundMessage(RemoteMessage message) {
    developer.log('FCM foreground: ${message.notification?.title}',
        name: 'FCM');
    // In-app notification is handled by the notification list polling.
    // You can show a local snackbar/toast here if desired.
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    developer.log('FCM opened app: ${message.data}', name: 'FCM');
    // Deep-link navigation can be handled here using message.data['order_id'] etc.
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _api.post(
        endPoint: Endpoints.deviceTokens,
        body: {'token': token, 'platform': platform},
      );
      developer.log('FCM token registered', name: 'FCM');
    } catch (e) {
      developer.log('FCM token register failed: $e', name: 'FCM');
    }
  }
}
