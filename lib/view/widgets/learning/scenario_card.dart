import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/scenario_model.dart';
import 'package:flutter/material.dart';

class ScenarioCard extends StatelessWidget {
  final ScenarioModel scenario;
  final bool isLocked;
  final VoidCallback? onTap;
  final bool isRightAligned;
  final bool isLast;

  const ScenarioCard({
    super.key,
    required this.scenario,
    this.isLocked = false,
    this.onTap,
    this.isRightAligned = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    // Use status from model if available, otherwise fallback to isLocked parameter
    final status = scenario.status ?? (isLocked ? 'locked' : 'open');
    final scenarioIsLocked = isLocked || !scenario.isPublished;
    final scenarioIsCompleted = status == 'completed';
    final isOpen = status == 'open';
    final progressPercentage = scenario.progressPercentage ?? 0.0;
    final isActive = !scenarioIsLocked && scenario.isPublished;

    // Determine border radius: only bottom corners for last card, all corners for others
    final borderRadius = BorderRadius.circular(66);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth * 0.35; // 35% of screen width

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Horizontal line in the center
            Positioned(
              left: -width(14),
              right: -width(14),
              top: height(12) + height(16) + height(20), // Center position
              child: IgnorePointer(
                child: Container(height: height(2), color: colors.divider),
              ),
            ),
            // Card content
            Align(
              alignment: isRightAligned
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: GestureDetector(
                onTap: onTap, // Allow tap even if locked to show dialog
                child: Container(
                  width: cardWidth,
                  margin: EdgeInsets.symmetric(
                    vertical: height(12),
                    horizontal: width(16),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.secondary,
                        scheme.secondary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: isActive ? null : colors.borderStrong,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.secondary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, height(4)),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Stack(
                      children: [
                        // Content container
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width(16),
                            vertical: height(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon
                              _buildIcon(
                                context,
                                scenarioIsLocked,
                                scenarioIsCompleted,
                                isActive,
                              ),
                              SizedBox(width: width(12)),
                              // Scenario title
                              Expanded(
                                child: Text(
                                  scenario.title,
                                  style: TextStyle(
                                    fontSize: width(15),
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress overlay (for open/in-progress state)
                        if (isOpen &&
                            progressPercentage > 0 &&
                            progressPercentage < 100)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width:
                                    cardWidth * (1 - progressPercentage / 100),
                                decoration: BoxDecoration(
                                  color: scheme.onPrimary.withOpacity(0.25),
                                  borderRadius: isLast
                                      ? BorderRadius.only(
                                          bottomLeft: Radius.circular(66),
                                        )
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(66),
                                          bottomLeft: Radius.circular(66),
                                        ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIcon(
    BuildContext context,
    bool isLocked,
    bool isCompleted,
    bool isActive,
  ) {
    final scheme = Theme.of(context).colorScheme;
    if (isLocked) {
      // Locked state - show lock icon
      return Container(
        width: width(30),
        height: width(30),
        decoration: BoxDecoration(
          color: scheme.onSecondary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_outline,
          color: scheme.onSecondary,
          size: width(15),
        ),
      );
    } else if (isCompleted) {
      // Completed state - show checkmark icon
      return Container(
        width: width(30),
        height: width(30),
        decoration: BoxDecoration(
          color: scheme.onSecondary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          size: width(20),
          color: scheme.onSecondary,
        ),
      );
    } else {
      // Open state - show psychology icon
      return Container(
        width: width(30),
        height: width(30),
        decoration: BoxDecoration(
          color: scheme.onSecondary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.psychology_rounded,
          color: scheme.onSecondary,
          size: width(15),
        ),
      );
    }
  }
}
