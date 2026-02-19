import 'package:diplomasi_app/data/model/learning/scenario_question_option_model.dart';

class ScenarioAnswerModel {
  final int id;
  final int questionId;
  final int attemptId;
  final int stepIndex;
  final String answeredAt;
  final String? timeSpent;
  final List<ScenarioAnswerOption> answerOptions;

  ScenarioAnswerModel({
    required this.id,
    required this.questionId,
    required this.attemptId,
    required this.stepIndex,
    required this.answeredAt,
    this.timeSpent,
    required this.answerOptions,
  });

  factory ScenarioAnswerModel.fromJson(Map<String, dynamic> json) {
    return ScenarioAnswerModel(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      attemptId: json['attempt_id'] as int,
      stepIndex: json['step_index'] as int,
      answeredAt: json['answered_at'] as String,
      timeSpent: json['time_spent'] as String?,
      answerOptions: json['user_scenario_answer_options'] != null
          ? (json['user_scenario_answer_options'] as List<dynamic>)
                .map(
                  (e) => ScenarioAnswerOption.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'attempt_id': attemptId,
      'step_index': stepIndex,
      'answered_at': answeredAt,
      'time_spent': timeSpent,
      'user_scenario_answer_options':
          answerOptions.map((e) => e.toJson()).toList(),
    };
  }
}

class ScenarioAnswerOption {
  final int id;
  final int userAnswerId;
  final int optionId;
  final ScenarioQuestionOptionModel? scenarioQuestionOption;

  ScenarioAnswerOption({
    required this.id,
    required this.userAnswerId,
    required this.optionId,
    this.scenarioQuestionOption,
  });

  factory ScenarioAnswerOption.fromJson(Map<String, dynamic> json) {
    return ScenarioAnswerOption(
      id: json['id'] as int,
      userAnswerId: json['user_answer_id'] as int,
      optionId: json['option_id'] as int,
      scenarioQuestionOption: json['scenario_question_option'] != null
          ? ScenarioQuestionOptionModel.fromJson(
              json['scenario_question_option'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_answer_id': userAnswerId,
      'option_id': optionId,
      'scenario_question_option': scenarioQuestionOption?.toJson(),
    };
  }
}

