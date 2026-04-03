import 'package:get/get.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';

/// FCM token for auth APIs (login, register, verify-otp, reset-password, etc.).
Future<String?> getAuthDeviceToken() async {
  if (!Get.isRegistered<PushNotificationService>()) return null;
  try {
    return await Get.find<PushNotificationService>().getDeviceToken();
  } catch (_) {
    return null;
  }
}
