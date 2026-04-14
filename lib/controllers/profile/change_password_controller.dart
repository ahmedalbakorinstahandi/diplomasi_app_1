import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/auth_device_token.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/app_shell_bootstrap.dart';
import 'package:diplomasi_app/data/resource/remote/user/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordControllerImp extends GetxController {
  UserData userData = UserData();

  // Text Controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  // State
  bool isLoading = false;
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword = !obscureCurrentPassword;
    update();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    update();
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كلمة المرور الحالية';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كلمة المرور الجديدة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون على الأقل 8 محارف';
    }
    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
    //   return 'يجب أن تحتوي على أحرف كبيرة';
    // }
    // if (!RegExp(r'[a-z]').hasMatch(value)) {
    //   return 'يجب أن تحتوي على أحرف صغيرة';
    // }
    // if (!RegExp(r'[0-9]').hasMatch(value)) {
    //   return 'يجب أن تحتوي على أرقام';
    // }
    // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    //   return 'يجب أن تحتوي على رمز';
    // }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != newPasswordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  Future<void> changePassword() async {
    // Validate all fields
    if (!formState.currentState!.validate()) return;

    final newPasswordError = validateNewPassword(newPasswordController.text);
    if (newPasswordError != null) {
      customSnackBar(text: newPasswordError, snackType: SnackBarType.error);
      return;
    }

    isLoading = true;
    update();

    final deviceToken = await getAuthDeviceToken();
    final response = await userData.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      deviceToken: deviceToken,
    );

    if (response.isSuccess) {
      if (response.response != null &&
          response.response['access_token'] != null) {
        Shared.setValue(
          StorageKeys.accessToken,
          response.response['access_token'],
        );
      }
      if (response.data != null) {
        Shared.setValue('user-data', response.data);
        if (response.data['account_state'] != null) {
          Shared.setValue(
            StorageKeys.accountState,
            response.data['account_state'],
          );
        }
      }
      Shared.setValue(StorageKeys.step, Steps.homeApp);
      customSnackBar(
        text: response.message ?? 'تم تغيير كلمة المرور بنجاح',
        snackType: SnackBarType.correct,
      );
      await AppShellBootstrap.ensurePreparedForCurrentToken();
      Get.offAllNamed(AppRoutes.app);
    }

    isLoading = false;
    update();
  }
}
