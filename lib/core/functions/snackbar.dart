// import 'package:diplomasi_app/view/screens/public/notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';

List<BoxShadow> _snackBarShadows(AppColors appColors, Brightness brightness) {
  if (brightness == Brightness.dark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 18,
        offset: const Offset(0, 8),
        spreadRadius: -3,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
  return [
    BoxShadow(
      color: appColors.shadow,
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

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
  Get.closeAllSnackbars();

  final appColors = Get.theme.extension<AppColors>() ?? AppColors.light;
  final brightness = Get.theme.brightness;

  late Color accent;
  late IconData glyph;

  switch (snackType) {
    case SnackBarType.correct:
      accent = appColors.success;
      glyph = Icons.check_rounded;
      break;
    case SnackBarType.info:
      accent = appColors.info;
      glyph = Icons.info_outline_rounded;
      break;
    case SnackBarType.error:
      accent = appColors.error;
      glyph = Icons.error_outline_rounded;
      break;
  }

  final iconTile = Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: accent.withValues(
        alpha: brightness == Brightness.dark ? 0.2 : 0.14,
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withValues(alpha: 0.28)),
    ),
    alignment: Alignment.center,
    child: Icon(glyph, color: accent, size: 20),
  );

  late final SnackbarController snackController;
  snackController = Get.rawSnackbar(
    title: '',
    message: '',
    titleText: LayoutBuilder(
      builder: (context, constraints) {
        // طرف النهاية في RTL = يسار: فاصل + X. الأيقونة داخل الصف الأول.
        const trailingFixed = 8 + 1 + 6 + 44;
        const iconAndGap = 36 + 12;
        final textMax = (constraints.maxWidth - trailingFixed - iconAndGap)
            .clamp(72.0, constraints.maxWidth);

        final textStyleTitle = TextStyle(
          color: appColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          height: 1.35,
        );
        final textStyleBody = TextStyle(
          color: appColors.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.35,
        );

        final textBlock = GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            if (id != null && type != null) {
              // notificationTap(id, type);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: textStyleTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  message,
                  style: textStyleBody,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        );

        // RTL: أول عنصر = يمين. Expanded يملأ المسافة ويحشر النص والأيقونة نحو البداية؛
        // آخر عناصر = الفاصل + X على طرف النهاية (يسار).
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconTile,
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: textMax),
                      child: textBlock,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 32, color: appColors.border),
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => snackController.close(),
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: appColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
    messageText: const SizedBox(),
    snackPosition: snackPosition,
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    backgroundColor: appColors.surfaceCard,
    dismissDirection: DismissDirection.horizontal,
    isDismissible: true,
    duration: duration ?? const Duration(seconds: 4, milliseconds: 500),
    borderRadius: 10,
    borderColor: appColors.borderStrong.withValues(alpha: 0.35),
    borderWidth: 1,
    leftBarIndicatorColor: null,
    boxShadows: _snackBarShadows(appColors, brightness),
    shouldIconPulse: false,
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    animationDuration: const Duration(milliseconds: 380),
    barBlur: 0,
    overlayBlur: 0,
  );
}

enum SnackBarType { correct, info, error }
