import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class PodcastsData {
  ApiService get _api => Get.find();

  Future<ApiResponse> getPodcasts({
    int page = 1,
    int perPage = 20,
    String status = 'all',
    bool? isFree,
    String? search,
    int? courseId,
    CancelToken? cancelToken,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'status': status,
      if (isFree != null) 'is_free': isFree ? 1 : 0,
      if (search != null && search.isNotEmpty) 'search': search,
      if (courseId != null) 'course_id': courseId,
    };
    return _api.get(
      EndPoints.podcasts,
      params: params,
      cancelToken: cancelToken,
    );
  }

  Future<ApiResponse> getPodcast(int id) async {
    return _api.get(
      EndPoints.podcast,
      pathVariables: {'id': id.toString()},
    );
  }

  Future<ApiResponse> updateProgress(
    int id, {
    required int positionSeconds,
    int? durationSeconds,
  }) async {
    return _api.post(
      EndPoints.podcastProgress,
      pathVariables: {'id': id.toString()},
      data: {
        'position_seconds': positionSeconds,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      },
    );
  }

  Future<ApiResponse> addFavorite(int id) async {
    return _api.post(
      EndPoints.podcastFavorite,
      pathVariables: {'id': id.toString()},
    );
  }

  Future<ApiResponse> removeFavorite(int id) async {
    return _api.delete(
      EndPoints.podcastFavorite,
      pathVariables: {'id': id.toString()},
    );
  }
}
