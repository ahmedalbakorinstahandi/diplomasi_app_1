import 'dart:io';

import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dismissible dialog suggesting an app update. Shown at most once per 24h.
class SuggestUpdateDialog extends StatelessWidget {
  final String? storeLinkAndroid;
  final String? storeLinkIos;
  final VoidCallback onLater;

  const SuggestUpdateDialog({
    super.key,
    this.storeLinkAndroid,
    this.storeLinkIos,
    required this.onLater,
  });

  static Future<void> show({
    String? storeLinkAndroid,
    String? storeLinkIos,
    required VoidCallback onLater,
  }) async {
    return Get.dialog<void>(
      SuggestUpdateDialog(
        storeLinkAndroid: storeLinkAndroid,
        storeLinkIos: storeLinkIos,
        onLater: onLater,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  Future<void> _openStore() async {
    Get.back();
    final link = Platform.isIOS ? storeLinkIos : storeLinkAndroid;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _onLater() {
    Get.back();
    onLater();
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
                  size: emp(40),
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: height(18)),
              Text(
                'suggest_update_title'.tr,
                style: TextStyle(
                  fontSize: emp(19),
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height(10)),
              Text(
                'suggest_update_message'.tr,
                style: TextStyle(
                  fontSize: emp(14),
                  color: colors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onLater,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: height(14)),
                        side: BorderSide(color: colors.borderStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'later_button'.tr,
                        style: TextStyle(
                          fontSize: emp(15),
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width(12)),
                  Expanded(
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
                          fontSize: emp(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
