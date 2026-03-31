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
        final scheme = Theme.of(context).colorScheme;
        final isGuest = currentAccountState == 'guest';
        final isVerifiedAccount = currentAccountState == 'registered_verified';
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
                            // Account Management Section
                            if (!isGuest) ...[
                              SizedBox(height: height(175)),
                              ProfileSection(
                                items: [
                                  ProfileItem(
                                    title: 'تعديل الملف الشخصي',
                                    icon: Assets.icons.svg.edit,
                                    onTap: () async {
                                      await Get.toNamed(AppRoutes.editProfile);
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
                            ],
                            if (isGuest) ...[
                              SizedBox(height: height(120)),
                              Container(
                                margin: EdgeInsets.only(bottom: height(12)),
                                padding: EdgeInsets.all(width(14)),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: scheme.primary.withOpacity(0.22),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'طوّر حسابك الآن',
                                      style: TextStyle(
                                        fontSize: emp(16),
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: height(6)),
                                    Text(
                                      'انضم معنا أو سجّل دخولك لفتح كل الميزات.',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: emp(13),
                                      ),
                                    ),
                                    SizedBox(height: height(10)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Get.toNamed(AppRoutes.register),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: scheme.primary,
                                              foregroundColor: scheme.onPrimary,
                                              minimumSize: Size(
                                                double.infinity,
                                                height(42),
                                              ),
                                            ),
                                            child: const Text('انضم معنا'),
                                          ),
                                        ),
                                        SizedBox(width: width(8)),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Get.toNamed(AppRoutes.login),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: Size(
                                                double.infinity,
                                                height(42),
                                              ),
                                              side: BorderSide(
                                                color: scheme.primary,
                                              ),
                                            ),
                                            child: Text(
                                              'سجّل دخول',
                                              style: TextStyle(
                                                color: scheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            Divider(
                              color: colors.borderStrong,
                              height: height(16),
                            ),
                            // User-Specific Content Section
                            ProfileSection(
                              items: [
                                if (isVerifiedAccount)
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
                                  title: 'المصطلحات',
                                  icon: Assets.icons.svg.terminology,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.glossary);
                                  },
                                ),
                                if (isVisible && isVerifiedAccount)
                                  ProfileItem(
                                    title: 'subscription_page_title'.tr,
                                    icon: Assets.icons.svg.subscriptions,
                                    onTap: () {
                                      Get.toNamed(AppRoutes.plans);
                                    },
                                  ),
                                if (isVisible && isVerifiedAccount)
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
                                if (!isGuest)
                                  ProfileItem(
                                    title: 'تسجيل الخروج',
                                    icon: Assets.icons.svg.logout,
                                    onTap: controller.logout,
                                    isLoading: controller.isLoggingOut,
                                  ),
                                if (isVerifiedAccount)
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
