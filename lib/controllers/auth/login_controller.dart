import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/constants/routes.dart';

abstract class LoginController extends GetxController {
  late TextEditingController email;
  late TextEditingController password;

  bool isLogin = false;

  bool isGuestLoading = false;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  Future<void> continueAsGuest();

  login();
}

class LoginControllerImp extends LoginController {
  bool obscurePassword = true;

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
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

      // final deviceToken = await Get.find<PushNotificationService>().getDeviceToken();

      var response = await authData.login(
        email: email.text,
        password: password.text,
        deviceToken: "deviceToken",
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

        Get.offAllNamed(AppRoutes.app);
      }

      isLogin = false;
      update();
    }
  }

  @override
  Future<void> continueAsGuest() async {
    if (isGuestLoading) return;
    isGuestLoading = true;
    update();

    final response = await authData.startGuest(deviceToken: "deviceToken");
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
      Get.offAllNamed(AppRoutes.app);
    } else {
      customSnackBar(text: response.message ?? "حدث خطأ");
    }

    isGuestLoading = false;
    update();
  }
}
