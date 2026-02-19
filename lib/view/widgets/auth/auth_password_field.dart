import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPasswordField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.border,
                width: 1,
              ),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                color: colors.textMuted,
              ),
              prefixIcon: MySvgIcon(
                path: Assets.icons.svg.lock,
                padding: 10,
                color: colors.textMuted,
              ),
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: SvgPicture.asset(
                  obscureText ? Assets.icons.svg.eyeOff : Assets.icons.svg.eyeOn,
                  width: 24,
                  height: 24,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

