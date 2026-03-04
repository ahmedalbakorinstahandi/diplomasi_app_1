class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic> data;
  final String? notificationableType;
  final int? notificationableId;
  final int? userId;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    this.type,
    this.data = const {},
    this.notificationableType,
    this.notificationableId,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: json['type'] as String?,
      data: _readData(json['data']),
      notificationableType: json['notificationable_type'],
      notificationableId: json['notificationable_id'],
      userId: json['user_id'],
      readAt: json['user_id'] == null
          ? DateTime.now().toIso8601String()
          : json['read_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'notificationable_type': notificationableType,
      'notificationable_id': notificationableId,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isRead => readAt != null;

  bool get hasAction =>
      data.containsKey('url') ||
      data.containsKey('link') ||
      data.containsKey('screen') ||
      (type != null && type!.isNotEmpty) ||
      (notificationableType != null && notificationableId != null);

  static Map<String, dynamic> _readData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }
}
