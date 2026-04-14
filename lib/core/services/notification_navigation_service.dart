import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/services/app_me_response_sidecar.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/model/user/notification_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationNavigationService extends GetxService {
  Future<void> handleStoredNotification(NotificationModel notification) async {
    await handlePayload(type: notification.type, payload: notification.data);
  }

  /// Notification types that are informational only; no navigation and no "فتح" action.
  static const _informationalOnlyTypes = {
    'login_new_device',
    'account_verified',
    'password_changed',
  };

  /// Whether this type should not show "فتح" or respond to tap.
  static bool isInformationalOnly(String? type) =>
      type != null && _informationalOnlyTypes.contains(type);

  Future<void> handlePayload({
    String? type,
    Map<String, dynamic>? payload,
  }) async {
    if (type != null && _informationalOnlyTypes.contains(type)) {
      return;
    }

    final data = payload ?? <String, dynamic>{};

    final deepLink = _extractString(data, ['url', 'link', 'deep_link']);
    if (deepLink != null && deepLink.isNotEmpty) {
      await _openExternalLink(deepLink);
      return;
    }

    final explicitScreen = _extractString(data, ['screen']);
    if (explicitScreen != null) {
      if (await _navigateByScreen(explicitScreen, data)) {
        return;
      }
    }

    await _navigateByType(type, data);
  }

  Future<void> _navigateByType(String? type, Map<String, dynamic> data) async {
    switch (type) {
      case 'certificate_issued':
        final certificateId = _extractInt(data, ['certificate_id']);
        if (certificateId != null) {
          Get.toNamed('/certificate-detail/$certificateId');
          return;
        }
        Get.toNamed(AppRoutes.certificates);
        return;
      case 'article_published':
        Get.toNamed(AppRoutes.articles);
        return;
      case 'invoice_issued':
      case 'renewal_success':
      case 'renewal_failed':
      case 'subscription_ending_reminder':
      case 'subscription_activated':
        Get.toNamed(AppRoutes.plans);
        return;
      case 'level_completed':
      case 'course_completed':
        if (AppMeResponseSidecar.hideCoursesLibrary) {
          Get.offAllNamed(AppRoutes.app);
        } else {
          Get.toNamed(AppRoutes.cources);
        }
        return;
      case 'account_banned':
        Get.toNamed(AppRoutes.profile);
        return;
      default:
        // No valid target: do not navigate (notification has no destination).
        break;
    }
  }

  Future<bool> _navigateByScreen(
    String screen,
    Map<String, dynamic> data,
  ) async {
    switch (screen) {
      case 'certificate_detail':
        final id = _extractInt(data, ['certificate_id']);
        if (id != null) {
          Get.toNamed('/certificate-detail/$id');
          return true;
        }
        return false;
      case 'articles':
        Get.toNamed(AppRoutes.articles);
        return true;
      case 'plans':
        Get.toNamed(AppRoutes.plans);
        return true;
      case 'billing_history':
        Get.toNamed(AppRoutes.billingHistory);
        return true;
      case 'courses':
        if (AppMeResponseSidecar.hideCoursesLibrary) {
          Get.offAllNamed(AppRoutes.app);
        } else {
          Get.toNamed(AppRoutes.cources);
        }
        return true;
      case 'levels':
        final courseId = _extractInt(data, ['course_id']);
        if (courseId != null) {
          Get.toNamed(AppRoutes.levels, parameters: {'id': '$courseId'});
          return true;
        }
        if (AppMeResponseSidecar.hideCoursesLibrary) {
          Get.offAllNamed(AppRoutes.app);
        } else {
          Get.toNamed(AppRoutes.cources);
        }
        return true;
      case 'scenario_attempts':
        final scenarioId = _extractInt(data, ['scenario_id']);
        if (scenarioId != null) {
          Get.toNamed(
            AppRoutes.scenarioAttempts,
            parameters: {'scenario_id': '$scenarioId'},
          );
          return true;
        }
        return false;
      case 'home':
        Get.offAllNamed(AppRoutes.app);
        return true;
      case 'profile':
      case 'support':
      case 'security':
        Get.toNamed(AppRoutes.profile);
        return true;
      default:
        return false;
    }
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      customSnackBar(text: 'الرابط غير صالح');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      customSnackBar(text: 'تعذر فتح الرابط');
    }
  }

  int? _extractInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
