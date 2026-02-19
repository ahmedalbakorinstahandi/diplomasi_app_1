// import 'package:diplomasi_app/view/screens/public/notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';

customSnackBar({
  required String text,
  String message = '',
  SnackBarType snackType = SnackBarType.correct,
  SnackPosition snackPosition = SnackPosition.TOP,
  Duration? duration,

  String? id,
  String? type,
}) {
  if (text.isEmpty) return;
  // Close any open SnackBars
  Get.closeAllSnackbars();

  final appColors = Get.theme.extension<AppColors>() ?? AppColors.light;
  final scheme = Get.theme.colorScheme;

  // Define snackbar color and icon
  late Color snackbarColor;
  late Widget icon;
  late Color onSnackbar;

  switch (snackType) {
    case SnackBarType.correct:
      snackbarColor = scheme.primary;
      onSnackbar = scheme.onPrimary;
      icon = Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          color: scheme.onPrimary,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Icons.check, color: snackbarColor, size: 18)),
      );
      break;

    case SnackBarType.info:
      snackbarColor = appColors.info;
      onSnackbar = scheme.onPrimary;
      icon = Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          color: scheme.onPrimary,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Icons.check, color: snackbarColor, size: 18)),
      );
      break;

    case SnackBarType.error:
      snackbarColor = scheme.error;
      onSnackbar = scheme.onError;
      icon = Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          color: scheme.onError,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, color: snackbarColor, size: 17),
      );
      break;
  }

  // Show Snackbar
  Get.snackbar(
    '',
    '',
    titleText: GestureDetector(
      onTap: () {
        if (id != null && type != null) {
          // notificationTap(id, type);
        }
      },
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: onSnackbar,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: onSnackbar,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    snackPosition: snackPosition,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    padding: const EdgeInsets.all(12),
    backgroundColor: snackbarColor,
    colorText: onSnackbar,
    messageText: const SizedBox(),
    dismissDirection: DismissDirection.horizontal,
    duration: duration ?? const Duration(seconds: 3),
    borderRadius: 8,
  );
}

enum SnackBarType { correct, info, error }
