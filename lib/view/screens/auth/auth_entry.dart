import 'package:diplomasi_app/controllers/auth/auth_entry_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthEntryControllerImp());

    return GetBuilder<AuthEntryControllerImp>(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 120),
                      Text(
                        'مرحبًا بك',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'اختر الطريقة المناسبة للمتابعة',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomButton(
                        text: 'تسجيل الدخول',
                        onPressed: controller.goToLogin,
                        height: 56,
                        borderRadius: 12,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: controller.goToRegister,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: BorderSide(color: scheme.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ),
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
                              'جرّب بدون حساب',
                              style: TextStyle(
                                color: scheme.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'يمكنك البدء الآن ثم إنشاء حساب لاحقًا.',
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
                                  minimumSize: const Size(double.infinity, 52),
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
                                        'الاستمرار كزائر',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
