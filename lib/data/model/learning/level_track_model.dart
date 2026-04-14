import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:diplomasi_app/data/model/learning/scenario_model.dart';

class LevelTrackModel {
  final int id;
  final int levelId;
  final int trackableId;
  final String trackableType;
  final int orderIndex;
  final String? status; // locked, locked_by_subscription, open, in_progress, completed
  final double? progressPercentage; // 0-100
  final bool? isAccessible;
  final String? accessReason; // progress | subscription
  final int? nextAccessibleTrackId;
  final String createdAt;
  final String updatedAt;
  final LevelModel? level;
  final dynamic trackable;

  LevelTrackModel({
    required this.id,
    required this.levelId,
    required this.trackableId,
    required this.trackableType,
    required this.orderIndex,
    this.status,
    this.progressPercentage,
    this.isAccessible,
    this.accessReason,
    this.nextAccessibleTrackId,
    required this.createdAt,
    required this.updatedAt,
    this.level,
    this.trackable,
  });

  factory LevelTrackModel.fromJson(Map<String, dynamic> json) {
    dynamic trackable;
    if (json['trackable'] != null) {
      if (json['trackable_type'].toString().toLowerCase().contains('lesson')) {
        trackable = LessonModel.fromJson(json['trackable']);
      } else if (json['trackable_type'].toString().toLowerCase().contains(
        'scenario',
      )) {
        trackable = ScenarioModel.fromJson(json['trackable']);
      }
    }

    return LevelTrackModel(
      id: json['id'],
      levelId: json['level_id'],
      trackableId: json['trackable_id'],
      trackableType: json['trackable_type'],
      orderIndex: json['order_index'],
      status: json['status'],
      progressPercentage: json['progress_percentage'] != null
          ? (json['progress_percentage'] is int
              ? json['progress_percentage'].toDouble()
              : json['progress_percentage'] as double)
          : null,
      isAccessible: json['is_accessible'],
      accessReason: json['access_reason'] as String?,
      nextAccessibleTrackId: json['next_accessible_track_id'] as int?,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
      trackable: trackable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
      'trackable_id': trackableId,
      'trackable_type': trackableType,
      'order_index': orderIndex,
      'status': status,
      'progress_percentage': progressPercentage,
      'is_accessible': isAccessible,
      'access_reason': accessReason,
      'next_accessible_track_id': nextAccessibleTrackId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'level': level?.toJson(),
      'trackable': trackable is LessonModel
          ? (trackable as LessonModel).toJson()
          : trackable is ScenarioModel
          ? (trackable as ScenarioModel).toJson()
          : null,
    };
  }
}
