import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? videoId;
  final ValueChanged<bool>? onFullScreenChange;

  const LessonVideoPlayer({
    super.key,
    required this.videoUrl,
    this.videoId,
    this.onFullScreenChange,
  });

  @override
  State<LessonVideoPlayer> createState() => LessonVideoPlayerState();
}

class LessonVideoPlayerState extends State<LessonVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _wasFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    String? videoId = widget.videoId;

    // Extract video ID from URL if not provided
    if (videoId == null && widget.videoUrl.isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    }

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
        ),
      )..addListener(_listener);
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted && _controller!.value.isReady) {
      setState(() {});
    }
    final isFullScreen = _controller?.value.isFullScreen ?? false;
    if (isFullScreen != _wasFullScreen) {
      _wasFullScreen = isFullScreen;
      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      widget.onFullScreenChange?.call(isFullScreen);
    }
  }

  void pause() {
    if (_controller != null && _isPlayerReady && _controller!.value.isPlaying) {
      _controller!.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    if (_controller == null) {
      return Container(
        height: height(200),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'لا يمكن تحميل الفيديو',
            style: TextStyle(color: scheme.onSurface),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: width(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: scheme.primary,
            progressColors: ProgressBarColors(
              playedColor: scheme.primary,
              handleColor: scheme.primary,
            ),
            onReady: () {
              _isPlayerReady = true;
            },
          ),
          builder: (context, player) {
            return player;
          },
        ),
      ),
    );
  }
}
