import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

abstract class RegisterController extends GetxController {
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController password;
  late TextEditingController confirmPassword;

  bool isRegister = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  register();
  void togglePasswordVisibility();
  void toggleConfirmPasswordVisibility();
}

class RegisterControllerImp extends RegisterController {
  @override
  void onInit() {
    firstName = TextEditingController();
    lastName = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
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
  register() async {
    if (formState.currentState!.validate()) {
      isRegister = true;
      update();

      final bool convertingFromGuest = isGuestAccount;
      var response = convertingFromGuest
          ? await authData.registerFromGuest(
              firstName: firstName.text,
              lastName: lastName.text,
              email: email.text,
              phone: phone.text,
              password: password.text,
              passwordConfirmation: confirmPassword.text,
            )
          : await authData.register(
              firstName: firstName.text,
              lastName: lastName.text,
              email: email.text,
              phone: phone.text,
              password: password.text,
              passwordConfirmation: confirmPassword.text,
            );

      if (response.isSuccess) {
        customSnackBar(text: response.message ?? "تم إنشاء الحساب بنجاح");
        if (response.data != null && response.data['account_state'] != null) {
          Shared.setValue(StorageKeys.accountState, response.data['account_state']);
        }
        // Navigate to verify code screen
        Get.toNamed(
          AppRoutes.verifyCode,
          arguments: {'email': email.text, 'isForgotPassword': false},
        );
      } else {
        customSnackBar(text: response.message ?? "حدث خطأ");
      }

      isRegister = false;
      update();
    }
  }
}
