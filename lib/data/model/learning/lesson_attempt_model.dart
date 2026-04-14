class LessonAttemptModel {
  final int id;
  final int? attemptNumber;
  final int userId;
  final int lessonId;
  final String status; // 'in_progress' | 'finished'
  final double score;
  final int? currentQuestionId;
  final String startedAt;
  final String? finishedAt;
  final int? totalTime;
  final ProgressInfo? progress;

  LessonAttemptModel({
    required this.id,
    this.attemptNumber,
    required this.userId,
    required this.lessonId,
    required this.status,
    required this.score,
    this.currentQuestionId,
    required this.startedAt,
    this.finishedAt,
    this.totalTime,
    this.progress,
  });

  factory LessonAttemptModel.fromJson(Map<String, dynamic> json) {
    return LessonAttemptModel(
      id: json['id'] as int,
      attemptNumber: json['attempt_number'] as int?,
      userId: json['user_id'] as int,
      lessonId: json['lesson_id'] as int,
      status: json['status'] as String,
      score: json['score'] is String 
          ? double.parse(json['score'] as String)
          : (json['score'] as num).toDouble(),
      currentQuestionId: json['current_question_id'] as int?,
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
      totalTime: json['total_time'] as int?,
      progress: json['progress'] != null
          ? ProgressInfo.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      'user_id': userId,
      'lesson_id': lessonId,
      'status': status,
      'score': score,
      'current_question_id': currentQuestionId,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'total_time': totalTime,
      'progress': progress?.toJson(),
    };
  }
}

class ProgressInfo {
  final int answered;
  final int total;
  final double percentage;

  ProgressInfo({
    required this.answered,
    required this.total,
    required this.percentage,
  });

  factory ProgressInfo.fromJson(Map<String, dynamic> json) {
    return ProgressInfo(
      answered: json['answered'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answered': answered,
      'total': total,
      'percentage': percentage,
    };
  }
}

