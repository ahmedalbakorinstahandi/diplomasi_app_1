import 'package:diplomasi_app/controllers/learning/lesson_controller.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/lesson_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_complete_button.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel? lesson;

  const LessonScreen({super.key, this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final GlobalKey<LessonVideoPlayerState> _videoPlayerKey =
      GlobalKey<LessonVideoPlayerState>();

  @override
  Widget build(BuildContext context) {
    Get.put(LessonControllerImp());
    return GetBuilder<LessonControllerImp>(
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
        final currentLesson = widget.lesson ?? controller.lesson;

        if (currentLesson == null) {
          return MyScaffold(body: const LessonScreenShimmer());
        }

        return MyScaffold(
          body: Stack(
            children: [
              // Background pattern
              if (!isDarkMode)
                Positioned.fill(
                  child: SvgPicture.asset(
                    Assets.pictures.svg.pattern1,
                    fit: BoxFit.cover,
                  ),
                ),

              // Content
              Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + height(16),
                      left: width(16),
                      right: width(16),
                      bottom: height(16),
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
                          onPressed: () => Get.back(),
                        ),

                        SizedBox(width: width(12)),

                        // Lesson title
                        Expanded(
                          child: Text(
                            currentLesson.title,
                            style: TextStyle(
                              fontSize: emp(18),
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(width: width(12)),

                        // // Book icon
                        // Container(
                        //   width: width(40),
                        //   height: width(40),
                        //   decoration: BoxDecoration(
                        //     color: scheme.onPrimary.withOpacity(0.2),
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: Center(
                        //     child: MySvgIcon(
                        //       path: Assets.icons.svg.book,
                        //       size: emp(20),
                        //       color: scheme.onPrimary,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Video player
                  SizedBox(height: height(20)),
                  LessonVideoPlayer(
                    key: _videoPlayerKey,
                    videoUrl: currentLesson.videoUrl,
                  ),

                  SizedBox(height: height(20)),

                  // Content (scrollable when long)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: width(16)),
                      child: Text(
                        currentLesson.content,
                        style: TextStyle(fontSize: emp(16)),
                      ),
                    ),
                  ),

                  // Complete button
                  LessonCompleteButton(
                    isLoading: controller.isLoadingAttempt,
                    onTap: () async {
                      // Pause video if playing
                      _videoPlayerKey.currentState?.pause();

                      // Start or resume attempt first
                      await controller.startOrResumeAttempt();
                      if (controller.attempt != null) {
                        // Mark video as watched
                        await controller.markVideoWatched();
                        // Navigate to questions
                        Get.toNamed(
                          AppRoutes.lessonQuestions,
                          parameters: {
                            'lesson_id': currentLesson.id.toString(),
                            'attempt_id': controller.attempt!.id.toString(),
                          },
                        );
                      }
                    },
                  ),
                  // SizedBox(height: height(10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
