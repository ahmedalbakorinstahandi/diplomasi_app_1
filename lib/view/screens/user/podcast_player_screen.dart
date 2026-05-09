import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/user/podcasts_controller.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastPlayerScreen extends StatefulWidget {
  const PodcastPlayerScreen({super.key});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  late final PodcastPlayerControllerImp _player;

  @override
  void initState() {
    super.initState();
    _player = Get.find<PodcastPlayerControllerImp>();
    // If opened via card tap (with arguments), start playback.
    // If opened from mini-player (no arguments), just show current.
    final arg = Get.arguments;
    if (arg is PodcastModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _player.playFromModel(arg);
      });
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(() {
          final podcast = _player.currentPodcast.value;
          if (podcast == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headphones_rounded, size: 64, color: colors.textMuted),
                  SizedBox(height: height(12)),
                  Text('لا يوجد محتوى قيد التشغيل', style: TextStyle(color: colors.textSecondary)),
                ],
              ),
            );
          }

          final pos = _player.position.value;
          final dur = _player.duration.value ?? Duration(seconds: podcast.durationSeconds);
          final progress = dur.inSeconds > 0
              ? (pos.inSeconds / dur.inSeconds).clamp(0.0, 1.0)
              : 0.0;

          return Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(8), vertical: height(4)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: width(28)),
                      onPressed: Get.back,
                      color: scheme.onSurface,
                    ),
                    const Spacer(),
                    Text(
                      'يعزف الآن',
                      style: TextStyle(
                        fontSize: emp(14),
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    _FavoriteButton(podcast: podcast, player: _player),
                  ],
                ),
              ),

              SizedBox(height: height(16)),

              // Cover art
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(32)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: podcast.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: podcast.coverImage!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _CoverFallback(scheme: scheme),
                          )
                        : _CoverFallback(scheme: scheme),
                  ),
                ),
              ),

              SizedBox(height: height(24)),

              // Title + description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(24)),
                child: Column(
                  children: [
                    Text(
                      podcast.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: emp(18),
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                    if (podcast.description != null && podcast.description!.isNotEmpty) ...[
                      SizedBox(height: height(6)),
                      Text(
                        podcast.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: emp(13),
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: height(24)),

              // Progress slider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(20)),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: dur.inSeconds > 0
                            ? (v) => _player.seekTo(Duration(seconds: (v * dur.inSeconds).round()))
                            : null,
                        activeColor: scheme.primary,
                        inactiveColor: colors.border,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(pos),
                              style: TextStyle(fontSize: emp(12), color: colors.textMuted)),
                          Text(
                            dur.inSeconds > 0 ? '-${_fmt(dur - pos)}' : '--:--',
                            style: TextStyle(fontSize: emp(12), color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height(8)),

              // Controls row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous episode
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: _player.hasPrevious.value
                                ? scheme.onSurface
                                : colors.textMuted,
                          ),
                          iconSize: width(30),
                          tooltip: 'الحلقة السابقة',
                          onPressed: _player.hasPrevious.value
                              ? _player.skipToPrevious
                              : null,
                        )),

                    // Skip backward 30 s
                    IconButton(
                      icon: const Icon(Icons.replay_30_rounded),
                      iconSize: width(28),
                      color: scheme.onSurface,
                      onPressed: () => _player.skipBackward(seconds: 30),
                    ),

                    // Play / Pause
                    Obx(() => GestureDetector(
                          onTap: _player.togglePlayPause,
                          child: Container(
                            width: width(64),
                            height: width(64),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _player.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: scheme.onPrimary,
                              size: width(34),
                            ),
                          ),
                        )),

                    // Skip forward 30 s
                    IconButton(
                      icon: const Icon(Icons.forward_30_rounded),
                      iconSize: width(28),
                      color: scheme.onSurface,
                      onPressed: () => _player.skipForward(seconds: 30),
                    ),

                    // Next episode
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: _player.hasNext.value
                                ? scheme.onSurface
                                : colors.textMuted,
                          ),
                          iconSize: width(30),
                          tooltip: 'الحلقة التالية',
                          onPressed: _player.hasNext.value
                              ? _player.skipToNext
                              : null,
                        )),
                  ],
                ),
              ),

              SizedBox(height: height(16)),

              // Bottom row: speed + repeat + sleep
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(24)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Speed selector
                    Obx(() => GestureDetector(
                          onTap: () => _showSpeedSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_player.speed.value}x',
                              style: TextStyle(
                                fontSize: emp(13),
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        )),

                    // Repeat
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.repeat_one_rounded,
                            color: _player.repeatOne.value ? scheme.primary : colors.textMuted,
                          ),
                          onPressed: _player.toggleRepeat,
                          tooltip: 'تكرار',
                        )),

                    // Sleep timer
                    IconButton(
                      icon: Icon(Icons.bedtime_rounded, color: colors.textMuted),
                      onPressed: () => _showSleepSheet(context),
                      tooltip: 'مؤقت النوم',
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          );
        }),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سرعة التشغيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _player.speedPresets.map((s) {
                      final selected = _player.speed.value == s;
                      return ChoiceChip(
                        label: Text('${s}x'),
                        selected: selected,
                        onSelected: (_) {
                          _player.setPlaybackSpeed(s);
                          Get.back();
                        },
                        selectedColor: scheme.primary,
                        labelStyle: TextStyle(
                          color: selected ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  void _showSleepSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final options = [
      (5, '5 دقائق'),
      (10, '10 دقائق'),
      (15, '15 دقيقة'),
      (30, '30 دقيقة'),
    ];
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مؤقت النوم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((o) => ListTile(
                    title: Text(o.$2),
                    onTap: () {
                      _player.setSleepTimerMinutes(o.$1);
                      Get.back();
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
              ListTile(
                title: const Text('نهاية الحلقة'),
                onTap: () {
                  _player.setSleepEndOfEpisode();
                  Get.back();
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              ListTile(
                title: Text('إلغاء المؤقت', style: TextStyle(color: scheme.error)),
                onTap: () {
                  _player.setSleepTimerMinutes(null);
                  Get.back();
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: scheme.surface,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.podcast, required this.player});
  final PodcastDetailModel podcast;
  final PodcastPlayerControllerImp player;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Optimistic: read from list controller if available
    final listCtl = Get.isRegistered<PodcastsControllerImp>()
        ? Get.find<PodcastsControllerImp>()
        : null;

    return Obx(() {
      bool isFav = podcast.isFavorite;
      if (listCtl != null) {
        isFav = listCtl.podcasts
                .firstWhereOrNull((p) => p.id == podcast.id)
                ?.isFavorite ??
            podcast.isFavorite;
      }
      return IconButton(
        icon: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFav ? scheme.error : scheme.onSurface,
        ),
        onPressed: listCtl != null ? () => listCtl.toggleFavorite(podcast) : null,
      );
    });
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.primaryContainer,
      child: Icon(
        Icons.headphones_rounded,
        size: 80,
        color: scheme.primary,
      ),
    );
  }
}
