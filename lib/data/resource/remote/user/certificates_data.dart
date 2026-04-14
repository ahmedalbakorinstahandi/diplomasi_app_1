import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/timezone_helper.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/src/response.dart' as dio;

class CertificatesData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getCertificates({
    int page = 1,
    int perPage = 20,
    String sortField = 'issued_at',
    String sortOrder = 'desc',
    int? courseId,
    int? levelId,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_field': sortField,
      'sort_order': sortOrder,
    };

    params['course_id'] =
        courseId ?? Shared.getValue(StorageKeys.courseId, initialValue: 0);
    if (levelId != null) {
      params['level_id'] = levelId;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    return await apiService.get(EndPoints.certificates, params: params);
  }

  Future<ApiResponse> getCertificate(int id) async {
    return await apiService.get(
      EndPoints.certificate,
      pathVariables: {'id': id.toString()},
    );
  }

  Future<dio.Response> downloadCertificate(int id) async {
    // Create a new Dio instance for downloading binary data
    final dioClient = Dio();
    final accessToken = Shared.getValue(StorageKeys.accessToken);

    final endpoint = EndPoints.certificateDownload.replaceAll(
      '{id}',
      id.toString(),
    );

    if (accessToken != null) {
      dioClient.options.headers['Authorization'] = 'Bearer $accessToken';
    }
    dioClient.options.headers['X-Context'] = 'app';
    dioClient.options.headers['Accept'] = 'image/png';
    dioClient.options.responseType = ResponseType.bytes;

    final timezoneHeaders = await getTimezoneHeaders();
    dioClient.options.headers.addAll(timezoneHeaders);

    return await dioClient.get(endpoint);
  }

  Future<ApiResponse> verifyCertificate(String certificateCode) async {
    return await apiService.get(
      EndPoints.verifyCertificate,
      pathVariables: {'certificateCode': certificateCode},
    );
  }

  /// Verify certificate image and generate it if missing
  /// Returns updated certificate data with image_url
  Future<ApiResponse> verifyCertificateImage(int certificateId) async {
    return await apiService.get(
      EndPoints.certificateVerifyImage,
      pathVariables: {'id': certificateId.toString()},
    );
  }
}
