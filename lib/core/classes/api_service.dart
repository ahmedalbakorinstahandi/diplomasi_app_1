import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/localization/changelocale.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'internet_connectivity_service.dart';

class ApiService {
  final Dio _dio;
  final InternetConnectivityService connectivityService;

  ApiService({
    required String baseUrl,
    required this.connectivityService,
    Map<String, String>? defaultHeaders,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 40),
           receiveTimeout: const Duration(seconds: 40),
           headers: defaultHeaders ?? {},
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!connectivityService.isConnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          }

          final accessToken = Shared.getValue(StorageKeys.accessToken);

          options.headers['Accept-Language'] = LocaleController.languageCode;
          options.headers['X-Context'] = 'app';
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          ApiResponse apiResponse = ApiResponse.fromResponse(error.response);

          apiResponse.toString();

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          responseHeader: false,
          // requestBody: false,
          // responseBody: false,
          // error: false,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
          enabled: kDebugMode,
          filter: (options, args) {
            if (options.path.contains('/get-provider-position')) {
              return false;
            }
            return !args.isResponse || !args.hasUint8ListData;
          },
        ),
      );
    }
  }

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? pathVariables,
    bool printResponse = true,
    CancelToken? cancelToken,
  }) async {
    try {
      Map currentLocation = Shared.getMapValue('currentLocation');

      params ??= {};

      if (currentLocation.isNotEmpty) {
        params['lat'] = currentLocation['latitude'];
        params['long'] = currentLocation['longitude'];
      }

      final resolvedEndpoint = _resolvePathVariables(endpoint, pathVariables);
      final response = await _dio.get(
        resolvedEndpoint,
        queryParameters: params,
        cancelToken: cancelToken,
      );
      ApiResponse apiResponse = ApiResponse.fromResponse(response);
      return apiResponse;
    } on DioException catch (e) {
      printDebug('response error: $e');
      return _handleError(e, endpoint, params: params);
    }
  }

  Future<ApiResponse> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? pathVariables,
    Map<String, dynamic>? files,
    bool printResponse = true,
    CancelToken? cancelToken,
  }) async {
    try {
      endpoint = _resolvePathVariables(endpoint, pathVariables);

      // Use JSON if no files, otherwise use FormData
      dynamic requestData;
      Options? options;
      if (files != null && files.isNotEmpty) {
        requestData = await _prepareFormData(data, files);
      } else {
        // Send as JSON when no files
        requestData = data;
        // Set Content-Type header for JSON
        options = Options(headers: {'Content-Type': 'application/json'});
      }

      final response = await _dio.post(
        endpoint,
        data: requestData,
        options: options,
        cancelToken: cancelToken,
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);
      apiResponse.toString();
      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e, endpoint, body: data);
    }
  }

  Future<ApiResponse> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? pathVariables,
    bool printResponse = true,
    CancelToken? cancelToken,
  }) async {
    try {
      final resolvedEndpoint = _resolvePathVariables(endpoint, pathVariables);
      final response = await _dio.put(
        resolvedEndpoint,
        data: data,
        cancelToken: cancelToken,
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);
      apiResponse.toString();
      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e, endpoint, body: data);
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? pathVariables,
    bool printResponse = true,
    CancelToken? cancelToken,
  }) async {
    try {
      final resolvedEndpoint = _resolvePathVariables(endpoint, pathVariables);
      final response = await _dio.delete(
        resolvedEndpoint,
        data: data,
        cancelToken: cancelToken,
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);
      apiResponse.toString();
      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e, endpoint, body: data);
    }
  }

  String _resolvePathVariables(
    String endpoint,
    Map<String, dynamic>? pathVariables,
  ) {
    if (pathVariables != null) {
      pathVariables.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value.toString());
      });
    }
    return endpoint;
  }

  Future<FormData> _prepareFormData(
    dynamic data,
    Map<String, dynamic>? files,
  ) async {
    // Convert Map to FormData with proper array handling
    final Map<String, dynamic> formDataMap = {};

    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is List) {
          // Handle arrays properly for FormData
          for (int i = 0; i < value.length; i++) {
            formDataMap['$key[$i]'] = value[i];
          }
        } else {
          formDataMap[key] = value;
        }
      });
    }

    final formData = FormData.fromMap(formDataMap);

    if (files != null) {
      final List<MapEntry<String, MultipartFile>> fileEntries = [];

      for (var entry in files.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is File) {
          final file = await MultipartFile.fromFile(
            value.path,
            filename: value.uri.pathSegments.last,
          );
          fileEntries.add(MapEntry(key, file));
        } else if (value is List<File>) {
          for (var file in value) {
            final multiFile = await MultipartFile.fromFile(
              file.path,
              filename: file.uri.pathSegments.last,
            );
            fileEntries.add(MapEntry("$key[]", multiFile));
          }
        }
      }

      formData.files.addAll(fileEntries);
    }

    return formData;
  }

  ApiResponse _handleError(
    DioException error,
    String endpoint, {
    Map<String, dynamic>? params,
    dynamic body,
  }) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data['message'];
    error.message;

    if (message != null) {
      printDebug('Error: $message');
      if (statusCode != 500 || kDebugMode) {
        customSnackBar(text: message, snackType: SnackBarType.error);
      }
    }
    ApiResponse api = ApiResponse(
      success: false,
      statusCode: statusCode,
      url: endpoint,
      params: params,
      body: body,
      message: message,
      key: error.response?.data['key'],
    );

    api.toString();

    return api;
  }
}
