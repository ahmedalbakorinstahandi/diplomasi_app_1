import 'package:diplomasi_app/controllers/auth/reset_password_controller.dart';
import 'package:diplomasi_app/core/classes/validator.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_title.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_subtitle.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_password_field.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ResetPasswordControllerImp());
    return GetBuilder<ResetPasswordControllerImp>(
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
                            const AuthTitle(title: 'إعادة تعيين كلمة المرور'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        const AuthSubtitle(
                          subtitle: 'أدخل كلمة المرور الجديدة',
                        ),
                        const SizedBox(height: 40),
                        // Password field
                        AuthPasswordField(
                          label: 'كلمة المرور الجديدة',
                          hintText: 'أدخل كلمة المرور الجديدة',
                          controller: controller.password,
                          obscureText: controller.obscurePassword,
                          onToggleVisibility: controller.togglePasswordVisibility,
                          validator: (value) => MyValidator.validate(
                            value,
                            type: ValidatorType.password,
                            fieldName: 'كلمة المرور',
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Confirm Password field
                        AuthPasswordField(
                          label: 'تأكيد كلمة المرور',
                          hintText: 'أدخل كلمة المرور مرة أخرى',
                          controller: controller.confirmPassword,
                          obscureText: controller.obscureConfirmPassword,
                          onToggleVisibility:
                              controller.toggleConfirmPasswordVisibility,
                          validator: (value) {
                            if (value != controller.password.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return MyValidator.validate(
                              value,
                              type: ValidatorType.password,
                              fieldName: 'تأكيد كلمة المرور',
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        // Reset button
                        CustomButton(
                          text: 'تغيير كلمة المرور',
                          onPressed: controller.resetPassword,
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

