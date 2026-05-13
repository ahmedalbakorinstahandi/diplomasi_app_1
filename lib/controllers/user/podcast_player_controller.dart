import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/podcast_audio_handler.dart';
import 'package:diplomasi_app/core/services/podcast_listen_progress_store.dart';
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
  StreamSubscription? _playingStreamSub;
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

    /// Authoritative for play/pause icon (fixes stuck "pause" after complete, skip, stop).
    _playingStreamSub = _handler.player.playingStream.listen((playing) {
      isPlaying.value = playing;
    });

    _positionSub = AudioService.position.listen((p) {
      // After natural completion AudioService.position can jitter (e.g. back to zero)
      // while processingState stays completed — keep the scrubber pinned to full length.
      if (_handler.player.processingState == ProcessingState.completed) {
        final d = duration.value ?? _handler.player.duration;
        if (d != null && d > Duration.zero) {
          position.value = d;
          return;
        }
      }
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
    _playingStreamSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _syncTimer?.cancel();
    _sleepTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
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

    if (!isUserLoggedIn) {
      customSnackBar(
        text: 'سجّل الدخول لإضافة الحلقات إلى المفضلة',
        snackType: SnackBarType.info,
      );
      return;
    }

    final wasFav = currentIsFavorite.value;
    currentIsFavorite.value = !wasFav; // optimistic

    final res = wasFav
        ? await _podcastsData.removeFavorite(podcast.id)
        : await _podcastsData.addFavorite(podcast.id);

    if (!res.isSuccess) {
      currentIsFavorite.value = wasFav; // revert
      customSnackBar(
        text: 'تعذّر تحديث المفضلة. تحقق من الاتصال وحاول مرة أخرى.',
        snackType: SnackBarType.error,
      );
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
      detail = PodcastListenProgressStore.mergeIntoDetail(podcast);
    } else {
      final res = await _podcastsData.getPodcast(podcast.id);
      if (!res.isSuccess || res.data == null) return;
      detail = PodcastListenProgressStore.mergeIntoDetail(
        PodcastDetailModel.fromJson(res.data as Map<String, dynamic>),
      );
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
    final p = _handler.player;
    // At end of file [playing] can be false but [pause] is wrong — always treat as "play again".
    if (p.processingState == ProcessingState.completed) {
      await resume();
      return;
    }
    if (p.playing) {
      await pause();
      return;
    }
    await resume();
  }

  Future<void> pause() async {
    await _handler.pause();
    _syncProgressNow();
    isPlaying.value = false;
  }

  /// Continues playback; [PodcastAudioHandler.play] seeks to 0 when the episode
  /// had finished (same path as notification / headset play).
  Future<void> resume() async {
    await _handler.play();
  }

  Future<void> seekTo(Duration newPosition) => _handler.seek(newPosition);

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
    // Clear UI state immediately so the mini-player hides even if the platform
    // stop handshake is slow or the audio isolate lags briefly.
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = null;
    currentPodcast.value = null;
    currentIsFavorite.value = false;
    _queue.clear();
    _queueIndex = -1;
    _updateQueueFlags();
    await _handler.stop();
  }

  // ── Episode completed ─────────────────────────────────────────────────────────

  void _onEpisodeCompleted() {
    if (repeatOne.value) {
      _syncProgressNow();
      _handler.seek(Duration.zero).then((_) => _handler.play());
      return;
    }

    // Do not auto-advance the queue here — only [repeatOne] loops. User picks
    // "next" explicitly; otherwise playback stops at the end.
    final d = duration.value ?? _handler.player.duration;
    if (d != null && d > Duration.zero) {
      position.value = d;
    }
    _syncProgressNow();
    isPlaying.value = false;
  }

  // ── Progress sync ─────────────────────────────────────────────────────────────

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _syncProgressNow();
    });
  }

  void _syncProgressNow() {
    final podcast = currentPodcast.value;
    if (podcast == null) return;

    final posSeconds = _handler.player.position.inSeconds;
    final durSeconds =
        _handler.player.duration?.inSeconds ?? duration.value?.inSeconds;

    PodcastListenProgressStore.save(podcast.id, posSeconds, durSeconds);

    final step = Shared.getValue(StorageKeys.step, initialValue: 0);
    final inApp = step == Steps.homeApp;
    if (inApp) {
      _podcastsData
          .updateProgress(
            podcast.id,
            positionSeconds: posSeconds,
            durationSeconds: durSeconds,
          )
          .ignore();
    }
  }
}
