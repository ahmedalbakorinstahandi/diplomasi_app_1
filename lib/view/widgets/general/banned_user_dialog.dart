import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Dialog shown when the user is banned. Actions: Help center, Logout (API + clear), Close app.
class BannedUserDialog extends StatefulWidget {
  const BannedUserDialog({super.key});

  static Future<void> show() async {
    return Get.dialog<void>(
      const BannedUserDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
    );
  }

  @override
  State<BannedUserDialog> createState() => _BannedUserDialogState();
}

class _BannedUserDialogState extends State<BannedUserDialog> {
  bool _isLoggingOut = false;

  void _openHelpCenter() {
    // لا نغلق الـ dialog — نفتح مركز المساعدة فوقه حتى عند الرجوع تبقى نافذة الحظر ظاهرة
    Get.toNamed(AppRoutes.helpCenter);
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    final authData = AuthData();
    await authData.logout();
    if (!mounted) return;
    Get.back();
    Shared.clear();
    Shared.setValue(StorageKeys.step, Steps.login);
    Get.offAllNamed(AppRoutes.login);
  }

  void _closeApp() {
    Get.back();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Get.theme.extension<AppColors>() ?? AppColors.light;
    final scheme = Get.theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          elevation: 24,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: scheme.surface,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width(24),
              vertical: height(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(width(20)),
                  decoration: BoxDecoration(
                    color: scheme.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    size: emp(44),
                    color: scheme.error,
                  ),
                ),
                SizedBox(height: height(20)),
                Text(
                  'banned_title'.tr,
                  style: TextStyle(
                    fontSize: emp(20),
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height(12)),
                Text(
                  'banned_message'.tr,
                  style: TextStyle(
                    fontSize: emp(15),
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height(24)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openHelpCenter,
                    icon: Icon(Icons.help_outline_rounded, size: emp(20)),
                    label: Text('help_center'.tr),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: height(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: height(10)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoggingOut ? null : _logout,
                    icon: _isLoggingOut
                        ? SizedBox(
                            width: emp(20),
                            height: emp(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.error,
                            ),
                          )
                        : Icon(Icons.logout_rounded, size: emp(20)),
                    label: Text(
                      _isLoggingOut ? '${'logout'.tr}...' : 'logout'.tr,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error),
                      padding: EdgeInsets.symmetric(vertical: height(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height(10)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _closeApp,
                    icon: Icon(
                      Icons.close_rounded,
                      size: emp(20),
                      color: colors.textSecondary,
                    ),
                    label: Text(
                      'close_app'.tr,
                      style: TextStyle(
                        fontSize: emp(15),
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.borderStrong),
                      padding: EdgeInsets.symmetric(vertical: height(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
