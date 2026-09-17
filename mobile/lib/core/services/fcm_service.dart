import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  developer.log('FCM background: ${message.messageId}', name: 'FCM');
}

const _channelId = 'mongez_notifications';
const _channelName = 'Mongez Notifications';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  ApiService? _api;

  FcmService();

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('Notification tapped: ${details.payload}', name: 'FCM');
      },
    );

    // Create channel with HIGH importance for heads-up banners
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Order and service notifications',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Order and service notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        contentTitle: notification.title,
      ),
    );
    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }

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
      await _initLocalNotifications();
    } catch (e) {
      developer.log('Local notifications init failed: $e', name: 'FCM');
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

    // Foreground messages → show as heads-up notification
    FirebaseMessaging.onMessage.listen((message) {
      developer.log('FCM foreground: ${message.notification?.title}',
          name: 'FCM');
      _showLocalNotification(message);
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
