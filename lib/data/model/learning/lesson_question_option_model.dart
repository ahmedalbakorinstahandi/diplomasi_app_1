class LessonQuestionOptionModel {
  final int id;
  final int questionId;
  final String optionText;
  final String? pairKey; // For match questions
  final bool? isCorrect; // null for match questions
  final String? attachedPath;
  final int orderIndex;

  LessonQuestionOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    this.pairKey,
    this.isCorrect,
    this.attachedPath,
    required this.orderIndex,
  });

  factory LessonQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return LessonQuestionOptionModel(
      id: json['id'] as int,
      questionId: json['question_id'] as int? ?? 0,
      optionText: json['option_text'] as String,
      pairKey: json['pair_key'] as String?,
      isCorrect: json['is_correct'] == null
          ? null
          : (json['is_correct'] as num).toInt() == 1,
      attachedPath: json['attached_path'] as String?,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'pair_key': pairKey,
      'is_correct': isCorrect == null ? null : (isCorrect! ? 1 : 0),
      'attached_path': attachedPath,
      'order_index': orderIndex,
    };
  }
}

