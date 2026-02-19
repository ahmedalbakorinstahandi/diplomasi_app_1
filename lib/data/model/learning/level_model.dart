import 'package:diplomasi_app/data/model/learning/course_model.dart';
import 'package:diplomasi_app/data/model/learning/level_track_model.dart';

class LevelModel {
  final int id;
  final int courseId;
  final int levelNumber;
  final String title;
  final String? description;
  final bool isPublished;
  final bool isFree;
  final bool hasCertificate;
  final bool isCompleted;
  final String accessStatus;
  final int orderIndex;
  final String createdAt;
  final String updatedAt;
  final CourseModel? course;
  final List<LevelTrackModel> levelTracks;

  LevelModel({
    required this.id,
    required this.courseId,
    required this.levelNumber,
    required this.title,
    this.description,
    required this.isPublished,
    required this.isFree,
    required this.hasCertificate,
    required this.isCompleted,
    required this.accessStatus,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.course,
    required this.levelTracks,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      levelNumber: json['level_number'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isPublished: json['is_published'] as bool,
      isFree: json['is_free'] as bool,
      hasCertificate: json['has_certificate'] as bool,
      isCompleted: json['is_completed'] as bool,
      accessStatus: json['access_status'] as String,
      orderIndex: json['order_index'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      course: json['course'] != null
          ? CourseModel.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      levelTracks: json['level_tracks'] != null
          ? (json['level_tracks'] as List)
                .map((levelTrack) => LevelTrackModel.fromJson(levelTrack))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'level_number': levelNumber,
      'title': title,
      'description': description,
      'is_published': isPublished,
      'is_free': isFree,
      'has_certificate': hasCertificate,
      'is_completed': isCompleted,
      'access_status': accessStatus,
      'order_index': orderIndex,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course?.toJson(),
      'level_tracks': levelTracks
          .map((levelTrack) => levelTrack.toJson())
          .toList(),
    };
  }
}
