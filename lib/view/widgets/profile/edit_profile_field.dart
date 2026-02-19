import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class EditProfileField extends StatelessWidget {
  final String label;
  final String? iconPath;
  final Widget? child;
  final Widget? suffixIcon;
  final String? value;

  const EditProfileField({
    super.key,
    required this.label,
    this.iconPath,
    this.child,
    this.suffixIcon,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
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
          // Field Container
          Row(
            children: [
              // Value or Child
              Expanded(
                child:
                    child ??
                    Text(
                      value ?? '',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: emp(16),
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurface,
                      ),
                    ),
              ),
              // Suffix Icon (on the left)
              if (suffixIcon != null) ...[
                SizedBox(width: width(12)),
                suffixIcon!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
