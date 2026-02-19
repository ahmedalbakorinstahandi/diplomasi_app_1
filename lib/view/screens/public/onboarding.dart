import 'package:diplomasi_app/controllers/public/onbording_controller.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/public/page_onbording_model.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/shimmers/public/presentation/shimmer/onboarding_screen_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingControllerImp());
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return MyScaffold(
      body: GetBuilder<OnboardingControllerImp>(
        builder: (controller) {
          if (controller.onboardingPages.isEmpty) {
            return const OnboardingScreenShimmer();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap:
                        controller.currentPage !=
                            controller.onboardingPages.length - 1
                        ? () {
                            Get.offAllNamed(AppRoutes.login);
                            Shared.setValue(StorageKeys.step, Steps.login);
                          }
                        : () {},
                    child: Center(
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          color:
                              controller.currentPage !=
                                  controller.onboardingPages.length - 1
                              ? scheme.primary
                              : Colors.transparent,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height(40)),
              SizedBox(
                height: getHeight() * 0.65,
                width: getWidth(),
                child: PageView.builder(
                  onPageChanged: controller.onPageChanged,
                  controller: controller.pageController,
                  itemCount: controller.onboardingPages.length,
                  itemBuilder: (context, index) {
                    return buildPage(
                      context,
                      controller.onboardingPages[index],
                      controller,
                    );
                  },
                ),
              ),
              SizedBox(height: height(30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onboardingPages.length,
                  (index) => SizedBox(
                    width: width(32),
                    child: buildIndicator(
                      context,
                      isFocused: controller.currentPage == index,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height(30)),

              // CustomButton(
              //   text:
              //       controller.currentPage ==
              //           controller.onboardingPages.length - 1
              //       ? 'ابدأ الآن'
              //       : 'التالي',
              //   onPressed: controller.next,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: controller.next,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.highlight,
                          width: height(3),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),

                      padding: EdgeInsets.all(height(6)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: scheme.primary,
                        ),
                        height: height(60),
                        width: height(60),
                        child: Icon(
                          Icons.arrow_forward,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height(16)),
            ],
          );
        },
      ),
    );
  }

  Widget buildPage(
    BuildContext context,
    PageOnbordingModel page,
    OnboardingControllerImp controller,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.cover,
                width: getWidth(),
                height: height(400),
              ),
            ),
          ),

          SizedBox(height: height(24)),
          Text(
            page.title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: width(22),
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: height(8)),
          SizedBox(
            width: width(350),
            child: Text(
              page.description,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator(BuildContext context, {required bool isFocused}) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 750),
      margin: EdgeInsets.symmetric(horizontal: width(4)),
      width: width(16),
      height: height(16),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(32),
      // ),
      child: SvgPicture.asset(
        Assets.icons.svg.dot,
        color: isFocused ? colors.highlight : colors.border,
        width: width(16),
        height: height(16),
      ),
    );
  }
}
