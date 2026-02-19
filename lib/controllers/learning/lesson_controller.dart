import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/learning/lesson_attempt_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_model.dart';
import 'package:diplomasi_app/data/resource/remote/learning/lessons_data.dart';
import 'package:get/get.dart';

abstract class LessonController extends GetxController {
  bool isLoading = false;
  bool isLoadingAttempt = false;

  LessonsData lessonsData = LessonsData();

  LessonModel? lesson;
  LessonAttemptModel? attempt;
  int? lessonId;

  Future<void> getLessonDetails();
  Future<void> startOrResumeAttempt();
  Future<void> markVideoWatched();
  void saveAttemptIdLocally();
  int? getSavedAttemptId();
  void clearAttemptId();
}

class LessonControllerImp extends LessonController {
  @override
  void onInit() {
    lessonId = int.tryParse(Get.parameters['id'] ?? '');
    if (lessonId == null) {
      Get.back();
      return;
    }

    print('lessonId: $lessonId');

    getLessonDetails();
    super.onInit();
  }

  @override
  Future<void> getLessonDetails() async {
    if (isLoading) return;

    isLoading = true;
    update();

    ApiResponse response = await lessonsData.show(lessonId!);
    if (response.isSuccess && response.data != null) {
      lesson = LessonModel.fromJson(response.data as Map<String, dynamic>);
    }

    isLoading = false;
    update();
  }

  @override
  Future<void> startOrResumeAttempt() async {
    if (isLoadingAttempt || lessonId == null) return;

    isLoadingAttempt = true;
    update();

    // Get saved attempt ID if exists (for verification)
    int? savedAttemptId = getSavedAttemptId();

    // Call API to start or resume attempt
    // The API automatically checks for existing in_progress attempts
    // and returns it if found, otherwise creates a new one
    ApiResponse response = await lessonsData.startAttempt(lessonId!);

    if (response.isSuccess && response.data != null) {
      attempt = LessonAttemptModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Verify: If we had a saved attempt, check if API returned the same one
      // This ensures consistency between local storage and server state
      if (savedAttemptId != null && attempt!.id != savedAttemptId) {
        // Server returned a different attempt (maybe old one was finished)
        // Update local storage with the new attempt ID
        saveAttemptIdLocally();
      } else {
        // Either no saved attempt, or API returned the same one
        // Save/update local storage
        saveAttemptIdLocally();
      }
    }

    isLoadingAttempt = false;
    update();
  }

  @override
  Future<void> markVideoWatched() async {
    if (lessonId == null || attempt == null) return;

    try {
      ApiResponse response = await lessonsData.markVideoWatched(
        lessonId: lessonId!,
        attemptId: attempt!.id,
      );

      if (response.isSuccess && response.data != null) {
        // Update attempt model with new data
        attempt = LessonAttemptModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        // Refresh lesson details to get updated progress
        await getLessonDetails();
        update();
      }
    } catch (e) {
      // Handle error silently or show message
      print('Error marking video as watched: $e');
    }
  }

  @override
  void saveAttemptIdLocally() {
    if (attempt != null && lessonId != null) {
      Shared.setValue('${StorageKeys.lessonAttemptId}_$lessonId', attempt!.id);
    }
  }

  @override
  int? getSavedAttemptId() {
    if (lessonId == null) return null;
    return Shared.getValue('${StorageKeys.lessonAttemptId}_$lessonId');
  }

  @override
  void clearAttemptId() {
    if (lessonId != null) {
      Shared.remove('${StorageKeys.lessonAttemptId}_$lessonId');
    }
  }
}
