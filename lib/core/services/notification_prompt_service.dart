import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// يعرض نافذة اقتراح تفعيل الإشعارات للمستخدم المسجّل فقط، مع احترام فترة 24 ساعة بين كل عرض.
class NotificationPromptService {
  static const Duration _promptCooldown = Duration(hours: 24);
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// استدعاؤه عند فتح التطبيق بعد تسجيل الدخول (مثلاً من AppController.onReady).
  /// يتحقق من: وجود توكن، عدم منح الصلاحية، مرور 24 ساعة منذ آخر عرض؛ ثم يعرض النافذة ويحفظ الوقت.
  Future<void> maybeShowPrompt() async {
    final token = Shared.getValue(StorageKeys.accessToken);
    if (token == null || token.toString().trim().isEmpty) return;

    final settings = await _messaging.getNotificationSettings();
    if (_isGranted(settings.authorizationStatus)) return;

    final lastShown = _getLastPromptTime();
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < _promptCooldown) {
      return;
    }

    _savePromptShownTime();
    if (Get.context == null || !Get.context!.mounted) return;
    await _showDialog();
  }

  bool _isGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  DateTime? _getLastPromptTime() {
    final v = Shared.getValue(StorageKeys.notificationPromptShownAt);
    if (v == null) return null;
    final ms = v is int ? v : (v is String ? int.tryParse(v) : null);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _savePromptShownTime() {
    Shared.setValue(
      StorageKeys.notificationPromptShownAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _showDialog() async {
    final scheme = Theme.of(Get.context!).colorScheme;
    final colors =
        Get.theme.extension<AppColors>() ?? AppColors.light;

    await Get.dialog<void>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  color: scheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'notification_prompt_title'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'notification_prompt_message'.tr,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
            textAlign: TextAlign.start,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colors.borderStrong),
                      ),
                    ),
                    child: Text(
                      'notification_prompt_later'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      final push = Get.find<PushNotificationService>();
                      await push.requestPermission();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'notification_prompt_enable'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
