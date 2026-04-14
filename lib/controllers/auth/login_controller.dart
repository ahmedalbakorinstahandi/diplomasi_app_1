import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/auth_response_keys.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/auth_device_token.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/app_shell_bootstrap.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../core/constants/routes.dart';

abstract class LoginController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLogin = false;

  bool isGuestLoading = false;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  Future<void> continueAsGuest();

  login();
  Future<void> offerAccountActivationFlow();
}

class LoginControllerImp extends LoginController {
  bool obscurePassword = true;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Get.find<PushNotificationService>().handlePendingInitialMessageIfAny();
    });
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update();
  }

  @override
  login() async {
    if (formState.currentState!.validate()) {
      isLogin = true;
      update();

      final deviceToken = await getAuthDeviceToken();

      var response = await authData.login(
        email: email.text.trim(),
        password: password.text,
        deviceToken: deviceToken,
      );

      if (response.isSuccess) {
        customSnackBar(text: response.message ?? "");

        Shared.setValue(
          StorageKeys.accessToken,
          response.response['access_token'],
        );
        Shared.setValue('user-data', response.data);
        if (response.data != null && response.data['account_state'] != null) {
          Shared.setValue(
            StorageKeys.accountState,
            response.data['account_state'],
          );
        }

        Shared.setValue(StorageKeys.step, Steps.homeApp);

        await AppShellBootstrap.ensurePreparedForCurrentToken();
        Get.offAllNamed(AppRoutes.app);
      } else if (response.key == AuthResponseKeys.accountNotVerified) {
        await offerAccountActivationFlow();
      }

      isLogin = false;
      update();
    }
  }

  @override
  Future<void> offerAccountActivationFlow() async {
    final confirmed = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفعيل الحساب'),
          content: const Text(
            'حسابك غير مفعّل بعد. هل تريد إرسال رمز تحقق إلى بريدك الإلكتروني لتفعيله؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('نعم، أرسل الرمز'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    isLogin = true;
    update();

    final sendResponse = await authData.forgotPassword(
      email: email.text.trim().trim(),
      purpose: 'account_activation',
    );

    isLogin = false;
    update();

    if (sendResponse.isSuccess) {
      customSnackBar(
        text: sendResponse.message ?? 'تم إرسال رمز التحقق إلى بريدك',
      );
      Get.toNamed(
        AppRoutes.verifyCode,
        arguments: {
          'email': email.text.trim().trim(),
          'isForgotPassword': false,
          'showActivationSuccess': true,
        },
      );
    }
  }

  @override
  Future<void> continueAsGuest() async {
    if (isGuestLoading) return;
    isGuestLoading = true;
    update();

    final deviceToken = await getAuthDeviceToken();
    final response = await authData.startGuest(deviceToken: deviceToken);
    if (response.isSuccess) {
      Shared.setValue(
        StorageKeys.accessToken,
        response.response['access_token'],
      );
      Shared.setValue('user-data', response.data);
      if (response.data != null && response.data['account_state'] != null) {
        Shared.setValue(
          StorageKeys.accountState,
          response.data['account_state'],
        );
      }
      Shared.setValue(StorageKeys.step, Steps.homeApp);
      await AppShellBootstrap.ensurePreparedForCurrentToken();
      Get.offAllNamed(AppRoutes.app);
    }
    isGuestLoading = false;
    update();
  }
}
