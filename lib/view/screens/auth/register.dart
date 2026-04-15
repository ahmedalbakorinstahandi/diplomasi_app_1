import 'package:diplomasi_app/controllers/auth/register_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/classes/validator.dart';
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

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterControllerImp>(
      init: RegisterControllerImp(),
      global: false,
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

                        // Title with sparkle icon
                        Row(
                          children: [
                            CustomBackButton(
                              color: scheme.primary,
                              isNormal: true,
                            ),
                            SizedBox(width: width(10)),
                            const AuthTitle(title: 'إنشاء حساب'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        const AuthSubtitle(
                          subtitle: 'أنشئ حسابك لتبدأ رحلتك معنا',
                        ),
                        const SizedBox(height: 40),
                        // Full Name field
                        Row(
                          children: [
                            Expanded(
                              child: AuthInputField(
                                label: 'الاسم',
                                hintText: 'أدخل الاسم الاول',
                                controller: controller.firstName,
                                iconPath: Assets.icons.svg.person,
                                validator: (value) => MyValidator.validate(
                                  value,
                                  type: ValidatorType.text,
                                  fieldName: 'الاسم الاول',
                                ),
                              ),
                            ),
                            SizedBox(width: width(16)),
                            Expanded(
                              child: AuthInputField(
                                label: '',
                                hintText: 'أدخل الاسم الثاني',
                                controller: controller.lastName,
                                iconPath: Assets.icons.svg.person,
                                validator: (value) => MyValidator.validate(
                                  value,
                                  type: ValidatorType.text,
                                  fieldName: 'الاسم الثاني',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                            fieldName: 'البريد الإلكتروني',
                          ),
                        ),
                        //const SizedBox(height: 24),
                        // Phone field
                        // AuthInputField(
                        //   label: 'رقم الهاتف',
                        //   hintText: 'أدخل رقم الهاتف',
                        //   controller: controller.phone,
                        //   keyboardType: TextInputType.phone,
                        //   textDirection: TextDirection.ltr,
                        //   iconPath: Assets.icons.svg.phone,
                        // validator: (value) => MyValidator.validate(
                        //   value,
                        //   type: ValidatorType.phone,
                        //   fieldName: 'رقم الهاتف',
                        // ),
                        //  ),
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
                        const SizedBox(height: 24),
                        // Confirm Password field
                        AuthPasswordField(
                          label: 'تأكيد كلمة المرور',
                          hintText: 'أدخل كلمة المرور',
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
                              fieldName: 'confirm_password',
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        // Continue button
                        CustomButton(
                          text: 'إنشاء',
                          onPressed: controller.register,
                          isLoading: controller.isRegister,
                          height: 56,
                          borderRadius: 12,
                        ),
                        const SizedBox(height: 24),
                        // Login link
                        AuthLink(
                          text: 'لديك حساب بالفعل؟ ',
                          linkText: 'تسجيل الدخول',
                          onTap: controller.navigateToLoginOrBack,
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
