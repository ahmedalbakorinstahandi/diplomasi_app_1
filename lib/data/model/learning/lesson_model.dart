import 'package:diplomasi_app/data/model/learning/level_model.dart';

class LessonModel {
  final int id;
  final int levelId;
  final String lessonNumber;
  final String title;
  final String description;
  final String videoUrl;
  final String content;
  final int orderIndex;
  final bool isPublished;
  final String? status; // locked, open, completed
  final double? progressPercentage; // 0-100
  final bool hasPreviousAttempts;
  final String createdAt;
  final String updatedAt;
  final LevelModel? level;

  LessonModel({
    required this.id,
    required this.levelId,
    required this.lessonNumber,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.content,
    required this.orderIndex,
    required this.isPublished,
    this.status,
    this.progressPercentage,
    this.hasPreviousAttempts = false,
    required this.createdAt,
    required this.updatedAt,
    this.level,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      levelId: json['level_id'],
      lessonNumber: json['lesson_number'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      content: json['content'],
      orderIndex: json['order_index'],
      isPublished: json['is_published'],
      status: json['status'],
      progressPercentage: json['progress_percentage'] != null
          ? (json['progress_percentage'] is int
              ? json['progress_percentage'].toDouble()
              : json['progress_percentage'] as double)
          : null,
      hasPreviousAttempts: json['has_previous_attempts'] as bool? ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
      'lesson_number': lessonNumber,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'content': content,
      'order_index': orderIndex,
      'is_published': isPublished,
      'status': status,
      'progress_percentage': progressPercentage,
      'has_previous_attempts': hasPreviousAttempts,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'level': level?.toJson(),
    };
  }
}
