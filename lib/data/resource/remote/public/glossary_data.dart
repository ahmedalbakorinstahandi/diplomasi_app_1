import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class GlossaryData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getTerms({String? search}) async {
    final params = <String, dynamic>{
      'per_page': 500,
      'course_id': Shared.getValue(StorageKeys.courseId, initialValue: 0),
    };
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    return await apiService.get(
      EndPoints.glossaryTerms,
      params: params,
    );
  }
}
