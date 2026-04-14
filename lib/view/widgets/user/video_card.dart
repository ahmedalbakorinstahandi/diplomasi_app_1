import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/video_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    required this.isSelected,
    required this.onTap,
  });

  final VideoModel video;
  final bool isSelected;
  final VoidCallback onTap;

  String? _getVideoId() {
    return YoutubePlayer.convertUrlToId(video.videoUrl);
  }

  String _getThumbnailUrl() {
    final videoId = _getVideoId();
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final videoId = _getVideoId();
    final thumbnailUrl = _getThumbnailUrl();
    final displayTitle = video.title.trim().isNotEmpty ? video.title : 'فيديو تعليمي';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: height(12)),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withOpacity(0.1)
              : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(width(12)),
          border: Border.all(
            color: isSelected ? scheme.primary : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(width(12)),
                bottomRight: Radius.circular(width(12)),
              ),
              child: Container(
                width: width(120),
                height: height(80),
                color: colors.border,
                child: thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            color: colors.border,
                            child: Icon(
                              Icons.play_circle_outline,
                              size: width(40),
                              color: colors.textSecondary,
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.play_circle_outline,
                        size: width(40),
                        color: colors.textSecondary,
                      ),
              ),
            ),
            SizedBox(width: width(12)),
            // Video Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: height(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: width(16),
                          color: isSelected
                              ? scheme.primary
                              : colors.textSecondary,
                        ),
                        SizedBox(width: width(6)),
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: TextStyle(
                              fontSize: emp(14),
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height(4)),
                    Text(
                      videoId != null ? 'YouTube' : 'فيديو',
                      style: TextStyle(
                        fontSize: emp(12),
                        fontWeight: FontWeight.w400,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Selected Indicator
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: width(12)),
                child: Icon(
                  Icons.check_circle,
                  size: width(20),
                  color: scheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
