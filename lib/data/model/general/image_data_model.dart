class ImageDataModel {
  final String imageName;
  final String imageUrl;

  ImageDataModel({
    required this.imageName,
    required this.imageUrl,
  });

  factory ImageDataModel.fromJson(Map<String, dynamic> json) {
    return ImageDataModel(
      imageName: json['image_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_name': imageName,
      'image_url': imageUrl,
    };
  }
}

