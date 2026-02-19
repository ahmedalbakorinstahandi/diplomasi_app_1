import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class EditProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final String? iconPath;
  const EditProfileTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      style: TextStyle(
        fontSize: emp(16),
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),

      decoration: InputDecoration(
        prefixIcon: iconPath != null
            ? MySvgIcon(path: iconPath!, padding: 12, color: colors.textMuted)
            : null,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: height(12),
          horizontal: width(0),
        ),
      ),
      validator: validator,
    );
  }
}
