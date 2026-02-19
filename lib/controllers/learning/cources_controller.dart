import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/resource/remote/learning/courses_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class CourcesController extends GetxController {
  CoursesData coursesData = CoursesData();

  bool isLoading = false;
  int perPage = 20;
  int page = 1;
  List courses = [];

  int? currentCourseId;
  int? previousCourseId;

  ScrollController scrollController = ScrollController();

  Future<void> getCources({bool reload = false});
  void selectCourse(int courseId);
}

class CourcesControllerImp extends CourcesController {
  @override
  void onInit() {
    // Load the base/original course ID (the one the app was opened with)
    // This will always be shown with light selection
    previousCourseId = Shared.getValue(StorageKeys.courseId, initialValue: 0);
    if (previousCourseId == 0) {
      previousCourseId = null;
    }

    // Load current course ID (temporarily selected course from navigation)
    // This will be shown with strong selection
    currentCourseId = Shared.getValue('temp_current_course_id', initialValue: 0);
    if (currentCourseId == 0) {
      currentCourseId = null;
    }

    getCources(reload: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getCources();
      }
    });

    super.onInit();
  }

  @override
  Future<void> getCources({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
    }

    isLoading = true;
    update();
    ApiResponse response = await coursesData.get(page: page, perPage: perPage);
    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: courses,
        newData: response.data,
        meta: response.meta!,
        page: page,
      );
    }
    isLoading = false;
    update();
  }

  @override
  void selectCourse(int courseId) {
    // Set new course as current (temporary selection)
    // The previousCourseId (base course) remains unchanged until startLearning
    currentCourseId = courseId;
    // Save temporarily (not to StorageKeys.courseId, as that should only be saved when starting learning)
    Shared.setValue('temp_current_course_id', courseId);
    update();
  }
}
