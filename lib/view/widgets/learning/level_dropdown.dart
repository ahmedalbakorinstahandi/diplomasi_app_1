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
      margin: EdgeInsets.only(bottom: height(4)),
      padding: EdgeInsets.symmetric(
        horizontal: width(12),
        vertical: height(10),
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: PopupMenuButton<LevelModel>(
        padding: EdgeInsets.zero,
        splashRadius: 22,
        offset: Offset(0, height(44)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: emp(15),
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width(6)),
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
