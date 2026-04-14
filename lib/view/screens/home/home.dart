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

                                        if (controller.level != null &&
                                            controller.level!.hasCertificate) ...[
                                          _CertificateStatusCard(
                                            level: controller.level!,
                                            onViewCertificate: () {
                                              if (!isVerifiedAccount) {
                                                showUpgradeSheet();
                                                return;
                                              }
                                              controller.viewCertificate();
                                            },
                                          ),
                                          SizedBox(height: height(14)),
                                        ],

                                        // Show navigation buttons if level is completed
                                        if (controller.level?.accessStatus == 'completed') ...[
                                          // Next Level Button
                                          if (controller.getNextLevel() != null)
                                            CustomButton(
                                              text: 'الانتقال للمستوى التالي',
                                              onPressed: () {
                                                controller.goToNextLevel();
                                              },
                                              backgroundColor: scheme.primary,
                                            ),
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

class _CertificateStatusCard extends StatelessWidget {
  final dynamic level;
  final VoidCallback onViewCertificate;

  const _CertificateStatusCard({
    required this.level,
    required this.onViewCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eligibility = (level.certificateEligibility ?? <String, dynamic>{})
        as Map<String, dynamic>;
    final finalState = (eligibility['final_state'] ?? 'not_eligible').toString();
    final isEligible = eligibility['is_eligible'] == true;
    final regenReason =
        eligibility['regeneration_reason']?.toString();
    final requiresSubscription =
        eligibility['requires_subscription_for_certificate'] == true;

    String title;
    List<String> details;
    String? buttonText;

    if (!isEligible) {
      title = 'يمكنك متابعة التعلم الآن';
      details = [
        'أنت لست مستحقًا للشهادة بعد.',
        'للحصول على الشهادة يجب إكمال جميع الدروس المطلوبة.',
        'ويجب إكمال جميع السيناريوهات المطلوبة.',
        if (requiresSubscription)
          'بعض السيناريوهات مقفولة حاليًا بالاشتراك، لكنها مطلوبة للشهادة.',
      ];
    } else if (finalState == 'generated') {
      title = 'أنت مستحق للشهادة';
      details = ['الشهادة جاهزة الآن، ويمكنك عرضها أو تنزيلها مباشرة.'];
      buttonText = 'عرض الشهادة';
    } else if (finalState == 'eligible_regeneration_needed') {
      title = 'أنت مستحق للشهادة';
      if (regenReason == 'generation_failed' ||
          regenReason == 'artifact_missing') {
        details = [
          if (regenReason == 'generation_failed')
            'فشل توليد ملف الشهادة بعد إكمالك. يمكنك إعادة المحاولة من صفحة الشهادة.'
          else
            'ملف الشهادة غير متوفر. يمكنك إعادة إصداره من صفحة الشهادة.',
        ];
        buttonText = 'الحصول على الشهادة';
      } else {
        details = [
          if (regenReason == 'template_changed')
            'تم تحديث نموذج الشهادة. سيتم إعادة الإصدار من خلال الإدارة.'
          else if (regenReason == 'certificate_deleted')
            'سجل الشهادة غير مكتمل. يُرجى التواصل مع الدعم أو الإدارة.'
          else
            'ملف الشهادة يحتاج إعادة إصدار من الإدارة.',
        ];
        buttonText = null;
      }
    } else {
      title = 'أنت مستحق للشهادة';
      details = ['استحقاقك مكتمل، لكن لم يتم توليد ملف الشهادة بعد.'];
      buttonText = 'الحصول على الشهادة';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width(12)),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: emp(15),
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: height(8)),
            ...details.map(
              (line) => Padding(
                padding: EdgeInsets.only(bottom: height(4)),
                child: Text(
                  '- $line',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: emp(13),
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withOpacity(0.9),
                    height: 1.35,
                  ),
                ),
              ),
            ),
            if (buttonText != null) ...[
              SizedBox(height: height(10)),
              CustomButton(
                text: buttonText,
                onPressed: onViewCertificate,
                backgroundColor: scheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
