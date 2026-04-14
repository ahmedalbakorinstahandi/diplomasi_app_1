import 'package:diplomasi_app/controllers/user/notifications_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/format_date.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/services/notification_navigation_service.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/notifications_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/notifications_header.dart';
import 'package:diplomasi_app/data/model/user/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsControllerImp());
    return GetBuilder<NotificationsControllerImp>(
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              // Header Section
              const NotificationsHeader(),
              // Notifications List Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.getNotifications(reload: true);
                  },
                  child: HandlingListDataView(
                    isLoading: controller.isLoading,
                    dataIsEmpty: controller.notifications.isEmpty,
                    emptyMessage: 'لا توجد إشعارات',
                    loadingWidget: const NotificationsScreenShimmer(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller.notificationsScrollController,
                      padding: EdgeInsets.all(width(16)),
                      children: [
                        ...controller.notifications.map((dateGroup) {
                          final notificationsForDate =
                              (dateGroup['notifications'] as List);
                          final firstNotification =
                              notificationsForDate.first as NotificationModel;

                          return NotificationDateSection(
                            date: formatDateRelative(
                              firstNotification.createdAt,
                              referenceUtc: controller.relativeDateReferenceUtc,
                            ),
                            notifications: notificationsForDate
                                .map(
                                  (notification) => NotificationCard(
                                    notification:
                                        notification as NotificationModel,
                                  ),
                                )
                                .toList(),
                          );
                        }),
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

class NotificationDateSection extends StatelessWidget {
  const NotificationDateSection({
    super.key,
    required this.date,
    required this.notifications,
  });
  final String date;
  final List<Widget> notifications;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Text(
          date,
          style: TextStyle(
            fontSize: emp(16),
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: height(12)),
        // Notifications
        ...notifications,
        SizedBox(height: height(12)),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final NotificationModel notification;

  bool get _hasNavigationAction =>
      notification.hasAction &&
      !NotificationNavigationService.isInformationalOnly(notification.type);

  Future<void> _handleNotificationTap() async {
    await Get.find<NotificationNavigationService>().handleStoredNotification(
      notification,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _hasNavigationAction ? _handleNotificationTap : null,
      borderRadius: BorderRadius.circular(width(16)),
      child: Container(
        margin: EdgeInsets.only(bottom: height(12)),
        padding: EdgeInsets.all(width(16)),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(width(16)),
          border: notification.isRead
              ? Border.all(color: colors.border, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Time Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: emp(16),
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: width(8)),
                // Time
                Text(
                  formatTimeOnly(notification.createdAt),
                  style: TextStyle(
                    fontSize: emp(12),
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: height(8)),
            // Body Text
            Text(
              notification.body,
              style: TextStyle(
                fontSize: emp(14),
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height(12)),
            // Action Button and Read Indicator Row
            Row(
              children: [
                if (_hasNavigationAction)
                  GestureDetector(
                    onTap: _handleNotificationTap,
                    child: Text(
                      'فتح',
                      style: TextStyle(
                        fontSize: emp(14),
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                const Spacer(),
                // Read Indicator
                Column(
                  children: [
                    // Read Indicator
                    Container(
                      width: width(8),
                      height: width(8),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? scheme.primary
                            : colors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (notification.isRead) ...[
                      SizedBox(height: height(4)),
                      Container(
                        width: width(8),
                        height: width(8),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
