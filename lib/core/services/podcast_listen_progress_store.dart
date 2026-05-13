import 'dart:convert';
import 'dart:math' as math;

import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';

/// Persists listen positions on device and merges them with API-reported progress
/// so resume works after killing the app or before the last POST finishes.
abstract class PodcastListenProgressStore {
  static Map<String, dynamic> _loadMap() {
    final raw = Shared.getValue(StorageKeys.podcastGuestProgress);
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw.toString());
      if (decoded is Map<String, dynamic>) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  /// Save the furthest known position for [podcastId] (called while listening).
  static void save(int podcastId, int positionSeconds, int? durationSeconds) {
    final map = _loadMap();
    map[podcastId.toString()] = {
      'position_seconds': math.max(0, positionSeconds),
      if (durationSeconds != null && durationSeconds > 0)
        'duration_seconds': durationSeconds,
      'saved_at': DateTime.now().toIso8601String(),
    };
    Shared.setValue(StorageKeys.podcastGuestProgress, json.encode(map));
  }

  static Map<String, dynamic>? _entry(int podcastId) {
    final m = _loadMap()[podcastId.toString()];
    return m is Map<String, dynamic> ? m : null;
  }

  /// Combine server row with local backup (uses max position for resume).
  static PodcastProgressModel mergeProgress(
    PodcastProgressModel server,
    int podcastId,
    int episodeDurationSeconds,
  ) {
    if (server.isCompleted) return server;

    final entry = _entry(podcastId);
    if (entry == null) return server;

    final lPos = (entry['position_seconds'] as num?)?.toInt() ?? 0;
    final lDurStored = (entry['duration_seconds'] as num?)?.toInt();
    final dur = episodeDurationSeconds > 0
        ? episodeDurationSeconds
        : (lDurStored != null && lDurStored > 0 ? lDurStored : 0);

    final sPos = server.positionSeconds;
    final pos = math.max(lPos, sPos);

    if (dur <= 0) {
      if (lPos <= sPos) return server;
      return PodcastProgressModel(
        positionSeconds: pos,
        progressPercentage: server.progressPercentage,
        isCompleted: false,
        lastPlayedAt: server.lastPlayedAt,
      );
    }

    final clamped = math.min(pos, dur);
    final pct = math.min(100.0, math.max(0.0, (clamped / dur) * 100));
    final nearEnd = (dur - clamped) <= 30;
    final completed = pct >= 90.0 || nearEnd;

    return PodcastProgressModel(
      positionSeconds: clamped,
      progressPercentage: pct,
      isCompleted: completed,
      lastPlayedAt: server.lastPlayedAt,
    );
  }

  static PodcastModel mergeIntoPodcast(PodcastModel p) {
    return p.copyWith(progress: mergeProgress(p.progress, p.id, p.durationSeconds));
  }

  static PodcastDetailModel mergeIntoDetail(PodcastDetailModel d) {
    return d.copyWith(
      progress: mergeProgress(d.progress, d.id, d.durationSeconds),
    );
  }

  /// Episodes that should appear under «أكمل الاستماع» when using only local data.
  static bool looksLikeContinueListening(PodcastModel p) {
    final g = mergeIntoPodcast(p);
    return g.progress.positionSeconds > 0 && !g.progress.isCompleted;
  }
}
