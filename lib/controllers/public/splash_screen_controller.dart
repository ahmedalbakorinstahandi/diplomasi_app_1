import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:get/get.dart';

abstract class SplashScreenController extends GetxController {
  startAndDoneSplashScreen();
}

class SplashScreenControllerImp extends SplashScreenController {
  late Map<String, dynamic>? initialMessage;

  @override
  void onInit() {
    startAndDoneSplashScreen();

    super.onInit();
  }

  @override
  startAndDoneSplashScreen() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000), () {
        int step = Shared.getValue('step', initialValue: 0);
        String route = '';
        switch (step) {
          case Steps.onboarding:
            route = AppRoutes.onboarding;
            break;
          case Steps.login:
            route = AppRoutes.login;
            break;
          case Steps.homeApp:
          default:
            route = AppRoutes.app;
        }

        Get.offAllNamed(route);
      });
    } catch (e) {
      printDebug('Error in splash screen navigation: $e');
      // Fallback navigation
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
