import 'dart:io';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/model/general/image_data_model.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class GeneralData {
  ApiService apiService = Get.find();

  Future<ApiResponse<ImageDataModel>> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      final response = await apiService.post(
        EndPoints.uploadImage,
        data: {'folder': folder},
        files: {'image': imageFile},
      );

      if (response.success && response.data != null) {
        final imageData = ImageDataModel.fromJson(response.data);
        return ApiResponse<ImageDataModel>(
          success: true,
          data: imageData,
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<ImageDataModel>(
        success: false,
        message: response.message ?? 'فشل رفع الصورة',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<ImageDataModel>(
        success: false,
        message: 'حدث خطأ أثناء رفع الصورة',
      );
    }
  }
}
