import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class AnswerFeedbackDialog extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;
  final String? correctAnswer;

  /// For match questions: number of correct pairs (e.g. 3 من 5).
  final int? matchCorrectCount;
  final int? matchTotalCount;
  final VoidCallback onNext;

  const AnswerFeedbackDialog({
    super.key,
    required this.isCorrect,
    this.explanation,
    this.correctAnswer,
    this.matchCorrectCount,
    this.matchTotalCount,
    required this.onNext,
  });

  /// Match feedback: full correct, partial, or wrong.
  bool get _isMatchFeedback =>
      matchCorrectCount != null &&
      matchTotalCount != null &&
      matchTotalCount! > 0;

  bool get _isMatchFullCorrect =>
      _isMatchFeedback && matchCorrectCount == matchTotalCount;

  bool get _isMatchPartial =>
      _isMatchFeedback &&
      matchCorrectCount! > 0 &&
      matchCorrectCount! < matchTotalCount!;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    // For match: icon and color by outcome
    final bool showPartial = _isMatchPartial;
    final bool showError = !isCorrect && !_isMatchPartial;

    Color iconBgColor = showError
        ? scheme.error.withOpacity(0.12)
        : (showPartial
              ? colors.warning.withOpacity(0.12)
              : colors.success.withOpacity(0.12));
    Color iconColor = showError
        ? scheme.error
        : (showPartial ? colors.warning : colors.success);
    IconData iconData = showError
        ? Icons.cancel
        : (showPartial ? Icons.warning_amber_rounded : Icons.check_circle);

    String message;
    if (_isMatchFeedback) {
      final c = matchCorrectCount!;
      final t = matchTotalCount!;
      if (_isMatchFullCorrect) {
        message = 'إجابتك صحيحة — $t من $t إجابات صحيحة';
      } else if (_isMatchPartial) {
        message = '$c إجابات صحيحة من $t';
      } else {
        message = '0 إجابات صحيحة من $t';
      }
    } else {
      message = isCorrect ? 'إجابتك صحيحة' : 'لم تصب هذه المرة';
    }

    return PopScope(
      canPop: false, // Prevent back button from closing dialog
      onPopInvokedWithResult: (didPop, result) {
        // When back button is pressed, execute the same action as the button
        if (!didPop) {
          onNext(); // Execute the same action as the "التالي" button
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: emp(32)),
              ),

              SizedBox(height: height(16)),

              // Message
              Text(
                message,
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
