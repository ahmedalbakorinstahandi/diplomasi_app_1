class VideoModel {
  final int id;
  final String videoUrl;
  final String createdAt;
  final String updatedAt;

  VideoModel({
    required this.id,
    required this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as int,
      videoUrl: json['video_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': videoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
