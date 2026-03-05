import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/functions/format_date.dart';
import 'package:diplomasi_app/data/model/user/notification_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/notifications_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class NotificationsController extends GetxController {
  List<NotificationModel> unsortedNotifications = [];
  List notifications = [];

  bool isLoading = false;
  int page = 1;
  int perPage = 20;
  bool isLoadingMore = false;

  NotificationsData notificationsData = NotificationsData();
  ScrollController notificationsScrollController = ScrollController();

  Future<void> getNotifications({bool reload = false});
  Future<void> markAllAsRead();
  Future<void> getUnreadCount();
}

class NotificationsControllerImp extends NotificationsController {
  @override
  void onInit() {
    super.onInit();
    getNotifications();
    notificationsScrollController.addListener(() {
      if (notificationsScrollController.position.pixels ==
          notificationsScrollController.position.maxScrollExtent) {
        getNotifications();
      }
    });
  }

  @override
  void onClose() {
    notificationsScrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> getNotifications({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
    }
    isLoading = true;

    isLoadingMore = !reload;
    update();

    ApiResponse response = await notificationsData.get(
      page: page,
      perPage: perPage,
    );

    if (response.isSuccess && response.data != null) {
      final notificationsData = response.data as List;
      final newNotifications = notificationsData
          .map(
            (notificationData) => NotificationModel.fromJson(
              notificationData as Map<String, dynamic>,
            ),
          )
          .toList();

      page = Meta.handlePagination(
        list: unsortedNotifications,
        newData: newNotifications,
        meta: response.meta!,
        page: page,
        reload: reload,
      );

      // Mark first unread notification as read
      for (var notification in unsortedNotifications) {
        if (notification.readAt == null) {
          markAllAsRead();
          break;
        }
      }

      // Group by local calendar day (UTC from API → convert to device timezone)
      List groupedNotifications = [];

      for (var notification in unsortedNotifications) {
        final String date = formatDateOnly(notification.createdAt);
        if (date.isEmpty) continue;

        var dateGroup = groupedNotifications.firstWhere(
          (element) => element['date'] == date,
          orElse: () {
            var newGroup = {'date': date, 'notifications': []};
            groupedNotifications.add(newGroup);
            return newGroup;
          },
        );

        dateGroup['notifications'].add(notification);
      }

      // Convert map to list of lists
      notifications = groupedNotifications;
    }
    isLoading = false;
    update();
  }

  @override
  Future<void> markAllAsRead() async {
    var response = await notificationsData.markAllAsRead();
    if (response.isSuccess) {
      Shared.setValue('notifications_unread_count', 0);

      await Get.forceAppUpdate();

      // final now = DateTime.now().toIso8601String();

      // // Update all notifications with readAt timestamp
      // for (int i = 0; i < unsortedNotifications.length; i++) {
      //   final notification = unsortedNotifications[i];
      //   if (notification.readAt == null) {
      //     unsortedNotifications[i] = NotificationModel(
      //       id: notification.id,
      //       title: notification.title,
      //       body: notification.body,
      //       notificationableType: notification.notificationableType,
      //       notificationableId: notification.notificationableId,
      //       readAt: now,
      //       createdAt: notification.createdAt,
      //       updatedAt: notification.updatedAt,
      //     );
      //   }
      // }

      // Regroup by local calendar day (same as getNotifications)
      List groupedNotifications = [];
      for (var notification in unsortedNotifications) {
        final String date = formatDateOnly(notification.createdAt);
        if (date.isEmpty) continue;
        var dateGroup = groupedNotifications.firstWhere(
          (element) => element['date'] == date,
          orElse: () {
            var newGroup = {'date': date, 'notifications': []};
            groupedNotifications.add(newGroup);
            return newGroup;
          },
        );
        dateGroup['notifications'].add(notification);
      }
      notifications = groupedNotifications;
      update();
    }
  }

  @override
  Future<void> getUnreadCount() async {
    var response = await notificationsData.getUnreadCount();
    if (response.isSuccess && response.data != null) {
      Shared.setValue('notifications_unread_count', response.data);
    }
  }
}
