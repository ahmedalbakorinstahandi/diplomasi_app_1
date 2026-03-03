import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class LessonCompleteButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const LessonCompleteButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width(16), vertical: height(0)),
      width: double.infinity,
      height: height(56),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: width(24),
                    height: width(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'إتمام الدرس',
                    style: TextStyle(
                      fontSize: emp(16),
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
