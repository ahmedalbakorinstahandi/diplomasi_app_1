import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;

class LessonInfoDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onStartLearning;
  final bool isLocked;
  final bool isLesson; // true for lesson, false for scenario

  const LessonInfoDialog({
    super.key,
    required this.title,
    required this.description,
    this.onStartLearning,
    this.isLocked = false,
    this.isLesson = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Determine background color based on type
    final backgroundColor = isLesson ? scheme.primary : scheme.secondary;
    final onBackgroundColor = isLesson ? scheme.onPrimary : scheme.onSecondary;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),

      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.12),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.only(
                top: height(24),
                left: width(20),
                right: width(20),
              ),
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: emp(20),
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),

            SizedBox(height: height(16)),

            // Description
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width(20)),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: description.isNotEmpty
                      ? html.Html(
                          data: description,
                          style: {
                            "body": html.Style(
                              margin: html.Margins.zero,
                              padding: html.HtmlPaddings.zero,
                              fontSize: html.FontSize(emp(16)),
                              color: scheme.onSurface,
                              lineHeight: html.LineHeight(1.5),
                            ),
                            "p": html.Style(
                              margin: html.Margins.only(bottom: 8),
                            ),
                          },
                        )
                      : Text(
                          description,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: emp(16),
                            fontWeight: FontWeight.w400,
                            color: scheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: height(24)),

            // Start Learning Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                left: width(20),
                right: width(20),
                bottom: height(20),
              ),
              height: height(48),
              decoration: BoxDecoration(
                color: isLocked
                    ? backgroundColor.withOpacity(0.4)
                    : backgroundColor, // Use lesson/scenario color
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: isLocked
                      ? null
                      : () {
                          Navigator.of(context).pop(); // Close dialog
                          onStartLearning
                              ?.call(); // Navigate to lesson/scenario
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ابدأ التعلم',
                          style: TextStyle(
                            fontSize: emp(16),
                            fontWeight: FontWeight.w600,
                            color: onBackgroundColor,
                          ),
                        ),
                        if (isLocked) ...[
                          SizedBox(width: width(8)),
                          MySvgIcon(
                            path: Assets.icons.svg.learnLock,
                            size: emp(16),
                            color: onBackgroundColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required String description,
    VoidCallback? onStartLearning,
    bool isLocked = false,
    bool isLesson = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      isDismissible: true,
      enableDrag: true,
      builder: (context) => LessonInfoDialog(
        title: title,
        description: description,
        onStartLearning: onStartLearning,
        isLocked: isLocked,
        isLesson: isLesson,
      ),
    );
  }
}
