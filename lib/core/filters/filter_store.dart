// import 'package:diplomasi_app/data/model/category_model.dart';
// import 'package:get/get.dart';

// class FilterStore extends GetxService {
//   // Reactive version for notifying listeners (UI preview updates)
//   final RxInt version = 0.obs;
//   // Applied version for notifying controllers (actual data fetch)
//   final RxInt appliedVersion = 0.obs;

//   // Filter state
//   CategoryModel? selectedCategory;
//   double? priceMin;
//   double? priceMax;
//   int? governorateId;
//   int? cityId;
//   String? availabilityStatus;
//   String? type;
//   bool? hasInsurance;
//   final Map<int, dynamic> properties = {};
//   final Map<int, bool> features = {};

//   // Setters
//   void selectCategory(CategoryModel? category) {
//     selectedCategory = category;
//     // Clear category-specific filters when category changes
//     properties.clear();
//     features.clear();
//     version.value++;
//     appliedVersion.value++; // Trigger data fetch immediately
//   }

//   void setPriceRange(double? min, double? max) {
//     priceMin = min;
//     priceMax = max;
//     version.value++;
//   }

//   void setGovernorate(int? id) {
//     governorateId = id;
//     if (id == null) {
//       cityId = null;
//     }
//     version.value++;
//   }

//   void setCity(int? id) {
//     cityId = id;
//     version.value++;
//   }

//   void setAvailabilityStatus(String? status) {
//     availabilityStatus = status;
//     version.value++;
//   }

//   void setType(String? filterType) {
//     type = filterType;
//     version.value++;
//   }

//   void setHasInsurance(bool? insurance) {
//     hasInsurance = insurance;
//     version.value++;
//   }

//   void setPropertyValue(int propertyId, dynamic value) {
//     if (value == null) {
//       properties.remove(propertyId);
//     } else {
//       properties[propertyId] = value;
//     }
//     version.value++;
//   }

//   void setFeatureValue(int featureId, bool? value) {
//     if (value == null) {
//       features.remove(featureId);
//     } else {
//       features[featureId] = value;
//     }
//     version.value++;
//   }

//   void resetAll() {
//     priceMin = null;
//     priceMax = null;
//     governorateId = null;
//     cityId = null;
//     availabilityStatus = null;
//     type = null;
//     hasInsurance = null;
//     properties.clear();
//     features.clear();
//     selectedCategory = null;
//     version.value++;
//   }

//   void notifyApplied() {
//     appliedVersion.value++;
//   }

//   String currentSignature() {
//     final list = buildAppliedFiltersList();
//     list.sort(
//       (a, b) => ('${a['filter_kind']}:${a['filter_name']}').compareTo(
//         '${b['filter_kind']}:${b['filter_name']}',
//       ),
//     );
//     return list
//         .map(
//           (m) => '${m['filter_kind']}:${m['filter_name']}=${m['filter_value']}',
//         )
//         .join('|');
//   }

//   List<Map<String, dynamic>> buildAppliedFiltersList() {
//     List<Map<String, dynamic>> appliedFilters = [];

//     // Category (basic)
//     if (selectedCategory != null) {
//       appliedFilters.add({
//         'filter_name': 'category_id',
//         'filter_value': selectedCategory!.id,
//         'filter_kind': 'basic',
//       });
//     }

//     // Price (basic)
//     if (priceMin != null) {
//       appliedFilters.add({
//         'filter_name': 'price_min',
//         'filter_value': priceMin,
//         'filter_kind': 'basic',
//       });
//     }
//     if (priceMax != null) {
//       appliedFilters.add({
//         'filter_name': 'price_max',
//         'filter_value': priceMax,
//         'filter_kind': 'basic',
//       });
//     }

//     // Governorate (basic)
//     if (governorateId != null) {
//       appliedFilters.add({
//         'filter_name': 'governorate_id',
//         'filter_value': governorateId,
//         'filter_kind': 'basic',
//       });
//     }

//     // City (basic)
//     if (cityId != null) {
//       appliedFilters.add({
//         'filter_name': 'city_id',
//         'filter_value': cityId,
//         'filter_kind': 'basic',
//       });
//     }

//     // Availability Status (basic)
//     if (availabilityStatus != null) {
//       appliedFilters.add({
//         'filter_name': 'availability_status',
//         'filter_value': availabilityStatus,
//         'filter_kind': 'basic',
//       });
//     }

//     // Type (basic)
//     if (type != null) {
//       appliedFilters.add({
//         'filter_name': 'type',
//         'filter_value': type,
//         'filter_kind': 'basic',
//       });
//     }

//     // Insurance (basic)
//     if (hasInsurance != null) {
//       appliedFilters.add({
//         'filter_name': 'has_insurance',
//         'filter_value': hasInsurance! ? 1 : 0,
//         'filter_kind': 'basic',
//       });
//     }

//     // Properties (dynamic)
//     properties.forEach((propertyId, value) {
//       // Check if value is a map with min/max (for numeric ranges)
//       if (value is Map) {
//         if (value['min'] != null) {
//           appliedFilters.add({
//             'filter_name': 'property_${propertyId}_min',
//             'filter_value': value['min'],
//             'filter_kind': 'property',
//           });
//         }
//         if (value['max'] != null) {
//           appliedFilters.add({
//             'filter_name': 'property_${propertyId}_max',
//             'filter_value': value['max'],
//             'filter_kind': 'property',
//           });
//         }
//       } else {
//         // Single value (for other types)
//         appliedFilters.add({
//           'filter_name': 'property_$propertyId',
//           'filter_value': value,
//           'filter_kind': 'property',
//         });
//       }
//     });

//     // Features (dynamic)
//     features.forEach((featureId, value) {
//       appliedFilters.add({
//         'filter_name': 'feature_$featureId',
//         'filter_value': value,
//         'filter_kind': 'feature',
//       });
//     });

//     return appliedFilters;
//   }

//   // Helper methods for category navigation
//   List<List<CategoryModel>> getCategoryLevels(List categories) {
//     List<List<CategoryModel>> levels = [];

//     // Convert categories list to CategoryModel list
//     List<CategoryModel> rootCategories = categories
//         .map((cat) => CategoryModel.fromJson(cat))
//         .toList();

//     // Level 1: Root categories
//     levels.add(rootCategories);

//     if (selectedCategory == null) {
//       return levels;
//     }

//     // Build path from root to selected category
//     List<CategoryModel> path = _buildPathToCategory(
//       selectedCategory!,
//       rootCategories,
//     );

//     // Add levels for each category in path
//     for (int i = 0; i < path.length; i++) {
//       CategoryModel currentCategory = path[i];
//       if (currentCategory.children.isNotEmpty) {
//         levels.add(currentCategory.children);
//       }
//     }

//     return levels;
//   }

//   List<CategoryModel> _buildPathToCategory(
//     CategoryModel target,
//     List<CategoryModel> categories,
//   ) {
//     for (CategoryModel category in categories) {
//       if (category.id == target.id) {
//         return [category];
//       }

//       if (category.children.isNotEmpty) {
//         List<CategoryModel> childPath = _buildPathToCategory(
//           target,
//           category.children,
//         );
//         if (childPath.isNotEmpty) {
//           return [category, ...childPath];
//         }
//       }
//     }
//     return [];
//   }

//   bool isCategoryInPath(CategoryModel category, List categories) {
//     if (selectedCategory == null) {
//       return false;
//     }

//     List<CategoryModel> rootCategories = categories
//         .map((cat) => CategoryModel.fromJson(cat))
//         .toList();

//     List<CategoryModel> path = _buildPathToCategory(
//       selectedCategory!,
//       rootCategories,
//     );

//     return path.any((cat) => cat.id == category.id);
//   }
// }
