class ArticleModel {
  final int id;
  final String title;
  final String? slug;
  final String content;
  final int authorId;
  final bool isPublished;
  final String? imageUrl;
  final String? pdfUrl;
  final String? publishedAt;
  final int orderIndex;
  final String createdAt;
  final String updatedAt;
  final ArticleAuthor? author;

  ArticleModel({
    required this.id,
    required this.title,
    this.slug,
    required this.content,
    required this.authorId,
    required this.isPublished,
    this.imageUrl,
    this.pdfUrl,
    this.publishedAt,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'],
      content: json['content'] ?? '',
      authorId: json['author_id'],
      isPublished: json['is_published'] ?? false,
      imageUrl: json['image_url'],
      pdfUrl: json['pdf_url'],
      publishedAt: json['published_at'],
      orderIndex: json['order_index'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      author: json['author'] != null
          ? ArticleAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'author_id': authorId,
      'is_published': isPublished,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'published_at': publishedAt,
      'order_index': orderIndex,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'author': author?.toJson(),
    };
  }
}

class ArticleAuthor {
  final int id;
  final String firstName;
  final String lastName;
  final int phoneVerified;
  final int emailVerified;
  final String? avatar;
  final String email;
  final String phone;
  final String? address;
  final String language;
  final String status;
  final String createdAt;
  final String updatedAt;

  ArticleAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneVerified,
    required this.emailVerified,
    this.avatar,
    required this.email,
    required this.phone,
    this.address,
    required this.language,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleAuthor.fromJson(Map<String, dynamic> json) {
    return ArticleAuthor(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneVerified: (json['phone_verified'] is bool)
          ? (json['phone_verified'] ? 1 : 0)
          : (json['phone_verified'] ?? 0),
      emailVerified: (json['email_verified'] is bool)
          ? (json['email_verified'] ? 1 : 0)
          : (json['email_verified'] ?? 0),
      avatar: json['avatar'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      language: json['language'] ?? 'ar',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
      'avatar': avatar,
      'email': email,
      'phone': phone,
      'address': address,
      'language': language,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullName => '$firstName $lastName';
}
