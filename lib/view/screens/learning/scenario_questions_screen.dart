import 'package:diplomasi_app/controllers/learning/scenario_questions_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/scenario_questions_screen_shimmer.dart';
import 'package:diplomasi_app/data/model/learning/lesson_answer_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_option_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_question_model.dart';
import 'package:diplomasi_app/view/widgets/learning/scenario_completion_dialog.dart';
import 'package:diplomasi_app/view/widgets/learning/scenario_description_view.dart';
import 'package:diplomasi_app/view/widgets/learning/scenario_explanation_dialog.dart';
import 'package:diplomasi_app/view/widgets/learning/single_choice_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ScenarioQuestionsScreen extends StatelessWidget {
  const ScenarioQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ScenarioQuestionsControllerImp());
    return GetBuilder<ScenarioQuestionsControllerImp>(
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
                  // Header
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
                              // Back button
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

                              // Title
                              SizedBox(
                                width: width(250),
                                child: Text(
                                  controller.scenario?.title ?? 'السيناريو',
                                  style: TextStyle(
                                    fontSize: emp(15),
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // // Toggle button (show description/questions)
                              // if (controller.scenario != null &&
                              //     !controller.showDescription)
                              //   IconButton(
                              //     icon: Icon(
                              //       Icons.info_outline,
                              //       size: 24,
                              //       color: scheme.onPrimary,
                              //     ),
                              //     onPressed: () => controller.toggleView(),
                              //     tooltip: 'عرض الوصف',
                              //   ),

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

                        SizedBox(height: height(8)),
                      ],
                    ),
                  ),

                  // Content (Description or Questions)
                  Expanded(child: _buildContent(context, controller)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScenarioQuestionsControllerImp controller,
  ) {
    // Determine what to show based on question readiness
    // Priority: If question is ready (loaded and not loading), show questions/shimmer
    // Otherwise, if showDescription is true, show description

    final hasQuestionReady =
        (controller.currentQuestion != null || controller.scenarioFinished) &&
        !controller.isLoadingQuestion &&
        !controller.isLoading;

    // Show description only if we don't have a ready question AND showDescription is true
    final shouldShowDescription =
        !hasQuestionReady && controller.showDescription;

    if (shouldShowDescription) {
      if (controller.isLoadingScenario || controller.scenario == null) {
        return const ScenarioDescriptionShimmer();
      }

      return ScenarioDescriptionView(
        scenario: controller.scenario!,
        isLoading: controller.isLoading || controller.isLoadingQuestion,
        onShowAttempts: controller.scenario!.hasPreviousAttempts
            ? () {
                Get.toNamed(
                  AppRoutes.scenarioAttempts,
                  parameters: {
                    'scenario_id': controller.scenario!.id.toString(),
                  },
                );
              }
            : null,
        onContinue: () async {
          // Start attempt first
          await controller.startAttempt();
          if (controller.attemptId != null) {
            // Load first question first - showDescription will be set to false inside getCurrentQuestion
            await controller.getCurrentQuestion();
            // Then mark description as read (this may trigger update, but showDescription is already false)
            await controller.markDescriptionRead();
          }
        },
      );
    }

    // Show questions or shimmer
    // If we're loading or don't have a question yet, show shimmer
    if (controller.isLoading ||
        controller.isLoadingQuestion ||
        (controller.currentQuestion == null && !controller.scenarioFinished)) {
      return const ScenarioQuestionShimmer();
    }

    if (controller.scenarioFinished) {
      return _buildFinishedView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        0,
        height(12),
        0,
        height(14),
      ),
      child: _buildQuestionWidget(context, controller),
    );
  }

  Widget _buildFinishedView() {
    final ctx = Get.context;
    final colors = (ctx != null)
        ? Theme.of(ctx).extension<AppColors>() ?? AppColors.light
        : AppColors.light;
    final scheme = (ctx != null)
        ? Theme.of(ctx).colorScheme
        : const ColorScheme.light();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: width(80), color: colors.success),
          SizedBox(height: height(24)),
          Text(
            'تم إكمال السيناريو بنجاح!',
            style: TextStyle(
              fontSize: emp(20),
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: height(32)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width(16)),
            width: double.infinity,
            height: height(48),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    'العودة',
                    style: TextStyle(
                      fontSize: emp(16),
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
    BuildContext context,
    ScenarioQuestionsControllerImp controller,
  ) {
    final question = controller.currentQuestion!;
    // السيناريو يعتمد على المسارات؛ كل الأنواع تُعرض كخيارات انتقال.
    return _buildScenarioSingleChoice(question, controller);
  }

  Widget _buildScenarioSingleChoice(
    ScenarioQuestionModel question,
    ScenarioQuestionsControllerImp controller,
  ) {
    // Convert ScenarioQuestionModel to LessonQuestionModel format for reuse
    return SingleChoiceQuestion(
      question: _convertToLessonQuestion(question),
      onSubmit: (optionId) => _handleSubmit(controller, optionId: optionId),
      showInstruction: false,
    );
  }

  // Helper to convert ScenarioQuestionModel to LessonQuestionModel
  LessonQuestionModel _convertToLessonQuestion(
    ScenarioQuestionModel scenarioQuestion,
  ) {
    // Convert options
    final lessonOptions = scenarioQuestion.options.map((opt) {
      return LessonQuestionOptionModel(
        id: opt.id,
        questionId: opt.questionId,
        optionText: opt.optionText,
        isCorrect: null, // Scenarios don't have correct answers
        attachedPath: opt.attachedPath,
        orderIndex: opt.orderIndex,
      );
    }).toList();

    // Convert answer if exists
    LessonAnswerModel? lessonAnswer;
    if (scenarioQuestion.answer != null) {
      final answerOptions = scenarioQuestion.answer!.answerOptions
          .map(
            (ao) => AnswerOption(
              optionId: ao.optionId,
              isCorrect: false, // Scenarios don't have correct answers
            ),
          )
          .toList();

      lessonAnswer = LessonAnswerModel(
        isCorrect: false,
        score: 0.0,
        answeredAt: scenarioQuestion.answer!.answeredAt,
        options: answerOptions,
      );
    }

    return LessonQuestionModel(
      id: scenarioQuestion.id,
      lessonId: scenarioQuestion.scenarioId,
      type: scenarioQuestion.type,
      questionText: scenarioQuestion.questionText,
      attachedPath: scenarioQuestion.attachedPath,
      explanation: scenarioQuestion.explanation,
      score: 0.0,
      orderIndex: scenarioQuestion.orderIndex,
      options: lessonOptions,
      status: scenarioQuestion.answered ? 'answered' : 'not_answered',
      userAnswer: lessonAnswer,
    );
  }

  Future<void> _handleSubmit(
    ScenarioQuestionsControllerImp controller, {
    required int optionId,
  }) async {
    final localOptionFeedback = controller.currentQuestion?.options
        .firstWhereOrNull((option) => option.id == optionId)
        ?.feedbackText;

    // Submit answer and get result
    final result = await controller.submitAnswer(optionId: optionId);

    // Check if we got a result
    if (result != null) {
      final finished = result['finished'] as bool? ?? false;
      final feedbackText = result['feedback_text'] as String?;
      final explanation = result['explanation'] as String?;
      final message = (feedbackText != null && feedbackText.isNotEmpty)
          ? feedbackText
          : ((localOptionFeedback != null && localOptionFeedback.isNotEmpty)
                ? localOptionFeedback
                : explanation);

      // Show feedback/explanation dialog if there's a message
      if (message != null && message.isNotEmpty) {
        if (Get.context != null) {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (context) => ScenarioExplanationDialog(
              explanation: message,
              onNext: () {
                Navigator.of(context).pop(); // Close dialog

                if (finished) {
                  // Show completion dialog
                  showDialog(
                    context: Get.context!,
                    barrierDismissible: false,
                    builder: (context) => ScenarioCompletionDialog(
                      onNext: () {
                        Navigator.of(context).pop(); // Close completion dialog
                        // Go back to home screen without reloading
                        Get.back(); // Go back to home screen
                      },
                    ),
                  );
                } else {
                  // Load next question
                  controller.getCurrentQuestion();
                }
              },
            ),
          );
        }
      } else {
        // No explanation, just move to next question or finish
        if (finished) {
          if (Get.context != null) {
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (context) => ScenarioCompletionDialog(
                onNext: () {
                  Navigator.of(context).pop(); // Close completion dialog
                  // Go back to home screen without reloading
                  Get.back(); // Go back to home screen
                },
              ),
            );
          }
        } else {
          // Load next question
          controller.getCurrentQuestion();
        }
      }
    }
  }
}
