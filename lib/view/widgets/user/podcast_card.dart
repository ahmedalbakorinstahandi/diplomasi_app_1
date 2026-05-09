import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/controllers/user/podcasts_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastCard extends StatelessWidget {
  const PodcastCard({super.key, required this.podcast, this.onPlay});
  final PodcastModel podcast;
  final VoidCallback? onPlay;

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final rem = m % 60;
      return '${h}س ${rem.toString().padLeft(2, '0')}د';
    }
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final downloads = Get.find<PodcastDownloadControllerImp>();
    final player = Get.find<PodcastPlayerControllerImp>();

    return GestureDetector(
      onTap: () {
        if (podcast.isLocked) {
          Get.find<PodcastsControllerImp>().play(podcast);
          return;
        }
        Get.toNamed(AppRoutes.podcastPlayer, arguments: podcast);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height(12)),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(width(14)),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(width(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(width(10)),
                child: SizedBox(
                  width: width(72),
                  height: width(72),
                  child: podcast.coverImage != null
                      ? CachedNetworkImage(
                          imageUrl: podcast.coverImage!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _CoverPlaceholder(scheme: scheme),
                        )
                      : _CoverPlaceholder(scheme: scheme),
                ),
              ),
              SizedBox(width: width(12)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with lock
                    Row(
                      children: [
                        if (podcast.isLocked)
                          Padding(
                            padding: EdgeInsets.only(left: width(4)),
                            child: Icon(
                              Icons.lock_rounded,
                              size: width(14),
                              color: scheme.primary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            podcast.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: emp(14),
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (podcast.description != null && podcast.description!.isNotEmpty) ...[
                      SizedBox(height: height(4)),
                      Text(
                        podcast.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: emp(12),
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],

                    SizedBox(height: height(8)),

                    // Duration + progress bar
                    if (!podcast.isLocked && podcast.durationSeconds > 0)
                      _ProgressRow(podcast: podcast, colors: colors, scheme: scheme),

                    SizedBox(height: height(8)),

                    // Bottom row: duration label, badges, actions
                    Row(
                      children: [
                        if (podcast.durationSeconds > 0)
                          Text(
                            _formatDuration(podcast.durationSeconds),
                            style: TextStyle(
                              fontSize: emp(11),
                              color: colors.textMuted,
                            ),
                          ),
                        if (podcast.isFree)
                          Padding(
                            padding: EdgeInsets.only(right: width(6)),
                            child: _Badge(label: 'مجاني', color: colors.success),
                          ),
                        const Spacer(),
                        // Favorite button
                        Obx(() {
                          final isFav = Get.find<PodcastsControllerImp>()
                              .podcasts
                              .firstWhereOrNull((p) => p.id == podcast.id)
                              ?.isFavorite ?? podcast.isFavorite;
                          return _IconBtn(
                            icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? scheme.error : colors.textMuted,
                            onTap: () => Get.find<PodcastsControllerImp>().toggleFavorite(podcast),
                          );
                        }),
                        // Download button
                        if (!podcast.isLocked && podcast.allowDownload)
                          Obx(() {
                            final state = downloads.states[podcast.id] ?? PodcastDownloadState.idle;
                            if (state == PodcastDownloadState.downloading) {
                              return Padding(
                                padding: EdgeInsets.all(width(8)),
                                child: SizedBox(
                                  width: width(16),
                                  height: width(16),
                                  child: CircularProgressIndicator(
                                    value: downloads.progressFraction[podcast.id],
                                    strokeWidth: 2,
                                    color: scheme.primary,
                                  ),
                                ),
                              );
                            } else if (state == PodcastDownloadState.downloaded) {
                              return _IconBtn(
                                icon: Icons.download_done_rounded,
                                color: colors.success,
                                onTap: () {},
                              );
                            }
                            return _IconBtn(
                              icon: Icons.download_rounded,
                              color: colors.textMuted,
                              onTap: () => downloads.download(podcast),
                            );
                          }),
                        // Play button
                        if (!podcast.isLocked)
                          Obx(() {
                            final isCurrent = player.currentPodcast.value?.id == podcast.id;
                            final isPlaying = player.isPlaying.value && isCurrent;
                            return _IconBtn(
                              icon: isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                              color: scheme.primary,
                              size: width(32),
                              onTap: () {
                                if (isCurrent) {
                                  player.togglePlayPause();
                                } else {
                                  Get.find<PodcastsControllerImp>().play(podcast);
                                }
                              },
                            );
                          }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.podcast, required this.colors, required this.scheme});
  final PodcastModel podcast;
  final AppColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final pct = podcast.progress.progressPercentage / 100.0;
    if (pct <= 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: height(3),
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
        SizedBox(height: height(2)),
        if (podcast.progress.isCompleted)
          Text(
            'مكتمل ✓',
            style: TextStyle(fontSize: emp(10), color: colors.success),
          ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.primaryContainer,
      child: Icon(Icons.headphones_rounded, color: scheme.primary),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.color, required this.onTap, this.size});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, color: color, size: size ?? 22),
      ),
    );
  }
}
