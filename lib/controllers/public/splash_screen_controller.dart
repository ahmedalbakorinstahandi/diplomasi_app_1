import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/core/services/app_shell_bootstrap.dart';
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
      final int step = Shared.getValue('step', initialValue: 0);
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

      final tokenVal = Shared.getValue(StorageKeys.accessToken);
      final hasToken = tokenVal != null && tokenVal.toString().isNotEmpty;

      if (route == AppRoutes.app && hasToken) {
        await Future.wait([
          Future.delayed(const Duration(milliseconds: 800)),
          AppShellBootstrap.ensurePreparedForCurrentToken(),
        ]);
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      Get.offAllNamed(route);
    } catch (e) {
      printDebug('Error in splash screen navigation: $e');
      // Fallback navigation
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
