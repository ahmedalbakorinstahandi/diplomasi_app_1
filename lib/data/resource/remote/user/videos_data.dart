import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class VideosData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({
    int page = 1,
    int perPage = 20,
    String sortField = 'created_at',
    String sortOrder = 'desc',
  }) async {
    return await apiService.get(
      EndPoints.videosUrl,
      params: {
        'page': page,
        'per_page': perPage,
        'sort_field': sortField,
        'sort_order': sortOrder,
        'course_id': Shared.getValue(StorageKeys.courseId, initialValue: 0),
      },
    );
  }
}
