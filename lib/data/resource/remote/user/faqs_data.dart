import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class FaqsData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({
    int page = 1,
    int perPage = 20,
    String? search,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> params = {
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    return await apiService.get(
      EndPoints.faqs,
      params: params,
      cancelToken: cancelToken,
    );
  }
}
