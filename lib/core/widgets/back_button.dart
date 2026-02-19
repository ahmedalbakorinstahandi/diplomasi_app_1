import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final bool isNormal;
  const CustomBackButton({super.key, this.color, this.isNormal = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final resolvedColor = color ?? scheme.onSurface;
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Container(
        padding: isNormal ? null : EdgeInsets.all(8),
        decoration: isNormal
            ? null
            : BoxDecoration(
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: resolvedColor,
        ),
      ),
    );
  }
}
