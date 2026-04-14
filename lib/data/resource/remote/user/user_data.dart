import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class UserData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getMyInfo() async {
    return await apiService.get(EndPoints.userMe);
  }

  /// Updates server last_opened_app_at when the app returns to foreground (re-engagement accuracy).
  Future<void> sendHeartbeat() async {
    try {
      await apiService.post(EndPoints.userHeartbeat);
    } catch (_) {}
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    return await apiService.put(EndPoints.userMe, data: data);
  }

  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    String? deviceToken,
  }) async {
    return await apiService.put(
      EndPoints.userMe,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        if (deviceToken != null) 'device_token': deviceToken,
      },
    );
  }
}
