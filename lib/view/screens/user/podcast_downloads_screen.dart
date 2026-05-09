import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastDownloadsScreen extends StatelessWidget {
  const PodcastDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<PodcastDownloadControllerImp>();
    final player = Get.find<PodcastPlayerControllerImp>();
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return MyScaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width(16),
              vertical: height(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: Get.back,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: scheme.onSurface,
                ),
                SizedBox(width: width(8)),
                Text(
                  'الحلقات المحملة',
                  style: TextStyle(
                    fontSize: emp(20),
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              final downloadedEntries = downloads.states.entries
                  .where((e) => e.value == PodcastDownloadState.downloaded)
                  .toList();

              if (downloadedEntries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_done_rounded, size: 64, color: colors.textMuted),
                      SizedBox(height: height(16)),
                      Text(
                        'لا توجد حلقات محملة',
                        style: TextStyle(
                          fontSize: emp(16),
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: height(8)),
                      Text(
                        'حمّل حلقات للاستماع بدون إنترنت',
                        style: TextStyle(fontSize: emp(13), color: colors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(width(16)),
                itemCount: downloadedEntries.length,
                itemBuilder: (ctx, i) {
                  final id = downloadedEntries[i].key;
                  final meta = downloads.metadataForId(id) ?? {};
                  final title = meta['title']?.toString() ?? 'حلقة #$id';
                  final coverImage = meta['cover_image']?.toString();
                  final durationSec = (meta['duration_seconds'] as num?)?.toInt() ?? 0;
                  final localPath = downloads.localPathIfExists(id);

                  return Obx(() {
                    final isCurrent = player.currentPodcast.value?.id == id;
                    final isPlaying = player.isPlaying.value && isCurrent;

                    return Container(
                      margin: EdgeInsets.only(bottom: height(10)),
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width(12),
                          vertical: height(6),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: width(48),
                            height: width(48),
                            child: coverImage != null
                                ? Image.network(
                                    coverImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _DownloadCoverFallback(scheme: scheme),
                                  )
                                : _DownloadCoverFallback(scheme: scheme),
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: emp(13),
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.download_done_rounded, size: 12, color: colors.success),
                            SizedBox(width: width(4)),
                            Text(
                              'محمّل${durationSec > 0 ? ' · ${durationSec ~/ 60} د' : ''}',
                              style: TextStyle(fontSize: emp(11), color: colors.success),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play/Pause
                            if (localPath != null)
                              IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_rounded
                                      : Icons.play_circle_rounded,
                                  color: scheme.primary,
                                  size: width(30),
                                ),
                                onPressed: () {
                                  if (isCurrent) {
                                    player.togglePlayPause();
                                  } else {
                                    // Build a minimal model from metadata
                                    player.playFromModel(
                                      _OfflineModel(
                                        id: id,
                                        title: title,
                                        coverImage: coverImage,
                                        durationSeconds: durationSec,
                                        streamUrl: 'file://$localPath',
                                      ),
                                    );
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            // Delete
                            IconButton(
                              icon: Icon(Icons.delete_rounded, color: scheme.error, size: width(22)),
                              onPressed: () => downloads.delete(id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DownloadCoverFallback extends StatelessWidget {
  const _DownloadCoverFallback({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.primaryContainer,
      child: Icon(Icons.headphones_rounded, color: scheme.primary, size: 20),
    );
  }
}

/// Minimal synthetic model for playing an offline file from the downloads screen.
class _OfflineModel extends PodcastDetailModel {
  _OfflineModel({
    required int id,
    required String title,
    String? coverImage,
    int durationSeconds = 0,
    String? streamUrl,
  }) : super(
          id: id,
          title: title,
          coverImage: coverImage,
          durationSeconds: durationSeconds,
          isFree: true,
          requiresSubscription: false,
          allowDownload: true,
          isLocked: false,
          progress: PodcastProgressModel(
            positionSeconds: 0,
            progressPercentage: 0,
            isCompleted: false,
          ),
          isFavorite: false,
          streamUrl: streamUrl,
        );
}
