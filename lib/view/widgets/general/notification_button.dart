import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    int unreadNotificationsCount = Shared.getValue(
      'notifications_unread_count',
      initialValue: 0,
    );

    String unreadNotificationsCountString = unreadNotificationsCount.toString();
    if (unreadNotificationsCount > 99) {
      unreadNotificationsCountString = '99+';
    }

    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.notifications);
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: width(40),
            height: height(40),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: MySvgIcon(
                path: Assets.icons.svg.notification,
                size: emp(24),
                color: scheme.primary,
              ),
            ),
          ),
          if (unreadNotificationsCount > 0)
            Positioned(
              top: -3,
              right: -3,
            child: Container(
                width: width(20),
                height: height(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadNotificationsCountString,
                  style: TextStyle(fontSize: emp(11), color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
