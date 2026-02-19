import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/localization/changelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? iconPath;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.iconPath,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textDirection,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        textAlign: ltr ? TextAlign.left : TextAlign.right,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        // textDirection: TextDirection.ltr,
        obscureText: widget.isPassword ? _obscureText : false,
        validator: widget.validator,
        onChanged: widget.onChanged,
        textDirection:
            widget.textDirection ??
            (ltr ? TextDirection.ltr : TextDirection.rtl),
        style: TextStyle(fontSize: 16, color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
          hintTextDirection:
              widget.textDirection ??
              (ltr ? TextDirection.ltr : TextDirection.rtl),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: widget.iconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    widget.iconPath!,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: SvgPicture.asset(
                    _obscureText
                        ? Assets.icons.svg.eyeOff
                        : Assets.icons.svg.eyeOn,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
