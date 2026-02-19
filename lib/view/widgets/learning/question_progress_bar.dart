import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class QuestionProgressBar extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;
  final double progressPercentage;

  const QuestionProgressBar({
    super.key,
    required this.answeredCount,
    required this.totalQuestions,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width(16),
        vertical: height(12),
      ),
      child: Column(
        children: [
          // Question number and progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Next button placeholder
              SizedBox(width: width(40)),
            ],
          ),

          // Progress bar
          Row(
            children: List.generate(
              totalQuestions,
              (index) => Expanded(
                child: Container(
                  height: height(8),
                  margin: EdgeInsets.symmetric(horizontal: width(2)),
                  decoration: BoxDecoration(
                    color: index < answeredCount
                        ? colors.highlight
                        : scheme.onPrimary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height(8)),
        ],
      ),
    );
  }
}
