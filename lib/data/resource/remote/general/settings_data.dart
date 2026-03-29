import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class SettingsData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({required String idOrKey}) async {
    return await apiService.get(
      EndPoints.setting,
      pathVariables: {'idOrKey': idOrKey},
    );
  }

  /// Tries keys in order; returns first successful response, or the last attempt.
  Future<ApiResponse> getFirstSuccessfulKey(Iterable<String> keys) async {
    ApiResponse? last;
    for (final idOrKey in keys) {
      last = await get(idOrKey: idOrKey);
      if (last.isSuccess) return last;
    }
    return last!;
  }
}
