import 'package:diplomasi_app/controllers/auth/forgot_password_controller.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/classes/validator.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_title.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_subtitle.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_input_field.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ForgotPasswordControllerImp());
    return GetBuilder<ForgotPasswordControllerImp>(
      builder: (controller) {
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
                            const AuthTitle(title: 'نسيت كلمة المرور'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        const AuthSubtitle(
                          subtitle:
                              'أدخل بريدك الإلكتروني المسجل وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
                        ),
                        const SizedBox(height: 40),
                        // Email field
                        AuthInputField(
                          label: 'البريد الإلكتروني',
                          hintText: 'Example@gmail.com',
                          controller: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          iconPath: Assets.icons.svg.email,
                          validator: (value) => MyValidator.validate(
                            value,
                            type: ValidatorType.email,
                            fieldName: 'البريد الإلكتروني',
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Send button
                        CustomButton(
                          text: 'إرسال',
                          onPressed: controller.sendOtp,
                          isLoading: controller.isLoading,
                          height: 56,
                          borderRadius: 12,
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
