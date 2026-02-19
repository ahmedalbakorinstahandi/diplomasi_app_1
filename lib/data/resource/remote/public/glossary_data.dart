import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class GlossaryData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getTerms({String? search}) async {
    return await apiService.get(
      EndPoints.glossaryTerms,
      params: {'search': search, 'per_page': 500},
    );
  }
}
