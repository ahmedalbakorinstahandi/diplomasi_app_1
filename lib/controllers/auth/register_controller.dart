import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/functions/auth_device_token.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Pass in [Get.toNamed](AppRoutes.register, arguments: {…}) when opening from login.
const registerOpenedFromLoginArg = 'registerOpenedFromLogin';

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
  void navigateToLoginOrBack();
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

  bool _isRegisterOpenedFromLogin() {
    final args = Get.arguments;
    if (args is Map && args[registerOpenedFromLoginArg] == true) return true;
    return Get.previousRoute == AppRoutes.login;
  }

  @override
  void navigateToLoginOrBack() {
    if (_isRegisterOpenedFromLogin()) {
      final ctx = Get.context;
      if (ctx != null && Navigator.canPop(ctx)) {
        Get.back();
        return;
      }
    }
    Get.offNamed(AppRoutes.login);
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
      final deviceToken = convertingFromGuest
          ? await getAuthDeviceToken()
          : null;
      var response = convertingFromGuest
          ? await authData.registerFromGuest(
              firstName: firstName.text,
              lastName: lastName.text,
              email: email.text,
              phone: phone.text,
              password: password.text,
              passwordConfirmation: confirmPassword.text,
              deviceToken: deviceToken,
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
          Shared.setValue(
            StorageKeys.accountState,
            response.data['account_state'],
          );
        }
        // Navigate to verify code screen
        Get.toNamed(
          AppRoutes.verifyCode,
          arguments: {'email': email.text, 'isForgotPassword': false},
        );
      }

      isRegister = false;
      update();
    }
  }
}
