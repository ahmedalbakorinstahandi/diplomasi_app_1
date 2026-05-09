import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/podcast_audio_handler.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/podcasts_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastPlayerControllerImp extends GetxController
    with WidgetsBindingObserver {
  final PodcastAudioHandler _handler;
  final _podcastsData = PodcastsData();

  PodcastPlayerControllerImp(this._handler);

  // ── Observables ──────────────────────────────────────────────────────────────
  final Rxn<PodcastDetailModel> currentPodcast = Rxn();
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rxn<Duration> duration = Rxn();
  final RxDouble speed = 1.0.obs;
  final RxBool repeatOne = false.obs;
  final Rxn<DateTime> sleepTimerEndsAt = Rxn();

  // ── Queue ────────────────────────────────────────────────────────────────────
  final RxList<PodcastModel> _queue = <PodcastModel>[].obs;
  int _queueIndex = -1;

  /// True when there is a next episode in the current queue.
  final RxBool hasNext = false.obs;

  /// True when there is a previous episode in the current queue.
  final RxBool hasPrevious = false.obs;

  // ── Favorite state ────────────────────────────────────────────────────────
  /// Reactive favorite flag for the currently-playing episode.
  /// Updated optimistically when the user taps the heart in the player screen.
  final RxBool currentIsFavorite = false.obs;

  /// Emits (podcastId, newFavoriteValue) whenever the player toggles a favorite.
  /// PodcastsControllerImp listens to this so the list stays in sync without
  /// creating a circular import.
  final Rxn<(int, bool)> lastFavouriteToggle = Rxn<(int, bool)>();

  final List<double> speedPresets = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Timer? _syncTimer;
  Timer? _sleepTimer;
  StreamSubscription? _playbackStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _completedSub;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Wire handler callbacks so notifications, car controls, and BT keys work.
    _handler.onSkipToNext = skipToNext;
    _handler.onSkipToPrevious = skipToPrevious;

    _playbackStateSub = _handler.playbackState.listen((state) {
      isPlaying.value = state.playing;
    });

    _positionSub = AudioService.position.listen((p) {
      position.value = p;
    });

    _handler.player.durationStream.listen((d) {
      duration.value = d;
    });

    _completedSub = _handler.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onEpisodeCompleted();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _playbackStateSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _syncTimer?.cancel();
    _sleepTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _syncProgressNow();
    }
  }

  // ── Queue management ──────────────────────────────────────────────────────────

  /// Sets the playback queue and the index of the episode the user tapped.
  /// Call this before [playFromModel] whenever you play from a list.
  void setQueue(List<PodcastModel> queue, int index) {
    _queue.assignAll(queue);
    _queueIndex = index;
    _updateQueueFlags();
  }

  void _updateQueueFlags() {
    // Buttons are active whenever the queue has more than one episode
    // (navigation wraps around, so there is always a next/previous).
    final canSkip = _queue.length > 1;
    hasNext.value = canSkip;
    hasPrevious.value = canSkip;
    _handler.hasNext = canSkip;
    _handler.hasPrevious = canSkip;
    // Do NOT call _handler.playbackState.add() here — that stream is already
    // piped from _player.playbackEventStream and cannot be written to manually.
  }

  /// Skip to the next episode — wraps around to the first when at the end.
  /// Called internally and by [PodcastAudioHandler] (notification / car / BT).
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    _queueIndex = (_queueIndex + 1) % _queue.length;
    _updateQueueFlags();
    await playFromModel(_queue[_queueIndex]);
  }

  /// Skip to the previous episode — wraps around to the last when at the start.
  /// Called internally and by [PodcastAudioHandler] (notification / car / BT).
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    _queueIndex = (_queueIndex - 1 + _queue.length) % _queue.length;
    _updateQueueFlags();
    await playFromModel(_queue[_queueIndex]);
  }

  // ── Favourite toggle (player-level) ──────────────────────────────────────────

  /// Toggles the favourite status of the currently-playing episode.
  /// Works independently of PodcastsControllerImp; the result is broadcast via
  /// [lastFavouriteToggle] so the list controller can react without a circular import.
  Future<void> toggleFavoriteInPlayer() async {
    final podcast = currentPodcast.value;
    if (podcast == null) return;

    final wasFav = currentIsFavorite.value;
    currentIsFavorite.value = !wasFav; // optimistic

    final res = wasFav
        ? await _podcastsData.removeFavorite(podcast.id)
        : await _podcastsData.addFavorite(podcast.id);

    if (!res.isSuccess) {
      currentIsFavorite.value = wasFav; // revert
    } else {
      lastFavouriteToggle.value = (podcast.id, currentIsFavorite.value);
    }
  }

  Future<void> playFromModel(PodcastModel podcast) async {
    // Save progress of the current episode before switching.
    if (currentPodcast.value != null) {
      _syncProgressNow();
      _syncTimer?.cancel();
    }

    // Resolve detail if needed to get stream_url
    PodcastDetailModel detail;
    if (podcast is PodcastDetailModel && podcast.streamUrl != null) {
      detail = podcast;
    } else {
      final res = await _podcastsData.getPodcast(podcast.id);
      if (!res.isSuccess || res.data == null) return;
      detail = PodcastDetailModel.fromJson(res.data as Map<String, dynamic>);
    }

    // Check for local file
    String? playUrl;
    final downloads = Get.find<PodcastDownloadControllerImp>();
    final localPath = downloads.localPathIfExists(detail.id);
    if (localPath != null) {
      playUrl = localPath;
    } else {
      playUrl = detail.streamUrl;
    }

    if (playUrl == null) return;

    // Determine start position
    final startSec = detail.progress.isCompleted ? 0 : detail.progress.positionSeconds;
    final startAt = Duration(seconds: startSec);

    final item = MediaItem(
      id: localPath != null ? 'file://$localPath' : playUrl,
      title: detail.title,
      album: 'Diplomasi',
      artUri: detail.coverImage != null ? Uri.tryParse(detail.coverImage!) : null,
      duration: Duration(seconds: detail.durationSeconds),
      extras: localPath != null ? {'localPath': localPath} : null,
    );

    await _handler.loadEpisode(item, startAt: startAt);
    currentPodcast.value = detail;
    currentIsFavorite.value = detail.isFavorite;
    await _handler.play();
    _startPeriodicSync();
  }

  Future<void> togglePlayPause() async {
    if (_handler.player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _handler.pause();
    _syncProgressNow();
  }

  Future<void> resume() => _handler.play();

  Future<void> seekTo(Duration position) => _handler.seek(position);

  Future<void> skipForward({int seconds = 30}) =>
      _handler.seekRelative(Duration(seconds: seconds));

  Future<void> skipBackward({int seconds = 30}) =>
      _handler.seekRelative(Duration(seconds: -seconds));

  Future<void> setPlaybackSpeed(double s) async {
    speed.value = s;
    await _handler.setSpeed(s);
  }

  void toggleRepeat() => repeatOne.value = !repeatOne.value;

  void setSleepTimerMinutes(int? minutes) {
    _sleepTimer?.cancel();
    if (minutes == null) {
      sleepTimerEndsAt.value = null;
      return;
    }
    final endsAt = DateTime.now().add(Duration(minutes: minutes));
    sleepTimerEndsAt.value = endsAt;
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      pause();
      sleepTimerEndsAt.value = null;
    });
  }

  void setSleepEndOfEpisode() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerEndsAt.value = null;
    _handler.player.processingStateStream.firstWhere(
      (s) => s == ProcessingState.completed,
    ).then((_) {
      pause();
    }).ignore();
  }

  Future<void> stopAndClear() async {
    _syncProgressNow();
    _syncTimer?.cancel();
    _sleepTimer?.cancel();
    await _handler.stop();
    currentPodcast.value = null;
    _queue.clear();
    _queueIndex = -1;
    _updateQueueFlags();
  }

  // ── Episode completed ─────────────────────────────────────────────────────────

  void _onEpisodeCompleted() {
    _syncProgressNow();
    if (repeatOne.value) {
      _handler.seek(Duration.zero).then((_) => _handler.play());
    } else if (hasNext.value) {
      // Auto-advance to the next episode in the queue.
      skipToNext();
    }
  }

  // ── Progress sync ─────────────────────────────────────────────────────────────

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _syncProgressNow();
    });
  }

  void _syncProgressNow() {
    final podcast = currentPodcast.value;
    if (podcast == null) return;

    final posSeconds = position.value.inSeconds;
    final durSeconds = duration.value?.inSeconds;

    final step = Shared.getValue(StorageKeys.step, initialValue: 0);
    final isLoggedIn = step == Steps.homeApp;

    if (isLoggedIn) {
      _podcastsData.updateProgress(
        podcast.id,
        positionSeconds: posSeconds,
        durationSeconds: durSeconds,
      ).ignore();
    } else {
      _persistGuestProgress(podcast.id, posSeconds, durSeconds);
    }
  }

  void _persistGuestProgress(int podcastId, int posSeconds, int? durSeconds) {
    final raw = Shared.getValue(StorageKeys.podcastGuestProgress);
    Map<String, dynamic> map = {};
    if (raw != null) {
      try {
        map = json.decode(raw.toString()) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[podcastId.toString()] = {
      'position_seconds': posSeconds,
      if (durSeconds != null) 'duration_seconds': durSeconds,
      'saved_at': DateTime.now().toIso8601String(),
    };
    Shared.setValue(StorageKeys.podcastGuestProgress, json.encode(map));
  }
}
