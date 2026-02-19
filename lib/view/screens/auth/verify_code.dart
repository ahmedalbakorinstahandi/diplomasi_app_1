import 'package:diplomasi_app/controllers/auth/verify_code_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_title.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_subtitle.dart';
import 'package:diplomasi_app/view/widgets/auth/otp_input_field.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VerifyCodeControllerImp());
    return GetBuilder<VerifyCodeControllerImp>(
      builder: (controller) {
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          body: SafeArea(
            child: SizedBox(
              height: getHeight(),
              child: AuthBackground(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: controller.formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        // Back button and title
                        Row(
                          children: [
                            CustomBackButton(
                              color: scheme.primary,
                              isNormal: true,
                            ),
                            SizedBox(width: width(10)),
                            const AuthTitle(title: 'التحقق من الرمز'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        AuthSubtitle(
                          subtitle: controller.isForgotPassword
                              ? 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني لإعادة تعيين كلمة المرور'
                              : 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني لتفعيل حسابك',
                        ),
                        const SizedBox(height: 40),
                        // OTP Input fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            controller.otpLength,
                            (index) => OtpInputField(
                              controller: controller.otpControllers[index],
                              autoFocus: index == 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Verify button
                        CustomButton(
                          text: 'تحقق',
                          onPressed: controller.verifyOtp,
                          isLoading: controller.isLoading,
                          height: 56,
                          borderRadius: 12,
                        ),
                        const SizedBox(height: 24),
                        // Resend code
                        Center(
                          child: controller.canResend
                              ? TextButton(
                                  onPressed: controller.resendOtp,
                                  child: Text(
                                    'إعادة إرسال الرمز',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: scheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Text(
                                  'إعادة إرسال الرمز خلال ${controller.resendTimer} ثانية',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
