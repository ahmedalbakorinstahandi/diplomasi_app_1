import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final double progressPercentage;

  const ProgressIndicatorWidget({
    super.key,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height(12)),
      padding: EdgeInsets.symmetric(
        horizontal: width(16),
        vertical: height(20),
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with star icon
          Row(
            children: [
              MySvgIcon(
                path: Assets.icons.svg.badge,
                size: emp(24),
                color: scheme.primary,
              ),
              SizedBox(width: width(8)),
              Text(
                'نسبة إنجازك',
                style: TextStyle(
                  fontSize: emp(16),
                  fontWeight: FontWeight.w600,
                  height: 19 / 16.0178,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: height(12)),
          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedLessons درس من $totalLessons',
                style: TextStyle(
                  fontSize: emp(16),
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${progressPercentage.isFinite ? progressPercentage.toInt() : 0}%',
                style: TextStyle(
                  fontSize: emp(16),
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: height(16)),
          // Progress bar with dots
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final barHeight = height(13);
              final dotSize = width(3.5);
              // Calculate spacing so that first and last dots have half-spacing from edges
              final dotSpacing = totalLessons > 1
                  ? (barWidth - dotSize) / totalLessons
                  : 0.0;

              return SizedBox(
                height: barHeight,
                child: Stack(
                  children: [
                    // Background bar
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                    ),
                    // Progress fill
                    FractionallySizedBox(
                      widthFactor: progressPercentage.isFinite
                          ? progressPercentage / 100
                          : 0,
                      child: Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(5.5),
                        ),
                      ),
                    ),
                    // Dots positioned on the bar (with half-spacing at edges)
                    ...List.generate(totalLessons, (index) {
                      final isCompleted = index < completedLessons;
                      return Positioned(
                        left: (dotSpacing / 2) + (index * dotSpacing),
                        top: (barHeight - dotSize) / 2,
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            color: isCompleted ? scheme.primary : colors.border,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
