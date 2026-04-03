import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class AuthData {
  ApiService apiService = Get.find();

  Future<ApiResponse> login({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    return await apiService.post(
      EndPoints.login,
      data: {
        'email': email,
        'password': password,
        'role': 'user',
        if (deviceToken != null) 'device_token': deviceToken,
      },
    );
  }

  Future<ApiResponse> startGuest({String? deviceToken}) async {
    return await apiService.post(
      EndPoints.guestStart,
      data: {if (deviceToken != null) 'device_token': deviceToken},
    );
  }

  Future<ApiResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await apiService.post(
      EndPoints.register,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'user',
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<ApiResponse> registerFromGuest({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? deviceToken,
  }) async {
    return await apiService.post(
      EndPoints.registerFromGuest,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (deviceToken != null) 'device_token': deviceToken,
      },
    );
  }

  /// [purpose]: `password_reset` (افتراضي)، أو `account_activation` لتفعيل بريد غير مفعّل.
  Future<ApiResponse> forgotPassword({
    required String email,
    String? purpose,
  }) async {
    return await apiService.post(
      EndPoints.forgotPassword,
      data: {
        'email': email,
        if (purpose != null) 'purpose': purpose,
      },
    );
  }

  Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
    String? deviceToken,
  }) async {
    return await apiService.post(
      EndPoints.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
        if (deviceToken != null) 'device_token': deviceToken,
      },
    );
  }

  Future<ApiResponse> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    String? deviceToken,
  }) async {
    return await apiService.post(
      EndPoints.resetPassword,
      data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (deviceToken != null) 'device_token': deviceToken,
      },
    );
  }

  Future<ApiResponse> logout() async {
    return await apiService.post(EndPoints.logout, data: {});
  }

  Future<ApiResponse> requestAccountDeletion() async {
    return await apiService.post(EndPoints.requestAccountDeletion, data: {});
  }

  Future<ApiResponse> confirmAccountDeletion({required String code}) async {
    return await apiService.post(
      EndPoints.confirmAccountDeletion,
      data: {'code': code},
    );
  }
}
