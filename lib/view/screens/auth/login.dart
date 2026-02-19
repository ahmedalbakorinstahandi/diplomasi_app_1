import 'package:diplomasi_app/controllers/auth/login_controller.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/classes/validator.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_title.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_subtitle.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_input_field.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_password_field.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_link.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginControllerImp());
    return GetBuilder<LoginControllerImp>(
      builder: (controller) {
        // Shared.setValue(StorageKeys.step, Steps.homeApp);
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        printDebug(Shared.getValue(StorageKeys.step));
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
                        const SizedBox(height: 120),
                        // Title with sparkle icon
                        const AuthTitle(
                          title: 'تسجيل الدخول',
                          icon: Icons.star,
                        ),
                        const SizedBox(height: 12),
                        // Welcome message
                        const AuthSubtitle(
                          subtitle:
                              'سعداء بعودتك! قم بتسجيل الدخول لإكمال رحلتك معنا.',
                        ),
                        const SizedBox(height: 40),
                        // Email field
                        AuthInputField(
                          label: 'البريد الالكتروني',
                          hintText: 'Example@gmail.com',
                          controller: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          iconPath: Assets.icons.svg.email,
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: colors.textMuted,
                            size: 24,
                          ),
                          validator: (value) => MyValidator.validate(
                            value,
                            type: ValidatorType.email,
                            fieldName: 'email',
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Password field
                        AuthPasswordField(
                          label: 'كلمة المرور',
                          hintText: 'أدخل كلمة المرور',
                          controller: controller.password,
                          obscureText: controller.obscurePassword,
                          onToggleVisibility:
                              controller.togglePasswordVisibility,
                          validator: (value) => MyValidator.validate(
                            value,
                            type: ValidatorType.password,
                            fieldName: 'password',
                          ),
                        ),
                        // Forgot password link
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: scheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Login button
                        CustomButton(
                          text: 'تسجيل الدخول',
                          onPressed: controller.login,
                          isLoading: controller.isLogin,
                          height: 56,
                          borderRadius: 12,
                        ),
                        const SizedBox(height: 24),
                        // Sign up link
                        AuthLink(
                          text: 'ليس لديك حساب؟ ',
                          linkText: 'إنشاء حساب جديد',
                          onTap: () {
                            Get.toNamed(AppRoutes.register);
                          },
                          textAlign: TextAlign.center,
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
