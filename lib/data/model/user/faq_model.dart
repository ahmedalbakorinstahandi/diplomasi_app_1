class FaqModel {
  final int id;
  final String question;
  final String answer;
  final String createdAt;
  final String updatedAt;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
