class PodcastProgressModel {
  final int positionSeconds;
  final double progressPercentage;
  final bool isCompleted;
  final String? lastPlayedAt;

  const PodcastProgressModel({
    required this.positionSeconds,
    required this.progressPercentage,
    required this.isCompleted,
    this.lastPlayedAt,
  });

  factory PodcastProgressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PodcastProgressModel(
        positionSeconds: 0,
        progressPercentage: 0,
        isCompleted: false,
      );
    }
    return PodcastProgressModel(
      positionSeconds: (json['position_seconds'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0,
      isCompleted: json['is_completed'] == true,
      lastPlayedAt: json['last_played_at']?.toString(),
    );
  }

  PodcastProgressModel copyWith({
    int? positionSeconds,
    double? progressPercentage,
    bool? isCompleted,
    String? lastPlayedAt,
  }) {
    return PodcastProgressModel(
      positionSeconds: positionSeconds ?? this.positionSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  static const empty = PodcastProgressModel(
    positionSeconds: 0,
    progressPercentage: 0,
    isCompleted: false,
  );
}

class PodcastModel {
  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final int durationSeconds;
  final bool isFree;
  final bool requiresSubscription;
  final bool allowDownload;
  final bool isLocked;
  final String? lockReason;
  final PodcastProgressModel progress;
  final bool isFavorite;

  const PodcastModel({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.durationSeconds,
    required this.isFree,
    required this.requiresSubscription,
    required this.allowDownload,
    required this.isLocked,
    this.lockReason,
    required this.progress,
    required this.isFavorite,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      coverImage: json['cover_image']?.toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      isFree: json['is_free'] == true,
      requiresSubscription: json['requires_subscription'] == true,
      allowDownload: json['allow_download'] == true,
      isLocked: json['is_locked'] == true,
      lockReason: json['lock_reason']?.toString(),
      progress: PodcastProgressModel.fromJson(
        json['progress'] is Map<String, dynamic>
            ? json['progress'] as Map<String, dynamic>
            : null,
      ),
      isFavorite: json['is_favorite'] == true,
    );
  }

  PodcastModel copyWith({
    int? id,
    String? title,
    String? description,
    String? coverImage,
    int? durationSeconds,
    bool? isFree,
    bool? requiresSubscription,
    bool? allowDownload,
    bool? isLocked,
    String? lockReason,
    PodcastProgressModel? progress,
    bool? isFavorite,
  }) {
    return PodcastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isFree: isFree ?? this.isFree,
      requiresSubscription: requiresSubscription ?? this.requiresSubscription,
      allowDownload: allowDownload ?? this.allowDownload,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class PodcastDetailModel extends PodcastModel {
  final String? streamUrl;
  final String? downloadUrl;
  final String? publishedAt;

  /// Server row update time; used to know if a re-upload replaced the audio file.
  final String? updatedAt;

  const PodcastDetailModel({
    required super.id,
    required super.title,
    super.description,
    super.coverImage,
    required super.durationSeconds,
    required super.isFree,
    required super.requiresSubscription,
    required super.allowDownload,
    required super.isLocked,
    super.lockReason,
    required super.progress,
    required super.isFavorite,
    this.streamUrl,
    this.downloadUrl,
    this.publishedAt,
    this.updatedAt,
  });

  factory PodcastDetailModel.fromJson(Map<String, dynamic> json) {
    return PodcastDetailModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      coverImage: json['cover_image']?.toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      isFree: json['is_free'] == true,
      requiresSubscription: json['requires_subscription'] == true,
      allowDownload: json['allow_download'] == true,
      isLocked: json['is_locked'] == true,
      lockReason: json['lock_reason']?.toString(),
      progress: PodcastProgressModel.fromJson(
        json['progress'] is Map<String, dynamic>
            ? json['progress'] as Map<String, dynamic>
            : null,
      ),
      isFavorite: json['is_favorite'] == true,
      streamUrl: json['stream_url']?.toString(),
      downloadUrl: json['download_url']?.toString(),
      publishedAt: json['published_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  factory PodcastDetailModel.fromBase(PodcastModel base, {String? streamUrl, String? downloadUrl, String? publishedAt, String? updatedAt}) {
    return PodcastDetailModel(
      id: base.id,
      title: base.title,
      description: base.description,
      coverImage: base.coverImage,
      durationSeconds: base.durationSeconds,
      isFree: base.isFree,
      requiresSubscription: base.requiresSubscription,
      allowDownload: base.allowDownload,
      isLocked: base.isLocked,
      lockReason: base.lockReason,
      progress: base.progress,
      isFavorite: base.isFavorite,
      streamUrl: streamUrl,
      downloadUrl: downloadUrl,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }

  @override
  PodcastDetailModel copyWith({
    int? id,
    String? title,
    String? description,
    String? coverImage,
    int? durationSeconds,
    bool? isFree,
    bool? requiresSubscription,
    bool? allowDownload,
    bool? isLocked,
    String? lockReason,
    PodcastProgressModel? progress,
    bool? isFavorite,
    String? streamUrl,
    String? downloadUrl,
    String? publishedAt,
    String? updatedAt,
  }) {
    return PodcastDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isFree: isFree ?? this.isFree,
      requiresSubscription: requiresSubscription ?? this.requiresSubscription,
      allowDownload: allowDownload ?? this.allowDownload,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
      streamUrl: streamUrl ?? this.streamUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
