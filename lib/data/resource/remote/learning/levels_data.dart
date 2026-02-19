import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class LevelsData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({
    required int courseId,
    int? page,
    int? perPage,
  }) async {
    return await apiService.get(
      EndPoints.levels,
      params: {
        if (page != null) 'page': page.toString(),
        if (perPage != null) 'per_page': perPage.toString(),
        'course_id': courseId.toString(),
      },
    );
  }

  Future<ApiResponse> show(int id) async {
    return await apiService.get(
      EndPoints.level,
      pathVariables: {'id': id.toString()},
    );
  }

  Future<ApiResponse> track(int levelId) async {
    return await apiService.get(
      EndPoints.levelTracks,
      params: {'level_id': levelId.toString(), 'per_page': 1000},
    );
  }
}
