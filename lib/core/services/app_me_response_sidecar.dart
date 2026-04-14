import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/bootstrap/courses_mode_payload.dart';
import 'package:diplomasi_app/view/widgets/general/suggest_update_dialog.dart';

class AppMeSidecarOutcome {
  AppMeSidecarOutcome({
    this.mergedSubscriptionPayload = false,
    this.mergedAppUpdateCheckPayload = false,
  });

  final bool mergedSubscriptionPayload;
  final bool mergedAppUpdateCheckPayload;
}

/// Parses top-level keys merged into GET /user/me (outside `data.user`).
class AppMeResponseSidecar {
  AppMeResponseSidecar._();

  /// Call after a successful /user/me response; [body] is the full JSON object.
  static Future<AppMeSidecarOutcome> applyFromMeBody(
    Map<String, dynamic> body, {
    required bool mergeBootstrapPayload,
  }) async {
    var mergedSubscriptionPayload = false;
    var mergedAppUpdateCheckPayload = false;

    final coursesRaw = body['courses_mode'];
    if (coursesRaw != null) {
      final mode = CoursesModePayload.tryParse(coursesRaw);
      if (mode != null) {
        Shared.setValue(StorageKeys.appCoursesCatalog, {
          'has_single_course': mode.hasSingleCourse,
          'total_published_courses': mode.totalPublishedCourses,
        });
        _applySingleCourseSelections(mode);
      }
    }

    if (!mergeBootstrapPayload) {
      return AppMeSidecarOutcome();
    }

    if (body.containsKey('billing_subscription')) {
      mergedSubscriptionPayload = true;
      final sub = body['billing_subscription'];
      if (sub is Map<String, dynamic>) {
        _persistSubscriptionSnapshot(sub);
      } else {
        _persistSubscriptionSnapshot(null);
      }
    }

    if (body.containsKey('app_update_check')) {
      mergedAppUpdateCheckPayload = true;
      final raw = body['app_update_check'];
      if (raw is Map) {
        await _maybeShowSuggestUpdate(Map<String, dynamic>.from(raw));
      }
    }

    return AppMeSidecarOutcome(
      mergedSubscriptionPayload: mergedSubscriptionPayload,
      mergedAppUpdateCheckPayload: mergedAppUpdateCheckPayload,
    );
  }

  static bool get hideCoursesLibrary {
    final m = Shared.getMapValueOrNull(StorageKeys.appCoursesCatalog);
    return m?['has_single_course'] == true;
  }

  static void _applySingleCourseSelections(CoursesModePayload mode) {
    if (!mode.hasSingleCourse) return;

    final storedCourse =
        Shared.getValue(StorageKeys.courseId, initialValue: 0) as int;
    final storedLevel =
        Shared.getValue(StorageKeys.levelId, initialValue: 0) as int;

    if (storedCourse == 0 && mode.singleCourseId != null) {
      Shared.setValue(StorageKeys.courseId, mode.singleCourseId);
    }

    final effectiveCourse =
        Shared.getValue(StorageKeys.courseId, initialValue: 0) as int;
    final singleId = mode.singleCourseId;
    final firstLevel = mode.singleCourseFirstLevelId;

    if (storedLevel != 0) return;

    if (firstLevel == null) return;

    if (singleId != null &&
        effectiveCourse != 0 &&
        effectiveCourse != singleId) {
      return;
    }

    Shared.setValue(StorageKeys.levelId, firstLevel);
  }

  static void _persistSubscriptionSnapshot(Map<String, dynamic>? subscription) {
    final status = (subscription?['status'] ?? 'none').toString().toLowerCase();
    final normalizedStatus = status.isEmpty ? 'none' : status;
    Shared.setValue(StorageKeys.subscriptionState, {
      'has_subscription': subscription != null,
      'status': normalizedStatus,
      'plan_id': subscription?['plan_id'],
      'end_date': subscription?['end_date'],
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _maybeShowSuggestUpdate(Map<String, dynamic> data) async {
    const twentyFourHoursMs = 24 * 60 * 60 * 1000;
    final lastAt =
        Shared.getValue(StorageKeys.lastUpdateSuggestionAt, initialValue: 0)
            as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastAt != 0 && (now - lastAt) < twentyFourHoursMs) return;

    if (data['suggest'] != true) return;

    final storeAndroid = data['store_link_android']?.toString();
    final storeIos = data['store_link_ios']?.toString();
    await SuggestUpdateDialog.show(
      storeLinkAndroid: storeAndroid,
      storeLinkIos: storeIos,
      onLater: () {},
    );
    Shared.setValue(
      StorageKeys.lastUpdateSuggestionAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
