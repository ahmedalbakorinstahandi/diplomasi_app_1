import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/controllers/profile/profile_controller.dart';
import 'package:diplomasi_app/controllers/theme/theme_controller.dart';
import 'package:diplomasi_app/view/widgets/profile/profile_avatar.dart';
import 'package:diplomasi_app/view/widgets/profile/profile_header.dart';
import 'package:diplomasi_app/view/widgets/profile/profile_item.dart';
import 'package:diplomasi_app/view/widgets/profile/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileControllerImp());
    return GetBuilder<ProfileControllerImp>(
      init: ProfileControllerImp(),
      builder: (controller) {
        final colors = context.appColors;
        return GetBuilder<ThemeControllerImp>(
          builder: (themeController) {
            // Helper function to get current theme mode name
            String getThemeModeName() {
              switch (themeController.themeMode) {
                case ThemeMode.light:
                  return 'نهاري';
                case ThemeMode.dark:
                  return 'ليلي';
                case ThemeMode.system:
                  return 'النظام';
              }
            }

            // Helper function to convert string to ThemeMode
            ThemeMode getThemeModeFromString(String value) {
              switch (value) {
                case 'نهاري':
                  return ThemeMode.light;
                case 'ليلي':
                  return ThemeMode.dark;
                case 'النظام':
                default:
                  return ThemeMode.system;
              }
            }

            return MyScaffold(
              body: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        const ProfileHeader(),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: width(14)),
                          children: [
                            SizedBox(height: height(175)),
                            // Account Management Section
                            ProfileSection(
                              items: [
                                ProfileItem(
                                  title: 'تعديل الملف الشخصي',
                                  icon: Assets.icons.svg.edit,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.editProfile);
                                  },
                                ),
                                ProfileItem(
                                  title: 'تغيير كلمة المرور',
                                  icon: Assets.icons.svg.lock,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.changePassword);
                                  },
                                ),
                              ],
                            ),

                            Divider(
                              color: colors.borderStrong,
                              height: height(16),
                            ),
                            // User-Specific Content Section
                            ProfileSection(
                              items: [
                                ProfileItem(
                                  title: 'شهاداتي',
                                  icon: Assets.icons.svg.badge,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.certificates);
                                  },
                                ),
                                // ProfileItem(
                                //   title: 'الأرشيف',
                                //   icon: Assets.icons.svg.fileEdit,
                                //   onTap: () {},
                                // ),
                                ProfileItem(
                                  title: 'المقالات',
                                  icon: Assets.icons.svg.book,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.articles);
                                  },
                                ),
                                if (isVisible)
                                  ProfileItem(
                                    title: 'الباقات',
                                    icon: Assets.icons.svg.subscriptions,
                                    onTap: () {
                                      Get.toNamed(AppRoutes.plans);
                                    },
                                  ),
                                ProfileItem(
                                  title: 'الفواتير والمدفوعات',
                                  icon: Assets.icons.svg.fileEdit,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.billingHistory);
                                  },
                                ),
                                ProfileItem(
                                  title: 'مكتبة الفيديوهات',
                                  icon: Assets.icons.svg.languageCircle,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.videos);
                                  },
                                ),
                              ],
                            ),
                            Divider(
                              color: colors.borderStrong,
                              height: height(16),
                            ),
                            // Application Settings Section
                            ProfileSection(
                              items: [
                                ProfileItem(
                                  title: 'تفعيل الإشعارات',
                                  icon: Assets.icons.svg.notificationBell,
                                  hasSwitch: true,
                                  switchValue:
                                      controller.isNotificationsEnabled,
                                  onSwitchChanged: (value) {
                                    controller.isNotificationActionInProgress
                                        ? (_) {}
                                        : controller.setNotificationsEnabled(
                                            value,
                                          );
                                  },
                                ),
                                // ProfileItem(
                                //   title: 'اتباع وضع النظام',
                                //   icon: Assets.icons.svg.languageCircle,
                                //   hasSwitch: true,
                                //   switchValue: isUsingSystemTheme,
                                //   onSwitchChanged: (value) {
                                //     themeController.setUseSystemTheme(value);
                                //   },
                                // ),

                                // ProfileItem(
                                //   title: 'اللغة',
                                //   icon: Assets.icons.svg.languageCircle,
                                //   onTap: () {},
                                // ),
                                ProfileItem(
                                  title: 'المظهر',
                                  icon: Assets.icons.svg.nightMode,
                                  hasDropdown: true,
                                  dropdownValue: getThemeModeName(),
                                  dropdownItems: const [
                                    'النظام',
                                    'نهاري',
                                    'ليلي',
                                  ],
                                  onDropdownChanged: (value) {
                                    themeController.setThemeMode(
                                      getThemeModeFromString(value),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Divider(
                              color: colors.borderStrong,
                              height: height(16),
                            ),
                            // Support and Legal Section
                            ProfileSection(
                              items: [
                                ProfileItem(
                                  title: 'help_center'.tr,
                                  icon: Assets.icons.svg.helpCircle,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.helpCenter);
                                  },
                                ),
                                ProfileItem(
                                  title: 'الأسئلة الشائعة',
                                  icon: Assets.icons.svg.helpCircle,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.faqs);
                                  },
                                ),
                                ProfileItem(
                                  title: 'terms_conditions'.tr,
                                  icon: Assets.icons.svg.termsAndConditions,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.termsConditions);
                                  },
                                ),
                                ProfileItem(
                                  title: 'privacy_policy'.tr,
                                  icon: Assets.icons.svg.shieldTick,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.privacyPolicy);
                                  },
                                ),
                              ],
                            ),
                            Divider(
                              color: colors.borderStrong,
                              height: height(16),
                            ),
                            // App Actions Section
                            ProfileSection(
                              items: [
                                ProfileItem(
                                  title: 'مشاركة التطبيق',
                                  icon: Assets.icons.svg.shareSquare,
                                  onTap: controller.shareApp,
                                  isLoading: controller.isShareAppInProgress,
                                ),
                                ProfileItem(
                                  title: 'تسجيل الخروج',
                                  icon: Assets.icons.svg.logout,
                                  onTap: controller.logout,
                                  isLoading: controller.isLoggingOut,
                                ),
                                ProfileItem(
                                  title: 'حذف الحساب',
                                  icon: Assets.icons.svg.trash,
                                  onTap: controller.requestAccountDeletion,
                                  isLoading:
                                      controller.isRequestingDeletionCode,
                                ),
                              ],
                            ),
                            SizedBox(height: height(24)),
                            // Delete Account Button
                            // DeleteAccountButton(
                            //   onTap: controller.requestAccountDeletion,
                            // ),
                            // SizedBox(height: height(24)),
                          ],
                        ),
                      ],
                    ),
                    const ProfileAvatar(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
