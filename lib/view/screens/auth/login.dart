import 'package:diplomasi_app/controllers/auth/login_controller.dart';
import 'package:diplomasi_app/controllers/auth/register_controller.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/classes/validator.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
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
    return GetBuilder<LoginControllerImp>(
      init: LoginControllerImp(),
      global: false,
      builder: (controller) {
        // Shared.setValue(StorageKeys.step, Steps.homeApp);
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
                        const SizedBox(height: 120),

                        // Title with sparkle icon
                        Row(
                          children: [
                            // if account state is guest - show arrwa back button
                            if (Shared.getValue(StorageKeys.accountState) ==
                                'guest') ...[
                              CustomBackButton(
                                color: scheme.primary,
                                isNormal: false,
                              ),
                              SizedBox(width: width(10)),
                            ],

                            AuthTitle(
                              title: 'تسجيل الدخول',
                              icon:
                                  Shared.getValue(StorageKeys.accountState) !=
                                      'guest'
                                  ? Icons.star
                                  : null,
                            ),
                          ],
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
                        // Login button
                        CustomButton(
                          text: 'تسجيل الدخول',
                          onPressed: controller.login,
                          isLoading: controller.isLogin,
                          height: 56,
                          borderRadius: 12,
                        ),
                        // if account state is not guest
                        if (Shared.getValue(StorageKeys.accountState) !=
                            'guest') ...[
                          const SizedBox(height: 12),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: scheme.secondary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: scheme.secondary.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ابدأ فورًا بدون تسجيل',
                                  style: TextStyle(
                                    color: scheme.secondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'التطبيق بمتناولك الآن، والتسجيل متاح بأي وقت.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.isGuestLoading
                                        ? null
                                        : controller.continueAsGuest,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: scheme.secondary,
                                      foregroundColor: scheme.onSecondary,
                                      minimumSize: const Size(
                                        double.infinity,
                                        52,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: controller.isGuestLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'الدخول كضيف',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Sign up link
                        AuthLink(
                          text: 'ليس لديك حساب؟ ',
                          linkText: 'إنشاء حساب جديد',
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.register,
                              arguments: const {
                                registerOpenedFromLoginArg: true,
                              },
                            );
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
