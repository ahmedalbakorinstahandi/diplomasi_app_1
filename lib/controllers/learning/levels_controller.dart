import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/resource/remote/learning/levels_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class LevelsController extends GetxController {
  LevelsData levelsData = LevelsData();

  bool isLoading = false;
  int perPage = 20;
  int page = 1;
  List levels = [];
  int? selectedLevelId;
  int? courseId;

  ScrollController scrollController = ScrollController();

  Future<void> getLevels({bool reload = false});
  void selectLevel(int levelId);
  void startLearning();
}

class LevelsControllerImp extends LevelsController {
  @override
  void onInit() {
    courseId = int.tryParse(Get.parameters['id'] ?? '');

    if (courseId == null) {
      Get.back();
      return;
    }

    getLevels(reload: true);
    update();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getLevels();
      }
    });

    super.onInit();
  }

  @override
  Future<void> getLevels({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
    }

    isLoading = true;
    update();
    ApiResponse response = await levelsData.get(
      courseId: courseId!,
      page: page,
      perPage: perPage,
    );
    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: levels,
        newData: response.data,
        meta: response.meta!,
        page: page,
      );
      // Select first level by default if no level is selected
      if (selectedLevelId == null && levels.isNotEmpty) {
        final firstLevel = levels.first as Map<String, dynamic>;
        selectedLevelId = firstLevel['id'] as int;
      }
    }
    isLoading = false;
    update();
  }

  @override
  void selectLevel(int levelId) {
    selectedLevelId = levelId;
    update();
  }

  @override
  void startLearning() {
    // Save the new course as the base course (official selection)
    Shared.setValue(StorageKeys.courseId, courseId!);
    Shared.setValue(StorageKeys.levelId, selectedLevelId!);
    // Clear temporary course selection as we're now officially starting learning
    // The previousCourseId will now come from the updated StorageKeys.courseId
    Shared.remove('temp_current_course_id');
    Get.offAllNamed(AppRoutes.app);
  }
}
