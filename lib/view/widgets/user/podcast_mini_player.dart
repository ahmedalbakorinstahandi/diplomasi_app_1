import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Persistent mini-player shown at the bottom of the app shell while a podcast is playing.
/// Height is fixed at [kMiniPlayerHeight]; screens should add this as bottom padding
/// when it is visible to avoid overlap.
const double kMiniPlayerHeight = 68;

class PodcastMiniPlayer extends StatelessWidget {
  const PodcastMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PodcastPlayerControllerImp>();
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final podcast = player.currentPodcast.value;
      if (podcast == null) return const SizedBox.shrink();

      final duration = player.duration.value ?? Duration(seconds: podcast.durationSeconds);
      final pos = player.position.value;
      final progress = duration.inSeconds > 0
          ? (pos.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
          : 0.0;

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.podcastPlayer),
        child: Container(
          height: kMiniPlayerHeight,
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Thin progress bar at top
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width(12)),
                  child: Row(
                    children: [
                      // Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: width(44),
                          height: width(44),
                          child: podcast.coverImage != null
                              ? CachedNetworkImage(
                                  imageUrl: podcast.coverImage!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: scheme.primaryContainer,
                                    child: Icon(Icons.headphones_rounded, color: scheme.primary, size: 20),
                                  ),
                                )
                              : Container(
                                  color: scheme.primaryContainer,
                                  child: Icon(Icons.headphones_rounded, color: scheme.primary, size: 20),
                                ),
                        ),
                      ),
                      SizedBox(width: width(10)),

                      // Title
                      Expanded(
                        child: Text(
                          podcast.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: emp(13),
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),

                      // Controls
                      // Previous episode
                      Obx(() => IconButton(
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              size: width(24),
                              color: player.hasPrevious.value
                                  ? scheme.onSurface
                                  : colors.textMuted,
                            ),
                            onPressed: player.hasPrevious.value
                                ? player.skipToPrevious
                                : null,
                            tooltip: 'السابق',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )),
                      SizedBox(width: width(2)),

                      // Play / Pause
                      Obx(() => IconButton(
                            icon: Icon(
                              player.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: width(28),
                              color: scheme.primary,
                            ),
                            onPressed: player.togglePlayPause,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )),
                      SizedBox(width: width(2)),

                      // Next episode
                      Obx(() => IconButton(
                            icon: Icon(
                              Icons.skip_next_rounded,
                              size: width(24),
                              color: player.hasNext.value
                                  ? scheme.onSurface
                                  : colors.textMuted,
                            ),
                            onPressed: player.hasNext.value
                                ? player.skipToNext
                                : null,
                            tooltip: 'التالي',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )),
                      SizedBox(width: width(6)),

                      // Close
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: width(20),
                          color: colors.textMuted,
                        ),
                        onPressed: player.stopAndClear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
