import 'package:diplomasi_app/controllers/home/home_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/home/presentation/shimmer/home_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/learning/level_track_list.dart';
import 'package:diplomasi_app/view/widgets/learning/home_header.dart';
import 'package:diplomasi_app/view/widgets/learning/level_dropdown.dart';
import 'package:diplomasi_app/view/widgets/learning/premium_banner.dart';
import 'package:diplomasi_app/view/widgets/learning/progress_indicator_widget.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:diplomasi_app/view/widgets/general/account_upgrade_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());
    return GetBuilder<HomeControllerImp>(
      init: HomeControllerImp(),
      builder: (controller) {
        // Shared.clear();
        // print(Shared.getValue(StorageKeys.lastUpdateSuggestionAt));
        // Shared.remove(StorageKeys.lastUpdateSuggestionAt);
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        final isVerifiedAccount = currentAccountState == 'registered_verified';

        Future<void> showUpgradeSheet() async {
          await AccountUpgradeSheet.show(
            context: context,
            title: 'افتح الميزة بالحساب الكامل',
            description:
                'للوصول للشهادات والاشتراك والمزامنة، انضم معنا أو سجّل دخولك.',
          );
        }
        // Shared.remove(StorageKeys.levelId);
        // Shared.remove(StorageKeys.courseId);

        // Shared.setValue('notifications_unread_count', 100);

        return MyScaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getLevels();
              await controller.getLevelTracks();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // Header Section
                HomeHeader(),
                Stack(
                  children: [
                    if (!isDarkMode)
                      Positioned(
                        top: height(-230),

                        child: SvgPicture.asset(
                          Assets.pictures.svg.pattern1,
                          height: getHeight(),
                          width: getWidth(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    HandlingListDataView(
                      isLoading:
                          controller.levelTracks.isEmpty ||
                          controller.isLoadingTracks,
                      dataIsEmpty: controller.levelTracks.isEmpty,
                      loadingWidget: const HomeScreenShimmer(),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              width(14),
                              height(20),
                              width(14),
                              0,
                            ),
                            height: getHeight() * 0.7855,
                            child: Column(
                              children: [
                                // Course title
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.level?.course?.title ?? '',
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          fontSize: emp(22),
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width(8)),
                                    Flexible(
                                      flex: 1,
                                      child: LevelDropdown(
                                        selectedLevel: controller.level,
                                        levels: controller.levels,
                                        onLevelSelected: (level) {
                                          controller.selectLevel(level);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Content Section
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Premium Banner
                                        if (isVisible &&
                                            controller.shouldShowPremiumBanner)
                                          PremiumBanner(
                                            onTap: () {
                                              if (!isVerifiedAccount) {
                                                showUpgradeSheet();
                                                return;
                                              }
                                              Get.toNamed(AppRoutes.plans);
                                            },
                                          ),
                                        // Progress Indicator
                                        ProgressIndicatorWidget(
                                          completedLessons:
                                              controller.completedTracks,
                                          totalLessons:
                                              controller.levelTracks.length,
                                          progressPercentage:
                                              controller.progressPercentage,
                                        ),

                                        if (controller.levelTracks.isEmpty) ...[
                                          SizedBox(height: height(100)),
                                          Center(
                                            child: Text(
                                              'لا يوجد محتوى لهذا المستوى',
                                              style: TextStyle(
                                                fontSize: emp(16),
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        // Level Track List
                                        LevelTrackList(
                                          tracks: controller.levelTracks,
                                          onTap: () {
                                            controller.getLevelTracks();
                                          },
                                        ),
                                        SizedBox(height: height(20)),

                                        // Show buttons if level is completed
                                        if (controller.level?.accessStatus ==
                                            'completed') ...[
                                          // Next Level Button
                                          if (controller.getNextLevel() != null)
                                            CustomButton(
                                              text: 'الانتقال للمستوى التالي',
                                              onPressed: () {
                                                controller.goToNextLevel();
                                              },
                                              backgroundColor: scheme.primary,
                                            ),

                                          // Certificate Button
                                          if (controller
                                                  .level
                                                  ?.hasCertificate ==
                                              true) ...[
                                            SizedBox(height: height(12)),
                                            CustomButton(
                                              text: 'عرض الشهادة',
                                              onPressed: () {
                                                if (!isVerifiedAccount) {
                                                  showUpgradeSheet();
                                                  return;
                                                }
                                                controller.viewCertificate();
                                              },
                                              backgroundColor: scheme.secondary,
                                            ),
                                          ],
                                          SizedBox(height: height(20)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
