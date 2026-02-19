class NotificationModel {
  final int id;
  final String title;
  final String body;
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
      'notificationable_type': notificationableType,
      'notificationable_id': notificationableId,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isRead => readAt != null;
}
