import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class CoursesData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({int? page, int? perPage}) async {
    return await apiService.get(
      EndPoints.cources,
      params: {'page': page?.toString(), 'per_page': perPage?.toString()},
    );
  }

  Future<ApiResponse> show(int id) async {
    return await apiService.get(
      EndPoints.cource,
      pathVariables: {'id': id.toString()},
    );
  }
}
