import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class ScenariosData {
  ApiService apiService = Get.find();

  /// Get scenario details
  Future<ApiResponse> show(int scenarioId) async {
    return await apiService.get(
      EndPoints.scenario,
      pathVariables: {'id': scenarioId.toString()},
    );
  }

  /// Start or resume a scenario attempt
  Future<ApiResponse> startAttempt(int scenarioId) async {
    return await apiService.post(
      EndPoints.scenarioStartAttempt,
      pathVariables: {'id': scenarioId.toString()},
    );
  }

  /// Get current question with full details
  Future<ApiResponse> getCurrentQuestion({
    required int scenarioId,
    required int attemptId,
  }) async {
    return await apiService.get(
      EndPoints.scenarioCurrentQuestion,
      pathVariables: {
        'id': scenarioId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Get attempts history for one scenario
  Future<ApiResponse> getAttempts({required int scenarioId}) async {
    return await apiService.get(
      EndPoints.scenarioAttempts,
      pathVariables: {'id': scenarioId.toString()},
    );
  }

  /// Get full journey payload for one scenario attempt
  Future<ApiResponse> getAttemptJourney({
    required int scenarioId,
    required int attemptId,
  }) async {
    return await apiService.get(
      EndPoints.scenarioAttemptJourney,
      pathVariables: {
        'id': scenarioId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Submit answer for a question
  Future<ApiResponse> submitAnswer({
    required int attemptId,
    required int questionId,
    required int optionId,
  }) async {
    Map<String, dynamic> body = {
      'attempt_id': attemptId,
      'question_id': questionId,
      'option_id': optionId,
    };

    return await apiService.post(
      EndPoints.scenarioSubmitAnswer,
      data: body,
    );
  }

  /// Finish the attempt
  Future<ApiResponse> finishAttempt({
    required int scenarioId,
    required int attemptId,
  }) async {
    return await apiService.post(
      EndPoints.scenarioFinishAttempt,
      pathVariables: {
        'id': scenarioId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }

  /// Mark description as read
  Future<ApiResponse> markDescriptionRead({
    required int scenarioId,
    required int attemptId,
  }) async {
    return await apiService.post(
      EndPoints.scenarioMarkDescriptionRead,
      pathVariables: {
        'id': scenarioId.toString(),
        'attemptId': attemptId.toString(),
      },
    );
  }
}

