import 'package:get/get.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';

class ApiResponse<T> {
  final bool success;
  final int? statusCode;
  final String? url;
  final T? data;
  final Map<String, dynamic>? params;
  final dynamic body;
  final String? message;
  final dynamic response;
  final Meta? meta;
  final String? key;

  ApiResponse({
    required this.success,
    this.statusCode,
    this.url,
    this.params,
    this.body,
    this.data,
    this.message,
    this.response,
    this.meta,
    this.key,
  });

  factory ApiResponse.fromResponse(dynamic response) {
    return ApiResponse<T>(
      success: response.data['success'] == true,
      statusCode: response.statusCode,
      url: response.requestOptions.uri.toString(),
      body: response.data,
      data: response.statusCode == 422
          ? response.data['errors']
          : response.data['data'],
      params: response.requestOptions.queryParameters,
      message: response.data.containsKey('message')
          ? response.data['message']
          : null,
      response: response.data,
      meta: response.data.containsKey('meta')
          ? Meta.fromJson(response.data['meta'])
          : null,
      key: response.data.containsKey('key') ? response.data['key'] : null,
    );
  }

  bool get isSuccess => success && statusCode != null && statusCode! < 400;

  @override
  String toString() {
    // if (kDebugMode) {
    //   printDebug("=========== Inputes ===========");
    //   printDebug("Url: $url");
    //   printDebug("params: ${params ?? {}}");
    //   printDebug("body: ${body ?? {}}");
    //   printDebug("=========== Outputs ===========");
    //   printDebug("success: $success");
    //   printDebug("Status Code: $statusCode");
    //   printDebug("data: $data");
    //   printDebug("message: $message");
    // }

    int step = Shared.getValue(StorageKeys.step, initialValue: Steps.login);

    if (step == Steps.homeApp) {
      if (statusCode == 401) {
        Shared.clear();
        Shared.setValue(StorageKeys.step, Steps.login);
        Get.offAllNamed(AppRoutes.login);
      }

      if (key == 'messages.user.is_banned') {
        Shared.clear();
        Shared.setValue(StorageKeys.step, Steps.login);
        Get.offAllNamed(AppRoutes.login);

        // showBannedDialog();
      }
    }

    String dataAsString =
        'ApiResponse(success: $success, statusCode: $statusCode, url: $url, params: $params, body: $body, message: $message, data: $data)';
    return dataAsString;
  }
}

class Meta {
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  Meta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Meta(currentPage: $currentPage, lastPage: $lastPage, perPage: $perPage, total: $total)';
  }

  static handlePagination({
    required List list,
    required List newData,
    required Meta meta,
    required int page,
    bool reload = false,
  }) {
    if (reload) {
      list.clear();
    }
    int lastItemsLength = list.length % meta.perPage;
    if (lastItemsLength > 0) {
      list.removeRange(list.length - lastItemsLength, list.length);
    }

    list.addAll(newData);

    if (newData.length == meta.perPage) {
      page = meta.currentPage + 1;
    }

    return page;
  }
}
