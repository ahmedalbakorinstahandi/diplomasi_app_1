import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:diplomasi_app/data/model/learning/level_track_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_model.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_card.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_info_dialog.dart';
import 'package:diplomasi_app/view/widgets/learning/scenario_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LevelTrackList extends StatelessWidget {
  final List tracks;
  final Function()? onTap;

  const LevelTrackList({super.key, required this.tracks, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Single counter for all items (lessons and scenarios) to alternate alignment
    int itemIndex = 0;

    // Filter valid tracks to determine last item
    final validTracks = tracks.where((t) {
      final track = LevelTrackModel.fromJson(t);
      final isLesson = track.trackableType.toLowerCase().contains('lesson');
      final isScenario = track.trackableType.toLowerCase().contains('scenario');
      return (isLesson && track.trackable is LessonModel) ||
          (isScenario && track.trackable is ScenarioModel);
    }).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cards
        Column(
          children: tracks.map((t) {
            final track = LevelTrackModel.fromJson(t);
            final isLesson = track.trackableType.toLowerCase().contains(
              'lesson',
            );
            final isScenario = track.trackableType.toLowerCase().contains(
              'scenario',
            );

            // Check if this is the last valid track
            final validIndex = validTracks.indexOf(t);
            final isLast = validIndex == validTracks.length - 1;

            // Calculate alignment based on overall item index
            final isRightAligned = itemIndex % 2 == 0;
            final cardCenterY = height(12) + height(16) + height(20);

            if (isLesson && track.trackable is LessonModel) {
              final lesson = track.trackable as LessonModel;
              // Use status from track if available, otherwise from lesson
              final status = track.status ?? 'open';
              final isLocked =
                  status == 'locked' || track.level?.accessStatus == 'locked';
              Widget card = Stack(
                clipBehavior: Clip.none,
                children: [
                  // Horizontal line segment for this card (centered)
                  Positioned(
                    left: -width(14),
                    right: -width(14),
                    top: cardCenterY,
                    child: IgnorePointer(
                      child: Container(
                        height: height(2),
                        color: colors.divider,
                      ),
                    ),
                  ),
                  LessonCard(
                    lesson: lesson,
                    isLocked: isLocked,
                    isCompleted: status == 'completed',
                    isRightAligned: isRightAligned,
                    isLast: isLast,
                    onTap: () {
                      // Show lesson info dialog first
                      LessonInfoDialog.show(
                        context: context,
                        title: lesson.title,
                        description: lesson.description,
                        isLocked: isLocked,
                        isLesson: true,
                        onStartLearning: isLocked
                            ? null
                            : () async {
                                await Get.toNamed(
                                  AppRoutes.lesson,
                                  parameters: {'id': lesson.id.toString()},
                                );
                                onTap?.call();
                              },
                      );
                    }, // Allow tap even if locked to show dialog
                  ),
                ],
              );

              itemIndex++;
              return card;
            } else if (isScenario && track.trackable is ScenarioModel) {
              final scenario = track.trackable as ScenarioModel;
              // Use status from track if available, otherwise from scenario
              final status = track.status;
              final isLocked =
                  status == 'locked' || track.level?.accessStatus == 'locked';

              Widget card = Stack(
                clipBehavior: Clip.none,
                children: [
                  // Horizontal line segment for this card (centered)
                  Positioned(
                    left: -width(14),
                    right: -width(14),
                    top: cardCenterY,
                    child: IgnorePointer(
                      child: Container(
                        height: height(2),
                        color: colors.divider,
                      ),
                    ),
                  ),
                  ScenarioCard(
                    scenario: scenario,
                    isLocked: isLocked,
                    isRightAligned: isRightAligned,
                    isLast: isLast,
                    onTap: () {
                      // Show scenario info dialog first
                      LessonInfoDialog.show(
                        context: context,
                        title: scenario.title,
                        description: scenario.description,
                        isLocked: isLocked,
                        isLesson: false,
                        onStartLearning: isLocked
                            ? null
                            : () async {
                                // Navigate to scenario questions screen
                                await Get.toNamed(
                                  AppRoutes.scenarioQuestions,
                                  parameters: {
                                    'scenario_id': scenario.id.toString(),
                                  },
                                );
                                onTap?.call();
                              },
                      );
                    }, // Allow tap even if locked to show dialog
                  ),
                ],
              );

              itemIndex++;
              return card;
            }

            return const SizedBox.shrink();
          }).toList(),
        ),
      ],
    );
  }
}
