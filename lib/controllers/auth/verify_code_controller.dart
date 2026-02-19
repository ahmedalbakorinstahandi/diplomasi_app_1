import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';

abstract class VerifyCodeController extends GetxController {
  late List<TextEditingController> otpControllers;
  late String email;
  late bool isForgotPassword;

  bool isLoading = false;
  int resendTimer = 60;
  bool canResend = false;

  int otpLength = 5;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  verifyOtp();
  void resendOtp();
  void startResendTimer();
  String getOtpCode();
}

class VerifyCodeControllerImp extends VerifyCodeController {
  @override
  void onInit() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    email = arguments?['email'] ?? '';
    isForgotPassword = arguments?['isForgotPassword'] ?? false;

    otpControllers = List.generate(otpLength, (index) => TextEditingController());
    startResendTimer();
    super.onInit();
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  @override
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  @override
  verifyOtp() async {
    final otp = getOtpCode();
    if (otp.length != otpLength) {
      customSnackBar(text: "الرجاء إدخال رمز التحقق كاملاً");
      return;
    }

    isLoading = true;
    update();

    var response = await authData.verifyOtp(email: email, otp: otp);

    if (response.isSuccess) {
      // Save access token if exists
      if (response.response != null &&
          response.response['access_token'] != null) {
        Shared.setValue(
          StorageKeys.accessToken,
          response.response['access_token'],
        );
      }

      if (isForgotPassword) {
        Get.offNamed(AppRoutes.resetPassword, arguments: {'email': email});
      } else {
        Get.offNamed(AppRoutes.authSuccess);
      }
    } else {
      customSnackBar(text: response.message ?? "رمز التحقق غير صحيح");
    }

    isLoading = false;
    update();
  }

  @override
  void resendOtp() async {
    if (!canResend) return;

    isLoading = true;
    update();

    var response = await authData.forgotPassword(email: email);

    if (response.isSuccess) {
      customSnackBar(text: "تم إرسال رمز التحقق مرة أخرى");
      resendTimer = 60;
      canResend = false;
      startResendTimer();
    } else {
      customSnackBar(text: response.message ?? "حدث خطأ");
    }

    isLoading = false;
    update();
  }

  @override
  void startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (resendTimer > 0) {
        resendTimer--;
        update();
        startResendTimer();
      } else {
        canResend = true;
        update();
      }
    });
  }
}
