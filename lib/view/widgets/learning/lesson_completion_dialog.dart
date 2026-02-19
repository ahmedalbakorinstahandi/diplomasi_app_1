import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class LessonCompletionDialog extends StatelessWidget {
  final bool isLevelCompletion;
  final VoidCallback onNext;

  const LessonCompletionDialog({
    super.key,
    this.isLevelCompletion = false,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false, // Prevent back button from closing dialog
      onPopInvokedWithResult: (didPop, result) {
        // When back button is pressed, execute the same action as the button
        if (!didPop) {
          onNext(); // Execute the same action as the blue button
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
        padding: EdgeInsets.all(width(24)),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon
            Container(
              width: width(80),
              height: width(80),
              decoration: BoxDecoration(
                color: colors.highlight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: colors.highlight,
                size: emp(48),
              ),
            ),
            
            SizedBox(height: height(20)),
            
            // Title
            Text(
              isLevelCompletion ? 'تهانينا!' : 'عمل رائع!',
              style: TextStyle(
                fontSize: emp(24),
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            
            SizedBox(height: height(12)),
            
            // Message
            Text(
              isLevelCompletion
                  ? 'اجتزت المستوى بنجاح واستحققت التقدم.'
                  : 'أنجزت هذا الدرس بنجاح.',
              style: TextStyle(
                fontSize: emp(16),
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: height(24)),
            
            // Next button
            Container(
              width: double.infinity,
              height: height(48),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onNext,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      isLevelCompletion ? 'إلى المستوى التالي' : 'إلى الدرس التالي',
                      style: TextStyle(
                        fontSize: emp(16),
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

