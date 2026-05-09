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

    states[podcast.id] = PodcastDownloadState.downloading;
    progressFraction[podcast.id] = 0.0;
    states.refresh();

    try {
      // Fetch detail to get stream_url
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

      final savePath = await filePathForId(podcast.id);
      final api = Get.find<ApiService>();
      await api.dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progressFraction[podcast.id] = received / total;
          }
        },
        cancelToken: CancelToken(),
      );

      _storage.saveMetadata(podcast.id, {
        'local_path': savePath,
        'title': podcast.title,
        'cover_image': podcast.coverImage,
        'duration_seconds': podcast.durationSeconds,
        'downloaded_at': DateTime.now().toIso8601String(),
      });

      states[podcast.id] = PodcastDownloadState.downloaded;
    } catch (_) {
      states[podcast.id] = PodcastDownloadState.failed;
    } finally {
      progressFraction.remove(podcast.id);
      states.refresh();
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────────

  Future<void> delete(int id) async {
    final path = localPathIfExists(id);
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    _storage.deleteMetadata(id);
    states.remove(id);
    progressFraction.remove(id);
    states.refresh();
  }
}
