class VideoModel {
  final int id;
  final String title;
  final String videoUrl;
  final String createdAt;
  final String updatedAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    String readTitle() {
      final keys = ['title', 'name', 'video_title', 'youtube_title'];
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return '';
    }

    return VideoModel(
      id: json['id'] as int,
      title: readTitle(),
      videoUrl: json['video_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_url': videoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
