import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final LevelModel level;
  final bool isSelected;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          // horizontal: width(16),
          vertical: height(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width(16),
          vertical: height(16),
        ),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? scheme.primary : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Level number badge
            Container(
              width: width(50),
              height: width(50),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : colors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  level.levelNumber.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: emp(18),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? scheme.onPrimary : colors.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(width: width(16)),
            // Level title
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(width: width(12)),
                  if (level.accessStatus == 'locked') ...[
                    MySvgIcon(
                      path: Assets.icons.svg.learnLock,
                      size: emp(20),
                      color: colors.textMuted,
                    ),
                    SizedBox(width: width(8)),
                  ] else if (level.accessStatus == 'completed') ...[
                    Icon(
                      Icons.check_circle,
                      size: emp(20),
                      color: scheme.primary,
                    ),
                    SizedBox(width: width(8)),
                  ],
                ],
              ),
            ),
            // Arrow icon (pointing left)
            Icon(
              Icons.arrow_forward_ios,
              size: emp(22),
              color: isSelected ? scheme.primary : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
