import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:flutter/material.dart';

class LevelDropdown extends StatelessWidget {
  final LevelModel? selectedLevel;
  final List levels;
  final Function(LevelModel)? onLevelSelected;

  const LevelDropdown({
    super.key,
    this.selectedLevel,
    required this.levels,
    this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        // horizontal: width(20),
        vertical: height(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width(12),
        vertical: height(12),
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: PopupMenuButton<LevelModel>(
        offset: Offset(0, height(50)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedLevel?.accessStatus == 'locked') ...[
                    MySvgIcon(
                      path: Assets.icons.svg.learnLock,
                      size: emp(15),
                      color: colors.textMuted,
                    ),
                    SizedBox(width: width(6)),
                  ] else if (selectedLevel?.accessStatus == 'completed') ...[
                    Icon(
                      Icons.check_circle,
                      size: emp(15),
                      color: scheme.primary,
                    ),
                    SizedBox(width: width(6)),
                  ],
                  Expanded(
                    child: Text(
                      selectedLevel?.title ?? 'اختر المستوى',
                      style: TextStyle(
                        fontSize: emp(15),
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width(8)),
            Icon(
              Icons.keyboard_arrow_down,
              color: colors.textMuted,
              size: emp(20),
            ),
          ],
        ),
        itemBuilder: (context) {
          return levels.map((t) {
            final level = LevelModel.fromJson(t);
            final isSelected = selectedLevel?.id == level.id;
            return PopupMenuItem<LevelModel>(
              value: level,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (level.accessStatus == 'locked') ...[
                          MySvgIcon(
                            path: Assets.icons.svg.learnLock,
                            size: emp(16),
                            color: colors.textMuted,
                          ),
                          SizedBox(width: width(6)),
                        ] else if (level.accessStatus == 'completed') ...[
                          Icon(
                            Icons.check_circle,
                            size: emp(16),
                            color: scheme.primary,
                          ),
                          SizedBox(width: width(6)),
                        ],
                        Expanded(
                          child: Text(
                            level.title,
                            style: TextStyle(
                              fontSize: emp(16),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: scheme.primary, size: emp(18)),
                ],
              ),
            );
          }).toList();
        },
        onSelected: (LevelModel level) {
          if (onLevelSelected != null) {
            onLevelSelected!(level);
          }
        },
      ),
    );
  }
}
