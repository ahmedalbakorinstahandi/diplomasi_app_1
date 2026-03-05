import 'dart:io';

import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Non-dismissible dialog shown when the app version is below min_version.
/// Single action: open store link (Android/iOS).
class ForceUpdateDialog extends StatelessWidget {
  final String? storeLinkAndroid;
  final String? storeLinkIos;

  const ForceUpdateDialog({
    super.key,
    this.storeLinkAndroid,
    this.storeLinkIos,
  });

  static Future<void> show({
    String? storeLinkAndroid,
    String? storeLinkIos,
  }) async {
    return Get.dialog<void>(
      ForceUpdateDialog(
        storeLinkAndroid: storeLinkAndroid,
        storeLinkIos: storeLinkIos,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  Future<void> _openStore() async {
    final link = Platform.isIOS ? storeLinkIos : storeLinkAndroid;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Get.theme.extension<AppColors>() ?? AppColors.light;
    final scheme = Get.theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: scheme.surface,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width(24), vertical: height(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(width(20)),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  size: emp(44),
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: height(20)),
              Text(
                'force_update_title'.tr,
                style: TextStyle(
                  fontSize: emp(20),
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height(12)),
              Text(
                'force_update_message'.tr,
                style: TextStyle(
                  fontSize: emp(15),
                  color: colors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height(28)),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _openStore,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: height(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'update_button'.tr,
                    style: TextStyle(
                      fontSize: emp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
