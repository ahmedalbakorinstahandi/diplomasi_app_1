import 'dart:io';

import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/data/resource/remote/general/settings_data.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:diplomasi_app/view/widgets/profile/account_deletion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share_plus/share_plus.dart';

abstract class ProfileController extends GetxController {
  bool notificationsEnabled = true;
  bool isNotificationsEnabled = false;
  bool isNotificationActionInProgress = false;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool isShareAppInProgress = false;
  bool isLoggingOut = false;
  bool isDeletingAccount = false;
  bool isRequestingDeletionCode = false;
  int resendTimer = 0;
  bool canResendDeletionCode = false;

  String shareLink = '';

  SettingsData settingsData = SettingsData();
  AuthData authData = AuthData();

  void toggleNotifications(bool value);
  Future<void> getProfile();
  void setNotificationsEnabled(bool value);

  Future<void> shareApp();

  void logout();
  void performLogout();

  void requestAccountDeletion();
  void confirmAccountDeletion(String code);
  void resendDeletionCode();
  void startResendTimer();
}

class ProfileControllerImp extends ProfileController {
  @override
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    update();
  }

  @override
  Future<void> getProfile() {
    throw UnimplementedError();
  }

  @override
  void setNotificationsEnabled(bool value, {bool showSnackbar = true}) async {
    if (isNotificationActionInProgress) return;

    isNotificationActionInProgress = true;
    update();

    try {
      if (value) {
        final granted = await _ensureNotificationPermission();

        if (!granted) {
          isNotificationsEnabled = false;
          Shared.setValue('isNotificationsEnabled', false);
          await _messaging.setAutoInitEnabled(false);

          if (showSnackbar) {
            customSnackBar(
              text: 'notifications_permission_required'.tr,
              snackType: SnackBarType.error,
            );
          }
          return;
        }

        await _messaging.setAutoInitEnabled(true);
        await _messaging.getToken();

        isNotificationsEnabled = true;
        Shared.setValue('isNotificationsEnabled', true);
        if (showSnackbar) {
          customSnackBar(
            text: 'notifications_enabled_success'.tr,
            snackType: SnackBarType.correct,
          );
        }
      } else {
        await _disableNotifications();
        isNotificationsEnabled = false;
        Shared.setValue('isNotificationsEnabled', false);
        if (showSnackbar) {
          customSnackBar(
            text: 'notifications_disabled_success'.tr,
            snackType: SnackBarType.info,
          );
        }
      }
    } catch (e) {
      if (showSnackbar) {
        customSnackBar(
          text: 'notifications_permission_error'.tr,
          message: e.toString(),
          snackType: SnackBarType.error,
        );
      }
    } finally {
      isNotificationActionInProgress = false;
      update();
    }
  }

  bool _isPermissionGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<bool> _ensureNotificationPermission() async {
    final current = await _messaging.getNotificationSettings();
    if (_isPermissionGranted(current.authorizationStatus)) {
      return true;
    }

    final requested = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    return _isPermissionGranted(requested.authorizationStatus);
  }

  Future<void> _disableNotifications() async {
    await _messaging.setAutoInitEnabled(false);
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Ignored: token might not exist yet.
    }
  }

  @override
  Future<void> shareApp() async {
    if (isShareAppInProgress) return;

    isShareAppInProgress = true;
    update();

    if (shareLink.isEmpty) {
      String shareLinkKey = '';

      if (Platform.isAndroid) {
        shareLinkKey = 'app.google_play_link';
      } else if (Platform.isIOS) {
        shareLinkKey = 'app.apple_store_link';
      }

      var response = await settingsData.get(idOrKey: shareLinkKey);
      if (response.isSuccess) {
        shareLink = response.data['value'];
      }
    }

    if (shareLink.isEmpty) {
      customSnackBar(text: 'share_app_error'.tr, snackType: SnackBarType.error);
    } else {
      await Share.share(shareLink);
    }

    isShareAppInProgress = false;
    update();
  }

  @override
  void logout() {
    Get.dialog(
      // context: Get.context!,
      GetBuilder<ProfileControllerImp>(
        builder: (controller) {
          final colors = Get.theme.extension<AppColors>() ?? AppColors.light;
          final scheme = Get.theme.colorScheme;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.logout, color: scheme.error, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'logout'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: Text(
                'logout_confirmation'.tr,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
                textAlign: TextAlign.center,
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
                          'cancel'.tr,
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
                        onPressed: () {
                          if (!isLoggingOut) {
                            performLogout();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: isLoggingOut
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: scheme.onError,
                                ),
                              )
                            : Text(
                                'logout'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onError,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void performLogout() async {
    if (isLoggingOut) return;

    isLoggingOut = true;
    update();
    var response = await authData.logout();
    if (response.isSuccess) {
      Get.back();
      Shared.setValue(StorageKeys.step, Steps.login);
      Shared.clear();
      Get.offAllNamed(AppRoutes.login);
      customSnackBar(
        text: response.message ?? '',
        snackType: SnackBarType.correct,
      );
    }
    isLoggingOut = false;
    update();
  }

  @override
  void requestAccountDeletion() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Get.theme.colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'حذف الحساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Get.theme.colorScheme.error.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Get.theme.colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم حذف جميع بياناتك بشكل نهائي. هذه العملية لا يمكن التراجع عنها.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'هل أنت متأكد من رغبتك في حذف حسابك؟',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
            ],
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
                        side: BorderSide(
                          color:
                              (Get.theme.extension<AppColors>() ??
                                      AppColors.light)
                                  .borderStrong,
                        ),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            (Get.theme.extension<AppColors>() ??
                                    AppColors.light)
                                .textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRequestingDeletionCode
                        ? null
                        : () {
                            Get.back();
                            _performRequestAccountDeletion();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'متابعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performRequestAccountDeletion() async {
    if (isRequestingDeletionCode) return;

    isRequestingDeletionCode = true;
    update();

    var response = await authData.requestAccountDeletion();

    isRequestingDeletionCode = false;
    update();

    if (response.isSuccess) {
      final user = getUserData();
      final email = user?.email ?? '';

      // Start resend timer
      resendTimer = 60;
      canResendDeletionCode = false;
      startResendTimer();

      // Show code input dialog
      _showAccountDeletionDialog(email);

      customSnackBar(
        text: response.message ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
        snackType: SnackBarType.correct,
      );
    } else {
      customSnackBar(
        text: response.message ?? 'حدث خطأ أثناء طلب حذف الحساب',
        snackType: SnackBarType.error,
      );
    }
  }

  @override
  void confirmAccountDeletion(String code) async {
    if (isDeletingAccount || code.length != 5) return;

    isDeletingAccount = true;
    update();

    var response = await authData.confirmAccountDeletion(code: code);

    if (response.isSuccess) {
      Get.back(); // Close dialog
      customSnackBar(
        text: response.message ?? 'تم حذف حسابك بنجاح',
        snackType: SnackBarType.correct,
      );

      // Logout and redirect to login
      await Future.delayed(const Duration(seconds: 1));
      Shared.setValue(StorageKeys.step, Steps.login);
      Shared.clear();
      Get.offAllNamed(AppRoutes.login);
    } else {
      customSnackBar(
        text: response.message ?? 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        snackType: SnackBarType.error,
      );
    }

    isDeletingAccount = false;
    update();
  }

  @override
  void resendDeletionCode() async {
    if (!canResendDeletionCode || isRequestingDeletionCode) return;

    // Close current dialog
    Get.back();

    await _performRequestAccountDeletion();
  }

  void _showAccountDeletionDialog(String email) {
    Get.dialog(
      GetBuilder<ProfileControllerImp>(
        builder: (controller) {
          return AccountDeletionDialog(
            email: email,
            onConfirm: controller.confirmAccountDeletion,
            onCancel: () => Get.back(),
            isLoading: controller.isDeletingAccount,
            onResend: controller.resendDeletionCode,
            canResend: controller.canResendDeletionCode,
            resendTimer: controller.resendTimer > 0
                ? controller.resendTimer
                : null,
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  void startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (resendTimer > 0) {
        resendTimer--;
        update();
        startResendTimer();
      } else {
        canResendDeletionCode = true;
        update();
      }
    });
  }
}
