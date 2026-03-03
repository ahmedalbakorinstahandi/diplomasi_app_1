import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class EditProfilePasswordField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final List<String>? requirements;

  const EditProfilePasswordField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: height(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: emp(18),
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: height(12)),
          // Field Container
          Row(
            children: [
              // Eye Icon (on the left)
              IconButton(
                onPressed: onToggleVisibility,
                icon: MySvgIcon(
                  path: obscureText
                      ? Assets.icons.svg.eyeOff
                      : Assets.icons.svg.eyeOn,
                  size: emp(20),
                  color: colors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: width(12)),
              // Text Field
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  textAlign: TextAlign.right,
                  validator: validator,
                  style: TextStyle(
                    fontSize: emp(16),
                    fontWeight: FontWeight.w400,
                    color: scheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: emp(14),
                      color: colors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: width(12)),
              // Lock Icon (on the right)
              MySvgIcon(
                path: Assets.icons.svg.lock,
                size: emp(20),
                color: colors.textMuted,
              ),
            ],
          ),
          // Requirements
          if (requirements != null && requirements!.isNotEmpty) ...[
            SizedBox(height: height(8)),
            ...requirements!.map(
              (req) => Padding(
                padding: EdgeInsets.only(bottom: height(4)),
                child: Text(
                  req,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: emp(12), color: scheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
