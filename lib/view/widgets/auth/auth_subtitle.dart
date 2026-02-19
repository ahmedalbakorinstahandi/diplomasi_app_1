import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthSubtitle extends StatelessWidget {
  final String subtitle;

  const AuthSubtitle({
    super.key,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
    );
  }
}

