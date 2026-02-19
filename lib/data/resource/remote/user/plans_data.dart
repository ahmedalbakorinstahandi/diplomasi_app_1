import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class PlansData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getPlans() async {
    return await apiService.get(EndPoints.plans);
  }
}
