import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/routes.dart';

abstract class ForgotPasswordController extends GetxController {
  TextEditingController email = TextEditingController();

  bool isLoading = false;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  sendOtp();
}

class ForgotPasswordControllerImp extends ForgotPasswordController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  sendOtp() async {
    if (formState.currentState!.validate()) {
      isLoading = true;
      update();

      var response = await authData.forgotPassword(email: email.text.trim());

      if (response.isSuccess) {
        customSnackBar(text: response.message ?? "تم إرسال رمز التحقق");
        Get.toNamed(
          AppRoutes.verifyCode,
          arguments: {'email': email.text.trim(), 'isForgotPassword': true},
        );
      }
      isLoading = false;
      update();
    }
  }
}
