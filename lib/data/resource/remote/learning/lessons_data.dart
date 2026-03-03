import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class LessonsData {
  ApiService apiService = Get.find();

  // show lesson details
  Future<ApiResponse> show(int lessonId) async {
    return await apiService.get(
      EndPoints.lesson,
      pathVariables: {'id': lessonId.toString()},
    );
  }

  /// Start or resume a lesson attempt
  Future<ApiResponse> startAttempt(int lessonId) async {
    return await apiService.post(
      EndPoints.lessonStartAttempt,
      pathVariables: {'id': lessonId.toString()},
    );
  }

  /// Get all questions for a lesson with their status
  Future<ApiResponse> getQuestions({
    required int lessonId,
    int? attemptId,
  }) async {
    return await apiService.get(
      EndPoints.lessonQuestions,
      pathVariables: {'id': lessonId.toString()},
      params: attemptId != null ? {'attempt_id': attemptId.toString()} : null,
    );
  }

  /// Get current question with full details
  Future<ApiResponse> getCurrentQuestion({
    required int lessonId,
    required int attemptId,
  }) async {
    return await apiService.get(
      EndPoints.lessonCurrentQuestion,
      pathVariables: {
        'id': lessonId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Get attempts history for a lesson
  Future<ApiResponse> getAttempts({required int lessonId}) async {
    return await apiService.get(
      EndPoints.lessonAttempts,
      pathVariables: {'id': lessonId.toString()},
    );
  }

  /// Get full review payload for one attempt
  Future<ApiResponse> getAttemptReview({
    required int lessonId,
    required int attemptId,
  }) async {
    return await apiService.get(
      EndPoints.lessonAttemptReview,
      pathVariables: {
        'id': lessonId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Submit answer for a question
  Future<ApiResponse> submitAnswer({
    required int lessonId,
    required int attemptId,
    required int questionId,
    int? optionId, // For single_choice and true_false
    List<int>? optionIds, // For multiple_choice
    List<Map<String, int>>? matches, // For match questions
  }) async {
    Map<String, dynamic> body = {'question_id': questionId};

    if (optionId != null) {
      body['option_id'] = optionId;
    } else if (optionIds != null) {
      body['option_ids'] = optionIds;
    } else if (matches != null) {
      body['matches'] = matches;
    }

    return await apiService.post(
      EndPoints.lessonSubmitAnswer,
      pathVariables: {
        'id': lessonId.toString(),
        'attemptId': attemptId.toString(),
      },
      data: body,
    );
  }

  /// Finish the attempt
  Future<ApiResponse> finishAttempt({
    required int lessonId,
    required int attemptId,
  }) async {
    return await apiService.post(
      EndPoints.lessonFinishAttempt,
      pathVariables: {
        'id': lessonId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Mark video as watched
  Future<ApiResponse> markVideoWatched({
    required int lessonId,
    required int attemptId,
  }) async {
    return await apiService.post(
      EndPoints.lessonMarkVideoWatched,
      pathVariables: {
        'id': lessonId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }
}
