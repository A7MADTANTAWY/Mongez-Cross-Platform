import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';
import 'package:mongez/core/routing/navigation_service.dart';
import 'package:mongez/features/shared/notifications/data/models/notification_model.dart';
import 'package:mongez/features/shared/notifications/presentation/cubit/notification_cubit.dart';

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
  ApiService? _api;
  NotificationCubit? _cubit;

  FcmService();

  /// Wires the live incoming-message updates into the notifications cubit
  /// (badge + list) so the foreground banner and the in-app list stay in sync.
  void attachNotificationCubit(NotificationCubit cubit) => _cubit = cubit;

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('Notification tapped: ${details.payload}', name: 'FCM');
        _handleTapPayload(details.payload);
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
      payload: jsonEncode(message.data),
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

    // iOS: allow foreground presentation through FCM itself so pushes are not
    // dropped while the app is open (Android is driven by
    // flutter_local_notifications directly). This prevents a missing OR a
    // duplicated banner on iOS depending on the APNs payload.
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      developer.log('FCM presentation options failed: $e', name: 'FCM');
    }

    try {
      await _initLocalNotifications();
    } catch (e) {
      developer.log('Local notifications init failed: $e', name: 'FCM');
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        developer.log('FCM token: $token', name: 'FCM');
        await _registerToken(token);
      }
    } catch (e) {
      developer.log('FCM getToken failed: $e', name: 'FCM');
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken);
    });

    // Foreground messages → show as heads-up notification + update the cubit
    // immediately (badge + list) without waiting for the polling timer.
    FirebaseMessaging.onMessage.listen((message) {
      developer.log('FCM foreground: ${message.notification?.title}',
          name: 'FCM');
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log('FCM opened app: ${message.data}', name: 'FCM');
      _handleMessageData(message.data);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      developer.log('FCM terminated tap: ${initial.data}', name: 'FCM');
      _handleMessageData(initial.data);
    }

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;
    _cubit?.applyIncomingNotification(
      NotificationModel.incoming(
        title: notif.title ?? '',
        message: notif.body ?? '',
        data: message.data,
        createdAt: message.sentTime,
      ),
    );
    _showLocalNotification(message);
  }

  /// Deep-link for a banner tap. The payload is the JSON-encoded push `data`
  /// (keys match backend `_push_to_devices`: `order_id` is a string).
  void _handleTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      _handleMessageData((decoded as Map).cast<String, dynamic>());
    } catch (_) {
      NavigationService.openNotifications();
    }
  }

  /// Routes a push open to the linked order when an `order_id` is present,
  /// otherwise falls back to the notifications screen.
  void _handleMessageData(Map<String, dynamic> data) {
    final orderId = int.tryParse(data['order_id']?.toString() ?? '');
    if (orderId != null) {
      NavigationService.openOrderByNotification(orderId);
    } else {
      NavigationService.openNotifications();
    }
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
