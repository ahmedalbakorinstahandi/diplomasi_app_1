import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/widgets/auth/auth_background.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessScreen({
    super.key,
    this.title,
    this.message,
    this.buttonText = 'متابعة',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: getHeight() * 0.2),
                  // Success icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    title ?? 'تم بنجاح!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Message
                  Text(
                    message ?? 'تمت العملية بنجاح.',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Continue button
                  CustomButton(
                    text: buttonText,
                    onPressed:
                        onButtonPressed ??
                        () {
                          Get.offAllNamed(AppRoutes.login);
                        },
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
    );
  }
}
