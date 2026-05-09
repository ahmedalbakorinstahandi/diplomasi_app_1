import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final PodcastPlayerControllerImp _player;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _player = Get.find<PodcastPlayerControllerImp>();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack),
    );

    if (_player.isPlaying.value) _scaleCtrl.forward();
    ever(_player.isPlaying, (bool playing) {
      playing ? _scaleCtrl.forward() : _scaleCtrl.reverse();
    });

    final arg = Get.arguments;
    if (arg is PodcastModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _player.playFromModel(arg);
      });
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours}:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Obx(() {
        final podcast = _player.currentPodcast.value;

        if (podcast == null) {
          return _EmptyState(colors: colors, scheme: scheme);
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Ambient background ──────────────────────────────────────────
            _AmbientBackground(podcast: podcast, scheme: scheme),

            // ── Foreground content ──────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _TopBar(player: _player, scheme: scheme, colors: colors),
                  const SizedBox(height: 4),

                  // Cover art – shrinks when paused
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width(36)),
                      child: AnimatedBuilder(
                        animation: _scaleAnim,
                        builder: (_, child) =>
                            Transform.scale(scale: _scaleAnim.value, child: child),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                                CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                              ),
                              child: child,
                            ),
                          ),
                          child: _CoverArt(
                            key: ValueKey(podcast.id),
                            podcast: podcast,
                            scheme: scheme,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Episode title + description
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.07),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOut),
                        ),
                        child: child,
                      ),
                    ),
                    child: _EpisodeInfo(
                      key: ValueKey(podcast.id),
                      podcast: podcast,
                      scheme: scheme,
                      colors: colors,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress slider
                  Obx(() {
                    final pos = _player.position.value;
                    final dur = _player.duration.value ??
                        Duration(seconds: podcast.durationSeconds);
                    return _ProgressSection(
                      player: _player,
                      pos: pos,
                      dur: dur,
                      scheme: scheme,
                      colors: colors,
                      fmt: _fmt,
                    );
                  }),

                  const SizedBox(height: 4),

                  // Main transport controls
                  _MainControls(
                    player: _player,
                    scheme: scheme,
                    colors: colors,
                    scaleAnim: _scaleAnim,
                  ),

                  const SizedBox(height: 8),

                  // Secondary: speed · repeat · sleep
                  _SecondaryControls(
                    player: _player,
                    scheme: scheme,
                    colors: colors,
                    onSpeedTap: () => _showSpeedSheet(context),
                    onSleepTap: () => _showSleepSheet(context),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Speed bottom sheet ──────────────────────────────────────────────────────

  void _showSpeedSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'سرعة التشغيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _player.speedPresets.map((s) {
                      final selected = _player.speed.value == s;
                      return ChoiceChip(
                        label: Text('${s}×'),
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
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // ── Sleep bottom sheet ──────────────────────────────────────────────────────

  void _showSleepSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const options = [
      (5, '5 دقائق'),
      (10, '10 دقائق'),
      (15, '15 دقيقة'),
      (30, '30 دقيقة'),
    ];
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'مؤقت النوم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
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
                title: Text('إلغاء المؤقت',
                    style: TextStyle(color: scheme.error)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// ── Ambient blurred background ─────────────────────────────────────────────

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.podcast, required this.scheme});
  final PodcastDetailModel podcast;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (podcast.coverImage == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withOpacity(0.5),
              scheme.surface,
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred cover as ambient colour wash
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
          child: CachedNetworkImage(
            imageUrl: podcast.coverImage!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                Container(color: scheme.primaryContainer),
          ),
        ),
        // Gradient overlay so text is always readable
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface.withOpacity(0.50),
                scheme.surface.withOpacity(0.82),
                scheme.surface.withOpacity(0.96),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.player, required this.scheme, required this.colors});
  final PodcastPlayerControllerImp player;
  final ColorScheme scheme;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(4), vertical: height(4)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 30, color: scheme.onSurface),
            onPressed: Get.back,
            tooltip: 'إغلاق',
          ),
          const Spacer(),
          Text(
            'يعزف الآن',
            style: TextStyle(
              fontSize: emp(13),
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          // Favourite – animated heart
          Obx(() => IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    player.currentIsFavorite.value
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(player.currentIsFavorite.value),
                    color: player.currentIsFavorite.value
                        ? scheme.error
                        : scheme.onSurface.withOpacity(0.75),
                    size: 24,
                  ),
                ),
                onPressed: player.toggleFavoriteInPlayer,
                tooltip: 'المفضلة',
              )),
        ],
      ),
    );
  }
}

// ── Cover art ──────────────────────────────────────────────────────────────

class _CoverArt extends StatelessWidget {
  const _CoverArt(
      {super.key, required this.podcast, required this.scheme});
  final PodcastDetailModel podcast;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.22),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: podcast.coverImage != null
            ? CachedNetworkImage(
                imageUrl: podcast.coverImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, __, ___) => _CoverFallback(scheme: scheme),
              )
            : _CoverFallback(scheme: scheme),
      ),
    );
  }
}

// ── Episode info ───────────────────────────────────────────────────────────

class _EpisodeInfo extends StatelessWidget {
  const _EpisodeInfo(
      {super.key,
      required this.podcast,
      required this.scheme,
      required this.colors});
  final PodcastDetailModel podcast;
  final ColorScheme scheme;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          if (podcast.description != null &&
              podcast.description!.isNotEmpty) ...[
            SizedBox(height: height(6)),
            Text(
              podcast.description!,
              maxLines: 1,
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
    );
  }
}

// ── Progress section ───────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.player,
    required this.pos,
    required this.dur,
    required this.scheme,
    required this.colors,
    required this.fmt,
  });
  final PodcastPlayerControllerImp player;
  final Duration pos;
  final Duration dur;
  final ColorScheme scheme;
  final AppColors colors;
  final String Function(Duration) fmt;

  @override
  Widget build(BuildContext context) {
    final progress =
        dur.inSeconds > 0 ? (pos.inSeconds / dur.inSeconds).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(20)),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.outline.withOpacity(0.18),
              thumbColor: scheme.primary,
              overlayColor: scheme.primary.withOpacity(0.14),
            ),
            child: Slider(
              value: progress,
              onChanged: dur.inSeconds > 0
                  ? (v) => player.seekTo(
                      Duration(seconds: (v * dur.inSeconds).round()))
                  : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fmt(pos),
                    style: TextStyle(
                        fontSize: emp(11), color: colors.textMuted)),
                Text(
                  dur.inSeconds > 0 ? '-${fmt(dur - pos)}' : '--:--',
                  style:
                      TextStyle(fontSize: emp(11), color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main transport controls ────────────────────────────────────────────────

class _MainControls extends StatelessWidget {
  const _MainControls({
    required this.player,
    required this.scheme,
    required this.colors,
    required this.scaleAnim,
  });
  final PodcastPlayerControllerImp player;
  final ColorScheme scheme;
  final AppColors colors;
  final Animation<double> scaleAnim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ◀◀ Previous episode
          Obx(() => _CtrlBtn(
                icon: Icons.skip_previous_rounded,
                size: width(28),
                color: player.hasPrevious.value
                    ? scheme.onSurface
                    : colors.textMuted.withOpacity(0.35),
                onTap: player.hasPrevious.value
                    ? player.skipToPrevious
                    : null,
              )),

          // ↺30 Skip back
          _CtrlBtn(
            icon: Icons.replay_30_rounded,
            size: width(26),
            color: scheme.onSurface.withOpacity(0.82),
            onTap: () => player.skipBackward(seconds: 30),
          ),

          // ▶/⏸ Play-Pause
          Obx(() => _PlayPauseBtn(
                isPlaying: player.isPlaying.value,
                scheme: scheme,
                onTap: player.togglePlayPause,
              )),

          // 30↻ Skip forward
          _CtrlBtn(
            icon: Icons.forward_30_rounded,
            size: width(26),
            color: scheme.onSurface.withOpacity(0.82),
            onTap: () => player.skipForward(seconds: 30),
          ),

          // ▶▶ Next episode
          Obx(() => _CtrlBtn(
                icon: Icons.skip_next_rounded,
                size: width(28),
                color: player.hasNext.value
                    ? scheme.onSurface
                    : colors.textMuted.withOpacity(0.35),
                onTap: player.hasNext.value ? player.skipToNext : null,
              )),
        ],
      ),
    );
  }
}

// ── Secondary controls ─────────────────────────────────────────────────────

class _SecondaryControls extends StatelessWidget {
  const _SecondaryControls({
    required this.player,
    required this.scheme,
    required this.colors,
    required this.onSpeedTap,
    required this.onSleepTap,
  });
  final PodcastPlayerControllerImp player;
  final ColorScheme scheme;
  final AppColors colors;
  final VoidCallback onSpeedTap;
  final VoidCallback onSleepTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Speed pill
          Obx(() {
            final active = player.speed.value != 1.0;
            return GestureDetector(
              onTap: onSpeedTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? scheme.primary.withOpacity(0.12)
                      : scheme.outline.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? scheme.primary.withOpacity(0.4)
                        : colors.border,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  '${player.speed.value}×',
                  style: TextStyle(
                    fontSize: emp(13),
                    fontWeight: FontWeight.w700,
                    color: active ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
            );
          }),

          // Repeat-one toggle
          Obx(() => _SecondaryToggle(
                icon: Icons.repeat_one_rounded,
                active: player.repeatOne.value,
                onTap: player.toggleRepeat,
                scheme: scheme,
                colors: colors,
              )),

          // Sleep timer
          Obx(() => _SecondaryToggle(
                icon: Icons.bedtime_rounded,
                active: player.sleepTimerEndsAt.value != null,
                onTap: onSleepTap,
                scheme: scheme,
                colors: colors,
              )),
        ],
      ),
    );
  }
}

// ── Re-usable small widgets ────────────────────────────────────────────────

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class _PlayPauseBtn extends StatelessWidget {
  const _PlayPauseBtn({
    required this.isPlaying,
    required this.scheme,
    required this.onTap,
  });
  final bool isPlaying;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.45),
                    blurRadius: 26,
                    spreadRadius: 2,
                    offset: const Offset(0, 7),
                  ),
                ]
              : [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: scheme.onPrimary,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _SecondaryToggle extends StatelessWidget {
  const _SecondaryToggle({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.scheme,
    required this.colors,
  });
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              active ? scheme.primary.withOpacity(0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: active ? scheme.primary : colors.textMuted,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.scheme});
  final AppColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones_rounded, size: 72, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            'لا يوجد محتوى قيد التشغيل',
            style:
                TextStyle(fontSize: emp(16), color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.primaryContainer,
      child: Icon(Icons.headphones_rounded, size: 80, color: scheme.primary),
    );
  }
}
