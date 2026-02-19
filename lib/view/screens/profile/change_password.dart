import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/controllers/profile/change_password_controller.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_password_field.dart';
import 'package:diplomasi_app/view/widgets/profile/edit_profile_save_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangePasswordControllerImp());
    final scheme = Theme.of(context).colorScheme;

    return MyScaffold(
      body: GetBuilder<ChangePasswordControllerImp>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Form(
              key: controller.formState,
              child: Column(
                children: [
                  // Header
                  Container(
                    width: getWidth(),
                    height: height(190),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + height(20),
                      left: width(20),
                      right: width(20),
                      bottom: height(30),
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.onPrimary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: width(12)),
                        Text(
                          'تعديل كلمة المرور',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: emp(20),
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width(14)),
                    child: Column(
                      children: [
                        SizedBox(height: height(24)),
                        // Current Password
                        EditProfilePasswordField(
                          label: 'كلمة المرور الحالية',
                          hintText: 'أدخل كلمة المرور الحالية',
                          controller: controller.currentPasswordController,
                          obscureText: controller.obscureCurrentPassword,
                          onToggleVisibility:
                              controller.toggleCurrentPasswordVisibility,
                          validator: controller.validateCurrentPassword,
                        ),
                        // New Password
                        EditProfilePasswordField(
                          label: 'كلمة المرور الجديدة',
                          hintText: 'أدخل كلمة المرور الجديدة',
                          controller: controller.newPasswordController,
                          obscureText: controller.obscureNewPassword,
                          onToggleVisibility:
                              controller.toggleNewPasswordVisibility,
                          validator: controller.validateNewPassword,
                          requirements: [
                            // 'على الأقل 8 محارف',
                            // 'يجب أن تحتوي على رمز, أحرف كبيرة, أحرف صغيرة',
                          ],
                        ),
                        // Confirm Password
                        EditProfilePasswordField(
                          label: 'تأكيد كلمة المرور الجديدة',
                          hintText: 'أدخل كلمة المرور مرة أخرى',
                          controller: controller.confirmPasswordController,
                          obscureText: controller.obscureConfirmPassword,
                          onToggleVisibility:
                              controller.toggleConfirmPasswordVisibility,
                          validator: controller.validateConfirmPassword,
                        ),
                        SizedBox(height: height(32)),
                        // Save Button
                        EditProfileSaveButton(
                          isLoading: controller.isLoading,
                          onPressed: controller.changePassword,
                        ),
                        SizedBox(height: height(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
