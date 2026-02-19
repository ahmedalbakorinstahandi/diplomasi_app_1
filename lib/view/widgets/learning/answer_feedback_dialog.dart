import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class AnswerFeedbackDialog extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;
  final String? correctAnswer;
  final VoidCallback onNext;

  const AnswerFeedbackDialog({
    super.key,
    required this.isCorrect,
    this.explanation,
    this.correctAnswer,
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
          onNext(); // Execute the same action as the "التالي" button
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
        padding: EdgeInsets.all(width(20)),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: width(60),
              height: width(60),
              decoration: BoxDecoration(
                color: isCorrect
                    ? colors.success.withOpacity(0.12)
                    : scheme.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? colors.success : scheme.error,
                size: emp(32),
              ),
            ),

            SizedBox(height: height(16)),

            // Message
            Text(
              isCorrect
                  ? 'إجابتك صحيحة، استمر..'
                  : 'لم تصب هذه المرة، استمر بالمحاولة!',
              style: TextStyle(
                fontSize: emp(16),
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            if (correctAnswer != null && !isCorrect) ...[
              SizedBox(height: height(12)),
              Text(
                'الإجابة الصحيحة هي: $correctAnswer',
                style: TextStyle(
                  fontSize: emp(14),
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (explanation != null && explanation!.isNotEmpty) ...[
              SizedBox(height: height(12)),
              Text(
                explanation!,
                style: TextStyle(
                  fontSize: emp(14),
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

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
                      'التالي',
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

