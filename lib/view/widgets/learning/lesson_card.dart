import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;
  final bool isRightAligned;
  final bool isLast;

  const LessonCard({
    super.key,
    required this.lesson,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
    this.isRightAligned = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Use status from model if available, otherwise fallback to isLocked parameter
    final status = lesson.status ?? (isLocked ? 'locked' : 'open');
    final lessonIsLocked = isLocked;
    final lessonIsCompleted = status == 'completed' || isCompleted;
    final isOpen = status == 'open';
    final progressPercentage = lesson.progressPercentage ?? 0.0;
    final isActive = !lessonIsLocked;

    // Determine border radius: only bottom corners for last card, all corners for others
    final borderRadius = BorderRadius.circular(66);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth * 0.45; // 35% of screen width

        return Align(
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
                color: scheme.primary.withOpacity(lessonIsLocked ? 0.7 : 1),
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.3),
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
                            lessonIsLocked,
                            lessonIsCompleted,
                            isActive,
                          ),

                          SizedBox(width: width(12)),
                          // Lesson title
                          Expanded(
                            child: Text(
                              lesson.title.length > 30
                                  ? '${lesson.title.substring(0, 30)}...'
                                  : lesson.title,
                              style: TextStyle(
                                fontSize: width(15),
                                fontWeight: FontWeight.w600,
                                color: scheme.onPrimary,
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
                            width: cardWidth * (1 - progressPercentage / 100),
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
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    if (isLocked) {
      // Locked state - show lock icon
      return Container(
        width: width(30),
        height: width(30),
        decoration: BoxDecoration(
          color: isActive ? scheme.onPrimary.withOpacity(0.2) : colors.border,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: MySvgIcon(
            path: Assets.icons.svg.learnLock,
            size: width(15),
            color: isActive ? scheme.onPrimary : colors.textSecondary,
          ),
        ),
      );
    } else if (isCompleted) {
      // Completed state - show checkmark icon
      return Container(
        width: width(30),
        height: width(30),
        decoration: BoxDecoration(
          color: scheme.onPrimary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          size: width(20),
          color: scheme.onPrimary,
        ),
      );
    } else {
      // Open state - show play icon
      return MySvgIcon(
        path: Assets.icons.svg.play,
        size: width(30),
        color: scheme.onPrimary,
      );
    }
  }
}
