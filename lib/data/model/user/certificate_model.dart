class CertificateModel {
  final int id;
  final int userId;
  final int courseId;
  final int? levelId;
  final String certificateCode;
  final String issuedAt;
  final String? qrCode;
  final String? pdfUrl;
  final String? imageUrl;
  final String? templatePath;
  final String verificationUrl;
  final String downloadUrl;
  final String createdAt;
  final String updatedAt;
  final CourseInfo? course;
  final LevelInfo? level;

  CertificateModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.levelId,
    required this.certificateCode,
    required this.issuedAt,
    this.qrCode,
    this.pdfUrl,
    this.imageUrl,
    this.templatePath,
    required this.verificationUrl,
    required this.downloadUrl,
    required this.createdAt,
    required this.updatedAt,
    this.course,
    this.level,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      courseId: json['course_id'] as int,
      levelId: json['level_id'] as int?,
      certificateCode: json['certificate_code'] as String,
      issuedAt: json['issued_at'] as String,
      qrCode: json['qr_code'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      imageUrl: json['image_url'] as String?,
      templatePath: json['template_path'] as String?,
      verificationUrl: json['verification_url'] as String,
      downloadUrl: json['download_url'] as String? ?? "",
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      course: json['course'] != null
          ? CourseInfo.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      level: json['level'] != null
          ? LevelInfo.fromJson(json['level'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'level_id': levelId,
      'certificate_code': certificateCode,
      'issued_at': issuedAt,
      'qr_code': qrCode,
      'pdf_url': pdfUrl,
      'image_url': imageUrl,
      'template_path': templatePath,
      'verification_url': verificationUrl,
      'download_url': downloadUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course?.toJson(),
      'level': level?.toJson(),
    };
  }

  // Helper method to check if it's a course certificate
  bool get isCourseCertificate => levelId == null;

  // Helper method to get certificate title
  String get title {
    if (isCourseCertificate) {
      return course?.title ?? 'شهادة الكورس';
    } else {
      return level?.title ?? 'شهادة المستوى';
    }
  }

  // Helper method to get certificate subtitle
  String? get subtitle {
    if (isCourseCertificate) {
      return null;
    } else {
      return course?.title;
    }
  }
}

class CourseInfo {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;

  CourseInfo({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

class LevelInfo {
  final int id;
  final String title;
  final int? levelNumber;

  LevelInfo({required this.id, required this.title, this.levelNumber});

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      levelNumber: json['level_number'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'level_number': levelNumber};
  }
}

class CertificatePaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  CertificatePaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory CertificatePaginationMeta.fromJson(Map<String, dynamic> json) {
    return CertificatePaginationMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
    );
  }
}

class CertificateVerificationResult {
  final bool valid;
  final String? message;
  final CertificateVerificationData? certificate;

  CertificateVerificationResult({
    required this.valid,
    this.message,
    this.certificate,
  });

  factory CertificateVerificationResult.fromJson(Map<String, dynamic> json) {
    return CertificateVerificationResult(
      valid: json['valid'] as bool? ?? false,
      message: json['message'] as String?,
      certificate: json['certificate'] != null
          ? CertificateVerificationData.fromJson(
              json['certificate'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CertificateVerificationData {
  final String? userName;
  final String? courseTitle;
  final String? levelTitle;
  final String? issuedAt;
  final String? certificateCode;

  CertificateVerificationData({
    this.userName,
    this.courseTitle,
    this.levelTitle,
    this.issuedAt,
    this.certificateCode,
  });

  factory CertificateVerificationData.fromJson(Map<String, dynamic> json) {
    return CertificateVerificationData(
      userName: json['user_name'] as String?,
      courseTitle: json['course_title'] as String?,
      levelTitle: json['level_title'] as String?,
      issuedAt: json['issued_at'] as String?,
      certificateCode: json['certificate_code'] as String?,
    );
  }
}
