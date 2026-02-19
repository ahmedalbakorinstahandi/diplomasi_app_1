import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/course_model.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isPreviousSelected;
  final bool isLast;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.isSelected = false,
    this.isPreviousSelected = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    // Determine border radius similar to lesson_card
    final borderRadius = 12.0;

    // Get status and progress (can be extended if CourseModel supports these)
    final status = 'open'; // Default status
    final isOpen = status == 'open';
    final progressPercentage =
        0.0; // Default progress, can be extended if CourseModel supports it

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        // Determine border color and width based on selection state
        Color borderColor;
        double borderWidth;
        if (isSelected) {
          // Current selected course - strong primary color
          borderColor = scheme.primary;
          borderWidth = 2;
        } else if (isPreviousSelected) {
          // Previous selected course - lighter/muted color
          borderColor = scheme.primary.withOpacity(0.4);
          borderWidth = 1.5;
        } else {
          // Not selected
          borderColor = colors.border;
          borderWidth = 1;
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(
                borderRadius + borderWidth * 2,
              ),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  // Content container
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Image
                      CachedNetworkImage(
                        imageUrl: course.imageUrl,
                        width: double.infinity,
                        height: height(140),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: height(140),
                          color: colors.backgroundSecondary,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: scheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: height(140),
                          color: colors.backgroundSecondary,
                          child: Icon(
                            Icons.image_not_supported,
                            color: colors.textMuted,
                            size: emp(40),
                          ),
                        ),
                      ),
                      // Course Title
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(width(12)),
                          child: Center(
                            child: Text(
                              course.title,
                              style: TextStyle(
                                fontSize: emp(16),
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
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
        );
      },
    );
  }
}
