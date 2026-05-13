import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:diplomasi_app/view/widgets/user/podcast_mini_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastDownloadsScreen extends StatefulWidget {
  const PodcastDownloadsScreen({super.key});

  @override
  State<PodcastDownloadsScreen> createState() => _PodcastDownloadsScreenState();
}

class _PodcastDownloadsScreenState extends State<PodcastDownloadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<PodcastDownloadControllerImp>().checkAllDownloadedFreshness();
    });
  }

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<PodcastDownloadControllerImp>();
    final player = Get.find<PodcastPlayerControllerImp>();
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return MyScaffold(
      body: Column(
        children: [
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
                      Icon(Icons.download_done_rounded,
                          size: 64, color: colors.textMuted),
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

              return RefreshIndicator(
                color: scheme.primary,
                onRefresh: () => downloads.checkAllDownloadedFreshness(),
                child: Obx(() {
                  final miniVisible = player.currentPodcast.value != null;
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      width(16),
                      height(8),
                      width(16),
                      miniVisible ? kMiniPlayerHeight + height(16) : height(16),
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: downloadedEntries.length,
                    itemBuilder: (ctx, i) {
                      final id = downloadedEntries[i].key;
                      final meta = downloads.metadataForId(id) ?? {};
                      final title = meta['title']?.toString() ?? 'حلقة #$id';
                      final coverImage = meta['cover_image']?.toString();
                      final durationSec =
                          (meta['duration_seconds'] as num?)?.toInt() ?? 0;
                      final localPath = downloads.localPathIfExists(id);

                      return Obx(() {
                        final isStale =
                            downloads.staleByPodcastId[id] == true;
                        final isCurrent = player.currentPodcast.value?.id == id;
                        final isPlaying =
                            player.isPlaying.value && isCurrent;

                        return Container(
                          margin: EdgeInsets.only(bottom: height(10)),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isStale
                                  ? scheme.tertiary.withOpacity(0.5)
                                  : colors.border,
                            ),
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
                                        errorBuilder: (_, __, ___) =>
                                            _DownloadCoverFallback(scheme: scheme),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.download_done_rounded,
                                        size: 12, color: colors.success),
                                    SizedBox(width: width(4)),
                                    Text(
                                      'محمّل${durationSec > 0 ? ' · ${durationSec ~/ 60} د' : ''}',
                                      style: TextStyle(
                                          fontSize: emp(11), color: colors.success),
                                    ),
                                  ],
                                ),
                                if (isStale) ...[
                                  SizedBox(height: height(4)),
                                  Text(
                                    'يتوفر ملف أحدث على السيرفر',
                                    style: TextStyle(
                                      fontSize: emp(11),
                                      color: scheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: TextButton(
                                      onPressed: () =>
                                          downloads.replaceWithLatestFromServer(id),
                                      child: const Text('تحديث التحميل'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                IconButton(
                                  icon: Icon(Icons.delete_rounded,
                                      color: scheme.error, size: width(22)),
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
    required super.id,
    required super.title,
    super.coverImage,
    super.durationSeconds = 0,
    super.streamUrl,
  }) : super(
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
        );
}
