import 'package:diplomasi_app/controllers/user/videos_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/video_model.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/videos_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/video_card.dart';
import 'package:diplomasi_app/view/widgets/user/video_player_widget.dart';
import 'package:diplomasi_app/view/widgets/user/videos_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VideosControllerImp());
    return GetBuilder<VideosControllerImp>(
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              // Header Section — يُخفى عند ملء شاشة الفيديو
              if (!controller.isVideoFullScreen) const VideosHeader(),
              // Content Section — عند ملء الشاشة: الفيديو فقط (كما في الدروس)
              Expanded(
                child: controller.isVideoFullScreen &&
                        controller.currentVideo != null
                    ? Padding(
                        padding: EdgeInsets.all(width(16)),
                        child: VideoPlayerWidget(
                          key: ValueKey(controller.currentVideo!.id),
                          video: controller.currentVideo!,
                          autoPlay: false,
                          onFullScreenChange: controller.setVideoFullScreen,
                          onNext: controller.currentVideoIndex <
                                  controller.videos.length - 1
                              ? () => controller.nextVideo()
                              : null,
                          onPrevious: controller.currentVideoIndex > 0
                              ? () => controller.previousVideo()
                              : null,
                          hasNext: controller.currentVideoIndex <
                              controller.videos.length - 1,
                          hasPrevious: controller.currentVideoIndex > 0,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await controller.getVideos(reload: true);
                        },
                        child: HandlingListDataView(
                          isLoading: controller.isLoading &&
                              controller.videos.isEmpty,
                          dataIsEmpty: controller.videos.isEmpty,
                          emptyMessage: 'لا توجد فيديوهات',
                          loadingWidget: const VideosScreenShimmer(),
                          child: Column(
                            children: [
                              if (controller.currentVideo != null)
                                Builder(
                                  builder: (context) {
                                    if (controller.shouldAutoPlay) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        controller.shouldAutoPlay = false;
                                        controller.update();
                                      });
                                    }
                                    return Padding(
                                      padding: EdgeInsets.all(width(16)),
                                      child: VideoPlayerWidget(
                                        key: ValueKey(
                                            controller.currentVideo!.id),
                                        video: controller.currentVideo!,
                                        autoPlay: controller.shouldAutoPlay,
                                        onFullScreenChange:
                                            controller.setVideoFullScreen,
                                        onNext: controller.currentVideoIndex <
                                                controller.videos.length - 1
                                            ? () => controller.nextVideo()
                                            : null,
                                        onPrevious:
                                            controller.currentVideoIndex > 0
                                                ? () =>
                                                    controller.previousVideo()
                                                : null,
                                        hasNext: controller.currentVideoIndex <
                                            controller.videos.length - 1,
                                        hasPrevious:
                                            controller.currentVideoIndex > 0,
                                      ),
                                    );
                                  },
                                )
                              else if (!controller.isLoading)
                                Padding(
                                  padding: EdgeInsets.all(width(16)),
                                  child: Builder(
                                    builder: (context) {
                                      final colors = context.appColors;
                                      final scheme =
                                          Theme.of(context).colorScheme;
                                      return Container(
                                        height: height(250),
                                        decoration: BoxDecoration(
                                          color: colors.backgroundSecondary,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'اختر فيديو للمشاهدة',
                                            style: TextStyle(
                                              color: scheme.onSurface
                                                  .withOpacity(0.5),
                                              fontSize: emp(16),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(height: height(16)),
                              Expanded(
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  controller:
                                      controller.videosScrollController,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width(16),
                                  ),
                                  children: [
                                    Text(
                                      'قائمة الفيديوهات',
                                      style: TextStyle(
                                        fontSize: emp(18),
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: height(12)),
                                    ...controller.videos.asMap().entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final videoData = entry.value;
                                      final video = VideoModel.fromJson(
                                        videoData as Map<String, dynamic>,
                                      );
                                      return VideoCard(
                                        video: video,
                                        isSelected: controller
                                                .currentVideoIndex ==
                                            index,
                                        onTap: () {
                                          controller.selectVideo(index);
                                        },
                                      );
                                    }),
                                    if (controller.isLoadingMore)
                                      Padding(
                                        padding: EdgeInsets.all(height(16)),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
