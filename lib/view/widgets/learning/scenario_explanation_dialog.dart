import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class ScenarioExplanationDialog extends StatelessWidget {
  final String? explanation;
  final VoidCallback onNext;

  const ScenarioExplanationDialog({
    super.key,
    this.explanation,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
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
                color: scheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                color: scheme.primary,
                size: emp(32),
              ),
            ),

            SizedBox(height: height(16)),

            // Explanation
            if (explanation != null && explanation!.isNotEmpty) ...[
              Text(
                explanation!,
                style: TextStyle(fontSize: emp(16), color: scheme.onSurface),
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
