import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Background audio handler for podcasts.
///
/// Wraps [just_audio.AudioPlayer] and bridges it to the [audio_service] system,
/// enabling lock-screen controls, notification controls, and background playback.
///
/// [onSkipToNext] and [onSkipToPrevious] are wired by [PodcastPlayerControllerImp]
/// so that notification buttons, car-head-unit buttons, and Bluetooth media keys
/// all delegate back to the controller's queue logic.
class PodcastAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  /// Called when the system requests "skip to next" (notification, car, BT).
  Future<void> Function()? onSkipToNext;

  /// Called when the system requests "skip to previous" (notification, car, BT).
  Future<void> Function()? onSkipToPrevious;

  /// Whether a next track is available — drives notification button state.
  bool hasNext = false;

  /// Whether a previous track is available — drives notification button state.
  bool hasPrevious = false;

  PodcastAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.durationStream.listen((d) {
      final current = mediaItem.value;
      if (current != null && d != null) {
        mediaItem.add(current.copyWith(duration: d));
      }
    });
  }

  AudioPlayer get player => _player;

  // ── Controls ────────────────────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  /// Skip to the next episode in the controller's queue.
  /// Invoked by Android notification, car head-unit, and BT media keys.
  @override
  Future<void> skipToNext() async {
    await onSkipToNext?.call();
  }

  /// Skip to the previous episode in the controller's queue.
  /// Invoked by Android notification, car head-unit, and BT media keys.
  @override
  Future<void> skipToPrevious() async {
    await onSkipToPrevious?.call();
  }

  Future<void> seekRelative(Duration offset) async {
    final current = _player.position;
    final target = current + offset;
    final duration = _player.duration;
    if (duration != null) {
      final clamped = target < Duration.zero
          ? Duration.zero
          : (target > duration ? duration : target);
      await _player.seek(clamped);
    } else {
      if (target > Duration.zero) await _player.seek(target);
    }
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> loadEpisode(MediaItem item, {Duration? startAt}) async {
    mediaItem.add(item);
    final source = item.extras?['localPath'] != null
        ? AudioSource.file(item.extras!['localPath'] as String)
        : AudioSource.uri(Uri.parse(item.id));

    await _player.setAudioSource(
      source,
      initialPosition: startAt ?? Duration.zero,
    );
  }

  // ── State transform ─────────────────────────────────────────────────────────

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        // Index 0 — enabled only when there is a previous track
        MediaControl.skipToPrevious,
        // Index 1 — play / pause
        if (_player.playing) MediaControl.pause else MediaControl.play,
        // Index 2 — enabled only when there is a next track
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      // Compact notification: show all three (prev · play/pause · next)
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _toAudioProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  AudioProcessingState _toAudioProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
