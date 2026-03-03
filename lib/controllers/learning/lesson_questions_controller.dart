import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/data/resource/remote/learning/lessons_data.dart';
import 'package:get/get.dart';

abstract class LessonQuestionsController extends GetxController {
  bool isLoading = false;
  bool isLoadingQuestion = false;
  bool isSubmittingAnswer = false;

  LessonsData lessonsData = LessonsData();

  int? lessonId;
  int? attemptId;
  List<LessonQuestionModel> questions = [];
  LessonQuestionModel? currentQuestion;
  int currentQuestionIndex = 0;
  int answeredCount = 0;
  int totalQuestions = 0;
  double progressPercentage = 0.0;
  bool attemptFinished = false;

  Future<void> getQuestions();
  Future<void> getCurrentQuestion();
  Future<Map<String, dynamic>?> submitAnswer({
    int? optionId,
    List<int>? optionIds,
    List<Map<String, int>>? matches,
  });
  Future<void> finishAttempt();
  void moveToNextQuestion();
  void updateProgress();
}

class LessonQuestionsControllerImp extends LessonQuestionsController {
  @override
  void onInit() {
    printDebug('Get.parameters: ${Get.parameters}');

    lessonId = int.tryParse(Get.parameters['lesson_id'] ?? '');
    attemptId = int.tryParse(Get.parameters['attempt_id'] ?? '');

    print('lessonId: $lessonId');
    print('attemptId: $attemptId');

    // if (lessonId == null || attemptId == null) {
    //   Get.back();
    //   return;
    // }

    getQuestions();
    super.onInit();
  }

  @override
  Future<void> getQuestions() async {
    if (isLoading || lessonId == null) return;

    isLoading = true;
    update();

    ApiResponse response = await lessonsData.getQuestions(
      lessonId: lessonId!,
      attemptId: attemptId,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;

      if (data['questions'] != null) {
        questions = (data['questions'] as List<dynamic>)
            .map((e) => LessonQuestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['progress'] != null) {
        final progress = data['progress'] as Map<String, dynamic>;
        answeredCount = progress['answered'] as int? ?? 0;
        totalQuestions = progress['total'] as int? ?? 0;
        progressPercentage =
            (progress['percentage'] as num?)?.toDouble() ?? 0.0;
      }

      // Get current question
      await getCurrentQuestion();
    }

    isLoading = false;
    update();
  }

  @override
  Future<void> getCurrentQuestion() async {
    if (isLoadingQuestion || lessonId == null || attemptId == null) return;

    isLoadingQuestion = true;
    update();

    ApiResponse response = await lessonsData.getCurrentQuestion(
      lessonId: lessonId!,
      attemptId: attemptId!,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['question'] != null) {
        currentQuestion = LessonQuestionModel.fromJson(
          data['question'] as Map<String, dynamic>,
        );

        // Find current question index
        currentQuestionIndex = questions.indexWhere(
          (q) => q.id == currentQuestion!.id,
        );
        if (currentQuestionIndex == -1) {
          currentQuestionIndex = 0;
        }
      }
    }

    isLoadingQuestion = false;
    update();
  }

  @override
  Future<Map<String, dynamic>?> submitAnswer({
    int? optionId,
    List<int>? optionIds,
    List<Map<String, int>>? matches,
  }) async {
    if (isSubmittingAnswer ||
        currentQuestion == null ||
        lessonId == null ||
        attemptId == null) {
      return null;
    }

    isSubmittingAnswer = true;
    update();

    ApiResponse response = await lessonsData.submitAnswer(
      lessonId: lessonId!,
      attemptId: attemptId!,
      questionId: currentQuestion!.id,
      optionId: optionId,
      optionIds: optionIds,
      matches: matches,
    );

    Map<String, dynamic>? result;

    if (response.isSuccess && response.data != null) {
      final data = response.data as Map<String, dynamic>;

      attemptFinished = data['attempt_finished'] as bool? ?? false;

      // Update progress
      answeredCount++;
      updateProgress();

      // Refresh current question to get updated data with answer
      await getCurrentQuestion();

      // Prepare result data for UI (include match counts for match questions)
      result = {
        'is_correct': data['is_correct'] as bool? ?? false,
        'score': data['score'],
        'explanation': data['explanation'] as String?,
        'next_question_id': data['next_question_id'],
        'attempt_finished': attemptFinished,
        if (data['correct_count'] != null) 'correct_count': (data['correct_count'] as num).toInt(),
        if (data['total_count'] != null) 'total_count': (data['total_count'] as num).toInt(),
      };
    }

    isSubmittingAnswer = false;
    update();

    return result;
  }

  @override
  Future<void> finishAttempt() async {
    if (lessonId == null || attemptId == null) return;

    ApiResponse response = await lessonsData.finishAttempt(
      lessonId: lessonId!,
      attemptId: attemptId!,
    );

    if (response.isSuccess && response.data != null) {
      attemptFinished = true;
      update();
    }
  }

  @override
  void moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      getCurrentQuestion();
    }
  }

  @override
  void updateProgress() {
    if (totalQuestions > 0) {
      progressPercentage = (answeredCount / totalQuestions) * 100;
    }
    update();
  }
}
