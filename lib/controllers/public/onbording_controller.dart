import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/public/page_onbording_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/data/resource/static/onbording/pages_data.dart'
    as data;

abstract class OnboardingController extends GetxController {
  void onPageChanged(int page);
  void next();
  void previous();
}

class OnboardingControllerImp extends OnboardingController {
  late PageController pageController;
  int currentPage = 0;

  RxList onboardingPages = <PageOnbordingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadData();
  }

  void loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    onboardingPages.assignAll(data.onboardingPages);
    update();
  }

  @override
  void onPageChanged(int page) {
    currentPage = page;
    update();
  }

  @override
  void next() {
    if (currentPage < onboardingPages.length - 1) {
      currentPage++;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeIn,
      );
      update();
    } else {
      Get.offAllNamed(AppRoutes.login);
      Shared.setValue(StorageKeys.step, Steps.login);
    }
  }

  @override
  void previous() {
    if (currentPage > 0) {
      currentPage--;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeIn,
      );
      update();
    }
  }
}
