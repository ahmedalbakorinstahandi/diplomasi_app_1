import 'package:diplomasi_app/controllers/public/splash_screen_controller.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreenScreen extends StatelessWidget {
  const SplashScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenControllerImp());
    return GetBuilder<SplashScreenControllerImp>(
      // init: splashScreenController,
      builder: (controller) {
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        return MyScaffold(
          body: Container(
            width: getWidth(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.backgroundPrimary,
                  colors.surface,
                  colors.backgroundSecondary,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width(50)),
                    child: SvgPicture.asset(
                      Assets.pictures.svg.logoWithName,
                      width: width(400),
                      height: height(400),
                      color: isDarkMode ? Colors.white : null,
                    ),
                  ),
                  SizedBox(height: height(80)),
                  CircularProgressIndicator(
                    color: scheme.primary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
