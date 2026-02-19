import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:diplomasi_app/view/widgets/learning/level_card.dart';
import 'package:flutter/material.dart';

class LevelsList extends StatelessWidget {
  final List<LevelModel> levels;
  final int? selectedLevelId;
  final Function(LevelModel)? onLevelTap;

  const LevelsList({
    super.key,
    required this.levels,
    this.selectedLevelId,
    this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: height(20)),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isSelected = selectedLevelId == level.id;

        return LevelCard(
          level: level,
          isSelected: isSelected,
          onTap: onLevelTap != null ? () => onLevelTap!(level) : null,
        );
      },
    );
  }
}

