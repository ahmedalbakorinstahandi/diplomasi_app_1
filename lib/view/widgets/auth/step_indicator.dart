import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int stepNumber;
  final Color? circleColor;
  final Color? borderColor;

  const StepIndicator({
    super.key,
    required this.stepNumber,
    this.circleColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor ?? scheme.primary,
        border: Border.all(
          color: borderColor ?? colors.highlight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

