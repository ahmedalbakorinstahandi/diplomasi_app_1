import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/model/user/video_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/videos_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class VideosController extends GetxController {
  List videos = [];
  int currentVideoIndex = 0;

  bool isLoading = false;
  int page = 1;
  int perPage = 20;
  bool isLoadingMore = false;
  bool shouldAutoPlay = false;
  bool isVideoFullScreen = false;

  VideosData videosData = VideosData();
  ScrollController videosScrollController = ScrollController();

  VideoModel? get currentVideo;

  Future<void> getVideos({bool reload = false});
  void selectVideo(int index);
  void nextVideo();
  void previousVideo();
  void setVideoFullScreen(bool value);
}

class VideosControllerImp extends VideosController {
  @override
  VideoModel? get currentVideo {
    if (videos.isEmpty ||
        currentVideoIndex < 0 ||
        currentVideoIndex >= videos.length) {
      return null;
    }
    return VideoModel.fromJson(
      videos[currentVideoIndex] as Map<String, dynamic>,
    );
  }

  @override
  void onInit() {
    super.onInit();
    getVideos(reload: true);
    videosScrollController.addListener(() {
      if (videosScrollController.position.pixels ==
          videosScrollController.position.maxScrollExtent) {
        getVideos();
      }
    });
  }

  @override
  void onClose() {
    videosScrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> getVideos({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
      currentVideoIndex = 0;
    }

    isLoading = true;
    isLoadingMore = !reload;
    update();

    ApiResponse response = await videosData.get(
      page: page,
      perPage: perPage,
      sortField: 'created_at',
      sortOrder: 'desc',
    );

    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: videos,
        newData: response.data!,
        meta: response.meta!,
        page: page,
        reload: reload,
      );
    }

    isLoading = false;
    isLoadingMore = false;
    update();
  }

  @override
  void selectVideo(int index) {
    if (index >= 0 && index < videos.length) {
      shouldAutoPlay = false;
      currentVideoIndex = index;
      update();
    }
  }

  @override
  void nextVideo() {
    if (currentVideoIndex < videos.length - 1) {
      shouldAutoPlay = true;
      currentVideoIndex++;
      update();
      // Scroll to selected video in list
      _scrollToVideo();
    }
  }

  @override
  void previousVideo() {
    if (currentVideoIndex > 0) {
      shouldAutoPlay = true;
      currentVideoIndex--;
      update();
      // Scroll to selected video in list
      _scrollToVideo();
    }
  }

  @override
  void setVideoFullScreen(bool value) {
    if (isVideoFullScreen != value) {
      isVideoFullScreen = value;
      update();
    }
  }

  void _scrollToVideo() {
    // This will be handled by the UI
  }
}
