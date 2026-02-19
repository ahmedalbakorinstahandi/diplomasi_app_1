class PlanModel {
  final int id;
  final String name;
  final String price;
  final String interval; // monthly, annual
  final String description;
  final String? iconUrl;
  final List<String> features;
  final String createdAt;
  final String updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.interval,
    required this.description,
    this.iconUrl,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as String,
      interval: json['interval'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'interval': interval,
      'description': description,
      'icon_url': iconUrl,
      'features': features,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to check if it's annual plan
  bool get isAnnual => interval.toLowerCase() == 'annual';

  // Helper method to check if it's premium/lifetime plan
  bool get isPremium =>
      name.toLowerCase().contains('premium') ||
      name.toLowerCase().contains('lifetime');
}
