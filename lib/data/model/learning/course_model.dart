class CourseModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isPublished;
  final bool isFree;
  final int orderIndex;
  final String createdAt;
  final String updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isPublished,
    required this.isFree,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      //ToDO : handle null image URLs
      imageUrl: json['image_url'] ??"", 
      isPublished: json['is_published'] as bool,
      isFree: json['is_free'] as bool,
      orderIndex: json['order_index'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'is_published': isPublished,
      'is_free': isFree,
      'order_index': orderIndex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
