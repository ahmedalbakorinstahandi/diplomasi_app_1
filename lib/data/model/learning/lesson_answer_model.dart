class LessonAnswerModel {
  final bool isCorrect;
  final double score;
  final String answeredAt;
  final List<AnswerOption>?
  options; // For single_choice, multiple_choice, true_false
  final List<AnswerMatch>? matches; // For match questions

  LessonAnswerModel({
    required this.isCorrect,
    required this.score,
    required this.answeredAt,
    this.options,
    this.matches,
  });

  factory LessonAnswerModel.fromJson(Map<String, dynamic> json) {
    return LessonAnswerModel(
      isCorrect: json['is_correct'] as bool,
      score: json['score'] == null
          ? 0.0
          : (json['score'] is String
                ? double.parse(json['score'] as String)
                : (json['score'] as num).toDouble()),
      answeredAt: json['answered_at'] as String,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>)
                .map((e) => AnswerOption.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      matches: json['matches'] != null
          ? (json['matches'] as List<dynamic>)
                .map((e) => AnswerMatch.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_correct': isCorrect,
      'score': score,
      'answered_at': answeredAt,
      'options': options?.map((e) => e.toJson()).toList(),
      'matches': matches?.map((e) => e.toJson()).toList(),
    };
  }
}

class AnswerOption {
  final int optionId;
  final bool isCorrect;

  AnswerOption({required this.optionId, required this.isCorrect});

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      optionId: json['option_id'] as int,
      isCorrect: json['is_correct'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'option_id': optionId, 'is_correct': isCorrect};
  }
}

class AnswerMatch {
  final int leftOptionId;
  final int rightOptionId;
  final bool isCorrect;

  AnswerMatch({
    required this.leftOptionId,
    required this.rightOptionId,
    required this.isCorrect,
  });

  factory AnswerMatch.fromJson(Map<String, dynamic> json) {
    return AnswerMatch(
      leftOptionId: json['left_option_id'] as int,
      rightOptionId: json['right_option_id'] as int,
      isCorrect: json['is_correct'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left_option_id': leftOptionId,
      'right_option_id': rightOptionId,
      'is_correct': isCorrect,
    };
  }
}
