import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/auth_device_token.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:diplomasi_app/view/screens/auth/success.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

abstract class VerifyCodeController extends GetxController {
  List<TextEditingController> otpControllers = [];
  String email = '';
  bool isForgotPassword = false;

  /// بعد تسجيل الدخول لحساب غير مفعّل: عرض شاشة نجاح ثم التطبيق.
  bool showActivationSuccess = false;

  bool isLoading = false;
  int resendTimer = 60;
  bool canResend = false;

  int otpLength = 5;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  AuthData authData = AuthData();

  verifyOtp();
  void applyPastedOtp(String raw);
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
    showActivationSuccess = arguments?['showActivationSuccess'] == true;

    otpControllers = List.generate(
      otpLength,
      (index) => TextEditingController(),
    );
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
  void applyPastedOtp(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    final buf = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;
    for (var i = 0; i < otpLength; i++) {
      otpControllers[i].text = i < buf.length ? buf[i] : '';
    }
    update();
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

    final deviceToken = await getAuthDeviceToken();
    var response = await authData.verifyOtp(
      email: email,
      otp: otp,
      deviceToken: deviceToken,
    );

    if (response.isSuccess) {
      // Save access token if exists
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

      if (isForgotPassword) {
        Get.offNamed(AppRoutes.resetPassword, arguments: {'email': email});
      } else {
        Shared.setValue(StorageKeys.step, Steps.homeApp);
        if (showActivationSuccess) {
          Get.offAll(
            SuccessScreen(
              title: 'تم تفعيل حسابك',
              message:
                  'تم التحقق من بريدك الإلكتروني وتفعيل حسابك. يمكنك الآن الدخول إلى التطبيق.',
              buttonText: 'الدخول إلى التطبيق',
              onButtonPressed: () => Get.offAllNamed(AppRoutes.app),
            ),
          );
        } else {
          Get.offAllNamed(AppRoutes.app);
        }
      }
    }

    isLoading = false;
    update();
  }

  @override
  void resendOtp() async {
    if (!canResend) return;

    isLoading = true;
    update();

    final String? resendPurpose = isForgotPassword
        ? 'password_reset'
        : (showActivationSuccess ? 'account_activation' : null);

    var response = await authData.forgotPassword(
      email: email,
      purpose: resendPurpose,
    );

    if (response.isSuccess) {
      customSnackBar(text: "تم إرسال رمز التحقق مرة أخرى");
      resendTimer = 60;
      canResend = false;
      startResendTimer();
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
