class ScenarioQuestionOptionModel {
  final int id;
  final int questionId;
  final String optionText;
  final int? nextQuestionId; // السؤال التالي عند اختيار هذا الخيار
  final String? attachedPath;
  final int orderIndex;

  ScenarioQuestionOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    this.nextQuestionId,
    this.attachedPath,
    required this.orderIndex,
  });

  factory ScenarioQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return ScenarioQuestionOptionModel(
      id: json['id'] as int,
      questionId: json['question_id'] as int? ?? 0,
      optionText: json['option_text'] as String,
      nextQuestionId: json['next_question_id'] as int?,
      attachedPath: json['attached_path'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'next_question_id': nextQuestionId,
      'attached_path': attachedPath,
      'order_index': orderIndex,
    };
  }
}

