import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/data/model/learning/scenario_answer_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_question_model.dart';
import 'package:diplomasi_app/data/resource/remote/learning/scenarios_data.dart';
import 'package:get/get.dart';

abstract class ScenarioQuestionsController extends GetxController {
  bool isLoading = false;
  bool isLoadingQuestion = false;
  bool isSubmittingAnswer = false;
  bool isLoadingScenario = false;

  ScenariosData scenariosData = ScenariosData();

  int? scenarioId;
  int? attemptId;
  ScenarioModel? scenario;
  ScenarioQuestionModel? currentQuestion;
  int stepIndex = 0;
  bool scenarioFinished = false;
  bool showDescription = true; // Show description first, then questions

  Future<void> getScenarioDetails();
  Future<void> startAttempt();
  Future<void> getCurrentQuestion();
  Future<Map<String, dynamic>?> submitAnswer({required int optionId});
  Future<void> finishAttempt();
  Future<void> markDescriptionRead();
  void toggleView(); // Toggle between description and questions
}

class ScenarioQuestionsControllerImp extends ScenarioQuestionsController {
  @override
  void onInit() {
    printDebug('Get.parameters: ${Get.parameters}');

    scenarioId = int.tryParse(Get.parameters['scenario_id'] ?? '');
    attemptId = int.tryParse(Get.parameters['attempt_id'] ?? '');

    print('scenarioId: $scenarioId');
    print('attemptId: $attemptId');

    if (scenarioId == null) {
      Get.back();
      return;
    }

    getScenarioDetails();
    super.onInit();
  }

  @override
  Future<void> getScenarioDetails() async {
    if (isLoadingScenario || scenarioId == null) return;

    isLoadingScenario = true;
    update();

    try {
      ApiResponse response = await scenariosData.show(scenarioId!);

      if (response.isSuccess && response.data != null) {
        scenario = ScenarioModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (e) {
      print('Error loading scenario details: $e');
    } finally {
      isLoadingScenario = false;
      update();
    }
  }

  @override
  void toggleView() {
    showDescription = !showDescription;
    update();
  }

  @override
  Future<void> startAttempt() async {
    if (isLoading || scenarioId == null) return;

    isLoading = true;
    update();

    try {
      ApiResponse response = await scenariosData.startAttempt(scenarioId!);

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        attemptId = data['id'] as int? ?? attemptId;

        // Get current question after starting attempt (only if not showing description)
        if (!showDescription) {
          await getCurrentQuestion();
        }
      }
    } catch (e) {
      print('Error starting attempt: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  Future<void> getCurrentQuestion() async {
    if (isLoadingQuestion || scenarioId == null || attemptId == null) return;

    isLoadingQuestion = true;
    update();

    try {
      ApiResponse response = await scenariosData.getCurrentQuestion(
        scenarioId: scenarioId!,
        attemptId: attemptId!,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Check if scenario is finished
        if (data['finished'] == true) {
          scenarioFinished = true;
          currentQuestion = null;
        } else if (data['question'] != null) {
          currentQuestion = ScenarioQuestionModel.fromJson(
            data['question'] as Map<String, dynamic>,
          );

          // Update answered status
          if (data['answered'] == true && data['answer'] != null) {
            currentQuestion = ScenarioQuestionModel(
              id: currentQuestion!.id,
              scenarioId: currentQuestion!.scenarioId,
              code: currentQuestion!.code,
              type: currentQuestion!.type,
              questionText: currentQuestion!.questionText,
              attachedPath: currentQuestion!.attachedPath,
              explanation: currentQuestion!.explanation,
              orderIndex: currentQuestion!.orderIndex,
              options: currentQuestion!.options,
              answered: true,
              answer: ScenarioAnswerModel.fromJson(
                data['answer'] as Map<String, dynamic>,
              ),
            );
          }

          // Update step index from answer if exists
          if (currentQuestion!.answer != null) {
            stepIndex = currentQuestion!.answer!.stepIndex;
          }
        }
      }
    } catch (e) {
      print('Error loading current question: $e');
    } finally {
      isLoadingQuestion = false;
      // If we're showing description and question is loaded, toggle to questions
      // Do this in finally to ensure it happens before update()
      if (showDescription && (currentQuestion != null || scenarioFinished)) {
        showDescription = false;
      }
      update();
    }
  }

  @override
  Future<Map<String, dynamic>?> submitAnswer({required int optionId}) async {
    if (isSubmittingAnswer || currentQuestion == null || attemptId == null) {
      return null;
    }

    isSubmittingAnswer = true;
    update();

    try {
      ApiResponse response = await scenariosData.submitAnswer(
        attemptId: attemptId!,
        questionId: currentQuestion!.id,
        optionId: optionId,
      );

      Map<String, dynamic>? result;

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        final nextQuestionId = data['next_question_id'] as int?;
        scenarioFinished = data['finished'] as bool? ?? false;

        // Prepare result data for UI
        result = {
          'next_question_id': nextQuestionId,
          'finished': scenarioFinished,
          'explanation': data['explanation'] as String?,
          'answer': data['answer'],
        };

        // Don't load next question here - it will be loaded when user clicks "التالي" in explanation dialog
        // This prevents double loading of the next question
      }

      return result;
    } catch (e) {
      print('Error submitting answer: $e');
      return null;
    } finally {
      isSubmittingAnswer = false;
      update();
    }
  }

  @override
  Future<void> finishAttempt() async {
    if (scenarioId == null || attemptId == null) return;

    ApiResponse response = await scenariosData.finishAttempt(
      scenarioId: scenarioId!,
      attemptId: attemptId!,
    );

    if (response.isSuccess && response.data != null) {
      scenarioFinished = true;
      update();
    }
  }

  @override
  Future<void> markDescriptionRead() async {
    if (scenarioId == null || attemptId == null) return;

    try {
      ApiResponse response = await scenariosData.markDescriptionRead(
        scenarioId: scenarioId!,
        attemptId: attemptId!,
      );

      if (response.isSuccess && response.data != null) {
        // Refresh scenario details to get updated progress
        await getScenarioDetails();
        update();
      }
    } catch (e) {
      // Handle error silently or show message
      print('Error marking description as read: $e');
    }
  }
}
