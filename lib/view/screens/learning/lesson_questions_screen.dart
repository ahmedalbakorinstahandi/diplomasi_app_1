import 'package:diplomasi_app/controllers/learning/lesson_questions_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/lesson_questions_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/learning/answer_feedback_dialog.dart';
import 'package:diplomasi_app/view/widgets/learning/lesson_completion_dialog.dart';
import 'package:diplomasi_app/view/widgets/learning/match_question.dart';
import 'package:diplomasi_app/view/widgets/learning/multiple_choice_question.dart';
import 'package:diplomasi_app/view/widgets/learning/question_progress_bar.dart';
import 'package:diplomasi_app/view/widgets/learning/single_choice_question.dart';
import 'package:diplomasi_app/view/widgets/learning/true_false_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LessonQuestionsScreen extends StatelessWidget {
  const LessonQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LessonQuestionsControllerImp());
    return GetBuilder<LessonQuestionsControllerImp>(
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
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
                  // Header with progress
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            width(15),
                            height(8),
                            width(15),
                            height(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Close button
                              CircleAvatar(
                                backgroundColor: scheme.onPrimary.withOpacity(
                                  0.15,
                                ),
                                radius: 16,
                                child: InkWell(
                                  onTap: () => Get.back(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),

                              // Question number
                              Text(
                                'سؤال ${controller.currentQuestionIndex + 1} من ${controller.totalQuestions}',
                                style: TextStyle(
                                  fontSize: emp(15),
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onPrimary,
                                ),
                              ),

                              // Next button (disabled for now)
                              SizedBox(width: width(40)),

                              // Close button
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: scheme.onPrimary,
                                ),
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        ),

                        // Progress bar
                        QuestionProgressBar(
                          answeredCount: controller.answeredCount,
                          totalQuestions: controller.totalQuestions,
                          progressPercentage: controller.progressPercentage,
                        ),
                      ],
                    ),
                  ),

                  // Questions content
                  Expanded(
                    child:
                        controller.isLoading ||
                            controller.currentQuestion == null
                        ? const LessonQuestionsScreenShimmer()
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              height(12),
                              0,
                              height(14),
                            ),
                            child: _buildQuestionWidget(context, controller),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionWidget(
    BuildContext context,
    LessonQuestionsControllerImp controller,
  ) {
    final question = controller.currentQuestion!;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    switch (question.type) {
      case 'single_choice':
        return SingleChoiceQuestion(
          key: ValueKey(question.id),
          question: question,
          onSubmit: (optionId) => _handleSubmit(controller, optionId: optionId),
        );

      case 'multiple_choice':
        return MultipleChoiceQuestion(
          key: ValueKey(question.id),
          question: question,
          onSubmit: (optionIds) =>
              _handleSubmit(controller, optionIds: optionIds),
        );

      case 'true_false':
        return TrueFalseQuestion(
          key: ValueKey(question.id),
          question: question,
          onSubmit: (optionId) => _handleSubmit(controller, optionId: optionId),
        );

      case 'match':
        return MatchQuestion(
          key: ValueKey(question.id),
          question: question,
          onSubmit: (matches) => _handleSubmit(controller, matches: matches),
        );

      default:
        return Container(
          padding: EdgeInsets.all(width(20)),
          child: Text(
            'نوع سؤال غير مدعوم: ${question.type}',
            style: TextStyle(fontSize: emp(16), color: colors.textSecondary),
          ),
        );
    }
  }

  Future<void> _handleSubmit(
    LessonQuestionsControllerImp controller, {
    int? optionId,
    List<int>? optionIds,
    List<Map<String, int>>? matches,
  }) async {
    // Submit answer and get result
    final result = await controller.submitAnswer(
      optionId: optionId,
      optionIds: optionIds,
      matches: matches,
    );

    // Check if we got a result
    if (result != null) {
      final isCorrect = result['is_correct'] as bool? ?? false;
      final explanation = result['explanation'] as String?;
      final attemptFinished = result['attempt_finished'] as bool? ?? false;
      final matchCorrectCount = result['correct_count'] as int?;
      final matchTotalCount = result['total_count'] as int?;

      // Show feedback dialog
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => AnswerFeedbackDialog(
            isCorrect: isCorrect,
            explanation: explanation,
            matchCorrectCount: matchCorrectCount,
            matchTotalCount: matchTotalCount,
            onNext: () {
              Navigator.of(context).pop(); // Close dialog

              if (attemptFinished) {
                // Show completion dialog
                showDialog(
                  context: Get.context!,
                  barrierDismissible: false,
                  builder: (context) => LessonCompletionDialog(
                    onNext: () {
                      Navigator.of(context).pop(); // Close completion dialog
                      // Go back to home screen without reloading
                      // Pop lesson questions screen, then pop lesson screen to get to home
                      Get.back(); // Go back from questions screen to lesson screen
                      Get.back(); // Go back from lesson screen to home screen
                    },
                  ),
                );
              } else {
                // Move to next question
                controller.moveToNextQuestion();
              }
            },
          ),
        );
      }
    }
  }
}
