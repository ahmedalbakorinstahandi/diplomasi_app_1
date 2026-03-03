import 'package:diplomasi_app/data/model/learning/scenario_question_option_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_answer_model.dart';

class ScenarioQuestionModel {
  final int id;
  final int scenarioId;
  final String code;
  final String type; // 'single_choice'
  final String questionText;
  final String? attachedPath;
  final String? explanation;
  final int orderIndex;
  final List<ScenarioQuestionOptionModel> options;
  final bool answered;
  final ScenarioAnswerModel? answer;

  ScenarioQuestionModel({
    required this.id,
    required this.scenarioId,
    required this.code,
    required this.type,
    required this.questionText,
    this.attachedPath,
    this.explanation,
    required this.orderIndex,
    required this.options,
    this.answered = false,
    this.answer,
  });

  factory ScenarioQuestionModel.fromJson(Map<String, dynamic> json) {
    return ScenarioQuestionModel(
      id: json['id'] as int,
      scenarioId: json['scenario_id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      type: json['type'] as String,
      questionText: json['question_text'] as String,
      attachedPath: json['attached_path'] as String?,
      explanation: json['explanation'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      options: json['scenario_question_options'] != null
          ? (json['scenario_question_options'] as List<dynamic>)
                .map(
                  (e) => ScenarioQuestionOptionModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      answered: json['answered'] as bool? ?? false,
      answer: json['answer'] != null
          ? ScenarioAnswerModel.fromJson(json['answer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'code': code,
      'type': type,
      'question_text': questionText,
      'attached_path': attachedPath,
      'explanation': explanation,
      'order_index': orderIndex,
      'scenario_question_options': options.map((e) => e.toJson()).toList(),
      'answered': answered,
      'answer': answer?.toJson(),
    };
  }
}
