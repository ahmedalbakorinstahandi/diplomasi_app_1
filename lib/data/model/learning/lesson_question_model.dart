import 'package:diplomasi_app/data/model/learning/lesson_question_option_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_answer_model.dart';

class LessonQuestionModel {
  final int id;
  final int lessonId;
  final String
  type; // 'single_choice' | 'multiple_choice' | 'true_false' | 'match'
  final String questionText;
  final String? attachedPath;
  final String? explanation;
  final double score;
  final int orderIndex;
  final List<LessonQuestionOptionModel> options;
  final String? status; // 'not_answered' | 'answered' | 'current'
  final LessonAnswerModel? userAnswer;

  LessonQuestionModel({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.questionText,
    this.attachedPath,
    this.explanation,
    required this.score,
    required this.orderIndex,
    required this.options,
    this.status,
    this.userAnswer,
  });

  factory LessonQuestionModel.fromJson(Map<String, dynamic> json) {
    return LessonQuestionModel(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int? ?? 0,
      type: json['type'] as String,
      questionText: json['question_text'] as String,
      attachedPath: json['attached_path'] as String?,
      explanation: json['explanation'] as String?,
      score: json['score'] == null
          ? 0.0
          : (json['score'] is String
                ? double.parse(json['score'] as String)
                : (json['score'] as num).toDouble()),
      orderIndex: json['order_index'] as int,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>)
                .map(
                  (e) => LessonQuestionOptionModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      status: json['status'] as String?,
      userAnswer: json['user_answer'] != null
          ? LessonAnswerModel.fromJson(
              json['user_answer'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'type': type,
      'question_text': questionText,
      'attached_path': attachedPath,
      'explanation': explanation,
      'score': score,
      'order_index': orderIndex,
      'options': options.map((e) => e.toJson()).toList(),
      'status': status,
      'user_answer': userAnswer?.toJson(),
    };
  }
}
