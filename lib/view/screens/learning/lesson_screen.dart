import 'package:diplomasi_app/controllers/learning/lesson_controller.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/lesson_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_complete_button.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_completion_dialog.dart';
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
  bool _isVideoFullScreen = false;
  bool _scriptExpanded = false;

  @override
  void didUpdateWidget(covariant LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLesson = oldWidget.lesson;
    final newLesson = widget.lesson;
    if (oldLesson?.id != newLesson?.id) {
      _scriptExpanded = false;
    }
  }

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
                  // Header — يُخفى عند ملء شاشة الفيديو
                  if (!_isVideoFullScreen)
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
                            icon: Icon(
                              Icons.arrow_back,
                              color: scheme.onPrimary,
                            ),
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
                        ],
                      ),
                    ),

                  // Video player — عند ملء الشاشة يأخذ كامل المساحة
                  SizedBox(height: height(20)),
                  if (_isVideoFullScreen)
                    Expanded(
                      child: LessonVideoPlayer(
                        key: _videoPlayerKey,
                        videoUrl: currentLesson.videoUrl,
                        onFullScreenChange: (isFullScreen) {
                          setState(() {
                            _isVideoFullScreen = isFullScreen;
                          });
                        },
                      ),
                    )
                  else
                    LessonVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: currentLesson.videoUrl,
                      onFullScreenChange: (isFullScreen) {
                        setState(() {
                          _isVideoFullScreen = isFullScreen;
                        });
                      },
                    ),

                  SizedBox(height: height(20)),

                  // Content (script) — سطران مع عرض المزيد/أقل
                  if (!_isVideoFullScreen)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: width(16)),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final content = currentLesson.content;
                            if (content.trim().isEmpty) {
                              return const SizedBox.shrink();
                            }
                            const maxLinesCollapsed = 4;
                            final textStyle = TextStyle(
                              fontSize: emp(16),
                              height: 1.4,
                            );
                            final textPainter = TextPainter(
                              text: TextSpan(text: content, style: textStyle),
                              maxLines: maxLinesCollapsed,
                              textDirection: TextDirection.rtl,
                            )..layout(maxWidth: constraints.maxWidth);
                            final needsToggle = textPainter.didExceedMaxLines;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  content,
                                  style: textStyle,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  maxLines: _scriptExpanded
                                      ? null
                                      : maxLinesCollapsed,
                                  overflow: _scriptExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                ),
                                if (needsToggle) ...[
                                  SizedBox(height: height(6)),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _scriptExpanded = !_scriptExpanded;
                                      });
                                    },
                                    child: Text(
                                      _scriptExpanded
                                          ? 'عرض أقل'
                                          : 'عرض المزيد',
                                      style: TextStyle(
                                        fontSize: emp(14),
                                        fontWeight: FontWeight.w600,
                                        color: scheme.primary,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                  if (!_isVideoFullScreen &&
                      currentLesson.hasPreviousAttempts) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width(16),
                        vertical: height(12),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: height(44),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.lessonAttempts,
                              parameters: {
                                'lesson_id': currentLesson.id.toString(),
                              },
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('عرض الإجابات السابقة'),
                        ),
                      ),
                    ),
                    // SizedBox(height: height(10)),
                  ],

                  // Complete button — يُخفى عند ملء شاشة الفيديو
                  if (!_isVideoFullScreen)
                    LessonCompleteButton(
                      isLoading: controller.isLoadingAttempt,
                      onTap: () async {
                        // Pause video if playing
                        _videoPlayerKey.currentState?.pause();

                        // Start or resume attempt first
                        await controller.startOrResumeAttempt();
                        if (controller.attempt == null) return;

                        // درس بلا أسئلة: الباكند يُرجع محاولة منتهية بنسبة 100٪
                        if (controller.attempt!.status == 'finished') {
                          await controller.getLessonDetails();
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => LessonCompletionDialog(
                              onNext: () {
                                Navigator.of(dialogContext).pop();
                                Get.back();
                              },
                            ),
                          );
                          return;
                        }

                        await controller.markVideoWatched();
                        Get.toNamed(
                          AppRoutes.lessonQuestions,
                          parameters: {
                            'lesson_id': currentLesson.id.toString(),
                            'attempt_id': controller.attempt!.id.toString(),
                          },
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
