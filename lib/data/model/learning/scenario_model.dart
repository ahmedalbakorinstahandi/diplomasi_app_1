import 'package:diplomasi_app/data/model/learning/level_model.dart';

class ScenarioModel {
  final int id;
  final int levelId;
  final String title;
  final String description;
  final bool isPublished;
  final bool isFree;
  final int? startQuestionId;
  final int orderIndex;
  final String? status; // locked, open, completed
  final double? progressPercentage; // 0-100
  final bool hasPreviousAttempts;
  final String createdAt;
  final String updatedAt;
  final LevelModel? level;

  ScenarioModel({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.isPublished,
    required this.isFree,
    this.startQuestionId,
    required this.orderIndex,
    this.status,
    this.progressPercentage,
    this.hasPreviousAttempts = false,
    required this.createdAt,
    required this.updatedAt,
    this.level,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'],
      levelId: json['level_id'],
      title: json['title'],
      description: json['description'],
      isPublished: json['is_published'],
      isFree: json['is_free'],
      startQuestionId: json['start_question_id'],
      orderIndex: json['order_index'],
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
      'title': title,
      'description': description,
      'is_published': isPublished,
      'is_free': isFree,
      'start_question_id': startQuestionId,
      'order_index': orderIndex,
      'status': status,
      'progress_percentage': progressPercentage,
      'has_previous_attempts': hasPreviousAttempts,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'level': level?.toJson(),
    };
  }
}
