import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool hasNext;
  final bool hasPrevious;
  final bool autoPlay;
  final ValueChanged<bool>? onFullScreenChange;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    this.onNext,
    this.onPrevious,
    this.hasNext = false,
    this.hasPrevious = false,
    this.autoPlay = false,
    this.onFullScreenChange,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _wasFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer(autoPlay: widget.autoPlay);
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
      _initializePlayer(autoPlay: widget.autoPlay);
    } else if (oldWidget.autoPlay != widget.autoPlay && widget.autoPlay) {
      // If autoPlay changed to true, start playing
      if (_controller != null && _isPlayerReady) {
        try {
          _controller!.play();
        } catch (e) {
          // Ignore if controller is disposed
        }
      }
    }
  }

  void _initializePlayer({bool autoPlay = false}) {
    final videoId = YoutubePlayer.convertUrlToId(widget.video.videoUrl);

    if (videoId != null) {
      // Remove listener and dispose old controller safely
      if (_controller != null) {
        _controller!.removeListener(_listener);
        _controller!.dispose();
        _controller = null;
      }

      // Create new controller
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: autoPlay,
          mute: false,
          enableCaption: true,
          loop: false,
        ),
      )..addListener(_listener);
      _isPlayerReady = false;

      // Update state if widget is still mounted
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _listener() {
    if (!mounted || _controller == null) return;

    try {
      if (_controller!.value.isReady && !_isPlayerReady) {
        if (mounted) {
          setState(() {
            _isPlayerReady = true;
          });
        }
      }
      // عند الملء: السماح بالعرض (landscape). عند الخروج: الرجوع للطول (portrait)
      final isFullScreen = _controller!.value.isFullScreen;
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
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
        widget.onFullScreenChange?.call(isFullScreen);
      }
    } catch (e) {
      // Controller might be disposed, ignore
    }
  }

  void pause() {
    if (_controller != null && !_controller!.value.isFullScreen) {
      try {
        _controller!.pause();
      } catch (e) {
        // Controller might be disposed, ignore
      }
    }
  }

  void play() {
    if (_controller != null && !_controller!.value.isFullScreen) {
      try {
        _controller!.play();
      } catch (e) {
        // Controller might be disposed, ignore
      }
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_listener);
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    if (_controller == null) {
      return Container(
        height: height(250),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: width(40),
                color: colors.textSecondary,
              ),
              SizedBox(height: height(8)),
              Text(
                'لا يمكن تحميل الفيديو',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: emp(14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
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
        child: Stack(
          children: [
            if (_controller != null)
              YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: scheme.primary,
                  progressColors: ProgressBarColors(
                    playedColor: scheme.primary,
                    handleColor: scheme.primary,
                    bufferedColor: scheme.primary.withOpacity(0.3),
                    backgroundColor: colors.border,
                  ),
                  onReady: () {
                    if (mounted && _controller != null) {
                      _isPlayerReady = true;
                      setState(() {});
                      // Auto play if enabled and controller is ready
                      if (widget.autoPlay && _controller != null) {
                        try {
                          _controller!.play();
                        } catch (e) {
                          // Ignore if controller is disposed
                        }
                      }
                    }
                  },
                ),
                builder: (context, player) {
                  return player;
                },
              ),
            // Navigation Buttons
            if (_isPlayerReady)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Next Button
                    if (widget.hasNext && widget.onNext != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onNext,
                          child: Container(
                            margin: EdgeInsets.all(width(8)),
                            padding: EdgeInsets.all(width(12)),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: width(24),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(width: width(8)), // Previous Button
                    if (widget.hasPrevious && widget.onPrevious != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onPrevious,
                          child: Container(
                            margin: EdgeInsets.all(width(8)),
                            padding: EdgeInsets.all(width(12)),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: width(24),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(width: width(8)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
