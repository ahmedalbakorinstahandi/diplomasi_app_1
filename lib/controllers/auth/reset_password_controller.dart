import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/auth_device_token.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/app_shell_bootstrap.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

abstract class ResetPasswordController extends GetxController {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  String email = '';

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  resetPassword();
  void togglePasswordVisibility();
  void toggleConfirmPasswordVisibility();
}

class ResetPasswordControllerImp extends ResetPasswordController {
  @override
  void onInit() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    email = arguments?['email'] ?? '';

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update();
  }

  @override
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    update();
  }

  @override
  resetPassword() async {
    if (formState.currentState!.validate()) {
      isLoading = true;
      update();

      final deviceToken = await getAuthDeviceToken();
      var response = await authData.resetPassword(
        email: email,
        password: password.text,
        passwordConfirmation: confirmPassword.text,
        deviceToken: deviceToken,
      );

      if (response.isSuccess) {
        customSnackBar(text: response.message ?? "تم تغيير كلمة المرور بنجاح");
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
        await AppShellBootstrap.ensurePreparedForCurrentToken();
        Get.offAllNamed(AppRoutes.app);
      }

      isLoading = false;
      update();
    }
  }
}
