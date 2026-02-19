import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/routes.dart';

abstract class ResetPasswordController extends GetxController {
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late String email;

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

    password = TextEditingController();
    confirmPassword = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    password.dispose();
    confirmPassword.dispose();
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

      var response = await authData.resetPassword(
        email: email,
        password: password.text,
        passwordConfirmation: confirmPassword.text,
      );

      if (response.isSuccess) {
        customSnackBar(text: response.message ?? "تم تغيير كلمة المرور بنجاح");
        Get.offAllNamed(AppRoutes.authSuccess);
      } else {
        customSnackBar(text: response.message ?? "حدث خطأ");
      }

      isLoading = false;
      update();
    }
  }
}
