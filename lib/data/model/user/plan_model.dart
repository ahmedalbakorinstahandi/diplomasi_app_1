class PlanModel {
  final int id;
  final String name;
  final String price;
  final String interval; // monthly, quarterly, semi_annual, annual
  final String? intervalLabel; // من الـ API: شهري، 3 أشهر، 6 أشهر، سنة
  final String description;
  final String? caption; // عبارة ترويجية من الـ API، إن وُجدت تعرض بدل النص الثابت
  final bool isFeatured; // من الـ API: عرض تاج + بوردر برتقالي
  final String? iconUrl;
  final List<String> features;
  final String createdAt;
  final String updatedAt;
  /// معرف منتج Apple (للـ iOS فقط). إن لم يرده الخادم نستخدم price الافتراضي.
  final String? iosProductId;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.interval,
    this.intervalLabel,
    required this.description,
    this.caption,
    this.isFeatured = false,
    this.iconUrl,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
    this.iosProductId,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'];
    final price = priceRaw != null ? priceRaw.toString() : '0';
    return PlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: price,
      interval: json['interval'] as String? ?? 'monthly',
      intervalLabel: json['interval_label'] as String?,
      description: json['description'] as String? ?? '',
      caption: json['caption'] as String?,
      isFeatured: json['is_featured'] == true,
      iconUrl: json['icon_url'] as String?,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      iosProductId: json['ios_product_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'interval': interval,
      'interval_label': intervalLabel,
      'description': description,
      'caption': caption,
      'is_featured': isFeatured,
      'icon_url': iconUrl,
      'features': features,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (iosProductId != null) 'ios_product_id': iosProductId,
    };
  }

  /// التسمية المعروضة للمدة (من API أو محلياً)
  String get displayIntervalLabel =>
      intervalLabel?.trim().isNotEmpty == true
          ? intervalLabel!
          : _fallbackIntervalLabel(interval);

  static String _fallbackIntervalLabel(String interval) {
    switch (interval.toLowerCase()) {
      case 'annual':
        return 'سنة';
      case 'semi_annual':
        return '6 أشهر';
      case 'quarterly':
        return '3 أشهر';
      case 'monthly':
      default:
        return 'شهري';
    }
  }

  bool get isAnnual => interval.toLowerCase() == 'annual';
}
