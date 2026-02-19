import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;
  final TextAlign? textAlign;

  const AuthLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: textAlign == TextAlign.center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              fontSize: 18,
              color: scheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

