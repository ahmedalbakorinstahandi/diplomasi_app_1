import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/podcasts_data.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

// ── Download state ────────────────────────────────────────────────────────────

enum PodcastDownloadState { idle, downloading, downloaded, failed }

// ── Isolated storage helper ───────────────────────────────────────────────────

/// Handles SharedPreferences access for download metadata.
/// Swap this class (e.g. to Hive/SQLite) without touching [PodcastDownloadControllerImp].
class _PodcastDownloadStorage {
  static final _key = StorageKeys.podcastDownloadsMeta;

  Map<String, dynamic> _raw() {
    final raw = Shared.getValue(_key);
    if (raw == null) return {};
    try {
      return json.decode(raw.toString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _save(Map<String, dynamic> data) {
    Shared.setValue(_key, json.encode(data));
  }

  void saveMetadata(int id, Map<String, dynamic> meta) {
    final all = _raw();
    all[id.toString()] = meta;
    _save(all);
  }

  Map<String, dynamic>? getMetadata(int id) {
    return _raw()[id.toString()] as Map<String, dynamic>?;
  }

  void deleteMetadata(int id) {
    final all = _raw();
    all.remove(id.toString());
    _save(all);
  }

  Map<String, Map<String, dynamic>> getAllMetadata() {
    final raw = _raw();
    final result = <String, Map<String, dynamic>>{};
    for (final e in raw.entries) {
      if (e.value is Map) {
        result[e.key] = Map<String, dynamic>.from(e.value as Map);
      }
    }
    return result;
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class PodcastDownloadControllerImp extends GetxController {
  final _storage = _PodcastDownloadStorage();
  final _podcastsData = PodcastsData();

  final RxMap<int, PodcastDownloadState> states = <int, PodcastDownloadState>{}.obs;
  final RxMap<int, double> progressFraction = <int, double>{}.obs;

  /// Per-active download cancel handles (Dio).
  final Map<int, CancelToken> _cancelTokens = <int, CancelToken>{};

  /// `true` when API [updated_at] differs from the revision stored at download time.
  final RxMap<int, bool> staleByPodcastId = <int, bool>{}.obs;

  // ── Public metadata accessor (for UI) ────────────────────────────────────────

  Map<String, dynamic>? metadataForId(int id) => _storage.getMetadata(id);
  Map<String, Map<String, dynamic>> allMetadata() => _storage.getAllMetadata();

  // ── Directory / paths ─────────────────────────────────────────────────────────

  Future<Directory> _podcastsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/podcasts');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _fileNameForId(int id) => 'podcast_$id.mp3';

  Future<String> filePathForId(int id) async {
    final dir = await _podcastsDir();
    return '${dir.path}/${_fileNameForId(id)}';
  }

  bool isDownloaded(int id) => states[id] == PodcastDownloadState.downloaded;

  String? localPathIfExists(int id) {
    final meta = _storage.getMetadata(id);
    final path = meta?['local_path']?.toString();
    if (path != null && File(path).existsSync()) return path;
    return null;
  }

  // ── Hydrate from storage ──────────────────────────────────────────────────────

  Future<void> hydrateFromStorage() async {
    final all = _storage.getAllMetadata();
    for (final entry in all.entries) {
      final id = int.tryParse(entry.key);
      if (id == null) continue;
      final path = entry.value['local_path']?.toString();
      if (path != null && File(path).existsSync()) {
        states[id] = PodcastDownloadState.downloaded;
      } else {
        _storage.deleteMetadata(id);
      }
    }
    states.refresh();
  }

  // ── Download ──────────────────────────────────────────────────────────────────

  Future<void> download(PodcastModel podcast) async {
    if (states[podcast.id] == PodcastDownloadState.downloading) return;
    if (states[podcast.id] == PodcastDownloadState.downloaded) return;

    _cancelTokens[podcast.id]?.cancel();
    final token = CancelToken();
    _cancelTokens[podcast.id] = token;

    states[podcast.id] = PodcastDownloadState.downloading;
    progressFraction[podcast.id] = 0.0;
    staleByPodcastId.remove(podcast.id);
    states.refresh();

    var savePath = '';
    try {
      final detailRes = await _podcastsData.getPodcast(podcast.id);
      if (!detailRes.isSuccess || detailRes.data == null) {
        throw Exception('Failed to fetch podcast detail');
      }
      final detail = PodcastDetailModel.fromJson(
        detailRes.data as Map<String, dynamic>,
      );
      final url = detail.downloadUrl ?? detail.streamUrl;
      if (url == null) {
        throw Exception('No downloadable URL');
      }

      savePath = await filePathForId(podcast.id);
      final api = Get.find<ApiService>();
      await api.dio.download(
        url,
        savePath,
        cancelToken: token,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progressFraction[podcast.id] = received / total;
          }
        },
      );

      _storage.saveMetadata(podcast.id, {
        'local_path': savePath,
        'title': podcast.title,
        'cover_image': podcast.coverImage,
        'duration_seconds': podcast.durationSeconds,
        'downloaded_at': DateTime.now().toIso8601String(),
        if (detail.updatedAt != null && detail.updatedAt!.isNotEmpty)
          'source_updated_at': detail.updatedAt,
      });

      states[podcast.id] = PodcastDownloadState.downloaded;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
        states[podcast.id] = PodcastDownloadState.idle;
        await _deleteFileQuietly(savePath);
      } else {
        states[podcast.id] = PodcastDownloadState.failed;
        await _deleteFileQuietly(savePath);
      }
    } catch (_) {
      states[podcast.id] = PodcastDownloadState.failed;
      await _deleteFileQuietly(savePath);
    } finally {
      _cancelTokens.remove(podcast.id);
      progressFraction.remove(podcast.id);
      states.refresh();
    }
  }

  Future<void> _deleteFileQuietly(String path) async {
    if (path.isEmpty) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Stops an in-flight download and removes any partial file.
  void cancelDownload(int id) {
    _cancelTokens[id]?.cancel();
  }

  // ── Compare server revision vs local metadata (replaced audio on server) ─────

  /// Call when opening the downloads screen or pull-to-refresh.
  Future<void> checkAllDownloadedFreshness() async {
    final entries = states.entries
        .where((e) => e.value == PodcastDownloadState.downloaded)
        .map((e) => e.key)
        .toList();
    for (final id in entries) {
      await checkFreshnessForId(id);
    }
  }

  Future<void> checkFreshnessForId(int id) async {
    final meta = _storage.getMetadata(id);
    if (meta == null) {
      staleByPodcastId[id] = false;
      return;
    }
    final saved = meta['source_updated_at']?.toString();
    if (saved == null || saved.isEmpty) {
      staleByPodcastId[id] = false;
      return;
    }

    try {
      final res = await _podcastsData.getPodcast(id);
      if (!res.isSuccess || res.data == null) {
        return;
      }
      final detail = PodcastDetailModel.fromJson(res.data as Map<String, dynamic>);
      final remote = detail.updatedAt ?? '';
      staleByPodcastId[id] = remote.isNotEmpty && remote != saved;
    } catch (_) {
      // Keep previous stale flag
    }
  }

  /// Deletes local file + metadata, then downloads again from API URLs.
  Future<void> replaceWithLatestFromServer(int id) async {
    final res = await _podcastsData.getPodcast(id);
    if (!res.isSuccess || res.data == null) return;
    final detail = PodcastDetailModel.fromJson(res.data as Map<String, dynamic>);
    await delete(id);
    states[id] = PodcastDownloadState.idle;
    states.refresh();
    await download(detail);
  }

  // ── Delete ────────────────────────────────────────────────────────────────────

  Future<void> delete(int id) async {
    cancelDownload(id);
    final path = localPathIfExists(id);
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    _storage.deleteMetadata(id);
    states.remove(id);
    progressFraction.remove(id);
    staleByPodcastId.remove(id);
    states.refresh();
  }
}
