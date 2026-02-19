import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final String? iconPath;
  final Widget? suffixIcon;
  final bool enabled;

  const AuthInputField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textDirection,
    this.iconPath,
    this.suffixIcon,
    this.enabled = true,
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
            keyboardType: keyboardType,
            textDirection: textDirection ?? TextDirection.rtl,
            textAlign: TextAlign.right,
            enabled: enabled,
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
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              prefixIcon: iconPath != null
                  ? MySvgIcon(
                      path: iconPath!,
                      padding: 10,
                      color: colors.textMuted,
                    )
                  : null,
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

