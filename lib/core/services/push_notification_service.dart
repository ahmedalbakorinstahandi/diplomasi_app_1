import 'dart:convert';

import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/notification_navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: keep lightweight and side-effect free.
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;
  RemoteMessage? _pendingInitialMessage;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _storeDeviceToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      Shared.setValue(StorageKeys.fcmToken, token);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTapMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingInitialMessage = initialMessage;
    }
  }

  /// Call after the navigator is ready (e.g. from AppScreen / Login onReady).
  /// Handles the notification that opened the app from a cold start.
  Future<void> handlePendingInitialMessageIfAny() async {
    final message = _pendingInitialMessage;
    if (message == null) return;
    _pendingInitialMessage = null;
    await _handleTapMessage(message);
  }

  Future<String?> getDeviceToken() async {
    final fromStorage = Shared.getValue(StorageKeys.fcmToken);
    if (fromStorage is String && fromStorage.trim().isNotEmpty) {
      return fromStorage.trim();
    }

    final token = await _messaging.getToken();
    if (token != null && token.trim().isNotEmpty) {
      Shared.setValue(StorageKeys.fcmToken, token.trim());
      return token.trim();
    }

    return null;
  }

  /// استدعاؤه من واجهة المستخدم فقط (مثلاً بعد تسجيل الدخول أو من نافذة الاقتراح).
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
  }

  Future<void> _storeDeviceToken() async {
    final token = await _messaging.getToken();
    if (token != null && token.trim().isNotEmpty) {
      Shared.setValue(StorageKeys.fcmToken, token.trim());
    }
  }

  Future<void> _handleTapMessage(RemoteMessage message) async {
    final navigator = Get.find<NotificationNavigationService>();
    await navigator.handlePayload(
      type: message.data['type']?.toString(),
      payload: _normalizePayload(message.data),
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title ?? 'إشعار جديد',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        messageText: Text(
          body ?? '',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        backgroundColor: Colors.black87,
        onTap: (_) async {
          await _handleTapMessage(message);
        },
      ),
    );
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{...data};
    final nestedData = data['data'];
    if (nestedData is String && nestedData.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(nestedData);
        if (parsed is Map) {
          parsed.forEach((key, value) {
            normalized['$key'] = value;
          });
        }
      } catch (_) {
        // Ignore invalid json payload.
      }
    }
    return normalized;
  }
}
