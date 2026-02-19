import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class NotificationsData {
  ApiService apiService = Get.find();

  Future<ApiResponse> get({int page = 1, int perPage = 20}) async {
    return await apiService.get(
      EndPoints.notifications,
      params: {'page': page, 'per_page': perPage},
    );
  }

  Future<ApiResponse> markAllAsRead() async {
    return await apiService.post(EndPoints.markAllRead);
  }

  Future<ApiResponse> getUnreadCount() async {
    return await apiService.get(EndPoints.unreadCount);
  }
}
