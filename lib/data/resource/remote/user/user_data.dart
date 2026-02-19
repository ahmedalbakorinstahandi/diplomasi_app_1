import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class UserData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getMyInfo() async {
    return await apiService.get(EndPoints.userMe);
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    return await apiService.put(EndPoints.userMe, data: data);
  }

  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await apiService.put(
      EndPoints.userMe,
      data: {'current_password': currentPassword, 'password': newPassword},
    );
  }
}
