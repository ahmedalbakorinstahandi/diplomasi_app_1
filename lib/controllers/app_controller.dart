// import 'package:diplomasi_app/core/constants/routes.dart';
// import 'package:flutter/scheduler.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/notification_prompt_service.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';
import 'package:diplomasi_app/view/widgets/general/suggest_update_dialog.dart';
import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:diplomasi_app/data/resource/remote/general/general_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/notifications_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/user_data.dart';
import 'package:diplomasi_app/view/screens/home/home.dart';
import 'package:diplomasi_app/view/screens/profile/profile.dart';
import 'package:diplomasi_app/view/screens/user/articles_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

abstract class AppController extends GetxController {
  PageController pageController = PageController();

  var isLoading = false;

  int pageIndex = 0;

  List pages = [
    {'screen': HomeScreen(), 'name': 'الرئيسية', 'icon': Assets.icons.svg.home},
    {
      'screen': const ArticlesScreen(),
      'name': 'المقالات',
      'icon': Assets.icons.svg.book,
    },

    {
      'screen': const ProfileScreen(),
      'name': 'حسابي',
      'icon': Assets.icons.svg.person,
    },
  ];

  UserData userData = UserData();
  GeneralData generalData = GeneralData();
  UserModel? userModel;
  bool isUserDataLoading = false;
  Future<void> getMyInfo();
  Future<void> checkSuggestUpdateOncePerDay();

  int unreadNotificationsCount = 0;

  bool isUnreadNotificationsCountLoading = false;

  NotificationsData notificationsData = NotificationsData();

  Future<void> getUnreadNotificationsCount();

  void goToHome();
  void onPageChanged(int page);
  void refreshHomePage();
  void changePage(int page);
  void checkLevelAndCourse();
}

class AppControllerImp extends AppController {
  @override
  void onInit() async {
    getMyInfo();
    checkSuggestUpdateOncePerDay();
    checkLevelAndCourse();
    getUnreadNotificationsCount();
    super.onInit();

    // if (isUserLoggedIn) {
    //   getUnreadNotificationsCount();
    // }
  }

  @override
  void onReady() {
    super.onReady();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Get.find<PushNotificationService>().handlePendingInitialMessageIfAny();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        NotificationPromptService().maybeShowPrompt();
      });
    });
  }

  @override
  void checkLevelAndCourse() {
    int levelId = Shared.getValue(StorageKeys.levelId, initialValue: 0);
    int courseId = Shared.getValue(StorageKeys.courseId, initialValue: 0);

    if (levelId == 0 || courseId == 0) {
      // Defer navigation until after the current build phase completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(AppRoutes.cources);
      });
      return;
    }
  }

  @override
  void goToHome() {
    pageController.jumpToPage(0);
    pageIndex = 0;
    update();
  }

  @override
  void refreshHomePage() {
    // if (Get.isRegistered<HomeControllerImp>()) {
    //   Get.find<HomeControllerImp>().refreshHomePage();
    // }
  }

  @override
  void onPageChanged(int page) {
    // pageIndex = page;
    // update();

    // // Notify the active tab controller
    // if (page == 0 && Get.isRegistered<HomeControllerImp>()) {
    //   Get.find<HomeControllerImp>().onBecameActive();
    // } else if (page == 1 && Get.isRegistered<MapControllerImp>()) {
    //   Get.find<MapControllerImp>().onBecameActive();
    // } else if (page == 2 && Get.isRegistered<FavoritesControllerImp>()) {
    //   Get.find<FavoritesControllerImp>().onBecameActive();
    // }
  }

  @override
  void changePage(int page) {
    if (page == 0 && pageIndex == 0) {
      refreshHomePage();
    }
    pageController.jumpToPage(
      page,
      // duration: const Duration(milliseconds: 250),
      // curve: Curves.easeIn,
    );
    pageIndex = page;
    update();

    // // Notify the active tab controller
    // if (page == 0 && Get.isRegistered<HomeControllerImp>()) {
    //   Get.find<HomeControllerImp>().onBecameActive();
    // } else if (page == 1 && Get.isRegistered<MapControllerImp>()) {
    //   Get.find<MapControllerImp>().onBecameActive();
    // } else if (page == 2 && Get.isRegistered<FavoritesControllerImp>()) {
    //   Get.find<FavoritesControllerImp>().onBecameActive();
    // }
  }

  @override
  Future<void> getMyInfo() async {
    if (isUserDataLoading) return;

    isUserDataLoading = true;
    update();

    var response = await userData.getMyInfo();
    if (response.isSuccess) {
      Shared.setValue('user-data', response.data);
      userModel = UserModel.fromJson(response.data);
      Shared.setValue(StorageKeys.accountState, userModel?.accountState ?? '');
    }
    isUserDataLoading = false;
    update();
  }

  @override
  Future<void> checkSuggestUpdateOncePerDay() async {
    const twentyFourHoursMs = 24 * 60 * 60 * 1000;
    final lastAt =
        Shared.getValue(StorageKeys.lastUpdateSuggestionAt, initialValue: 0)
            as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastAt != 0 && (now - lastAt) < twentyFourHoursMs) return;

    final response = await generalData.checkAppUpdateSuggest();
    if (!response.isSuccess || response.data == null) return;
    final data = response.data is Map ? response.data as Map : null;
    if (data == null || data['suggest'] != true) return;

    final storeAndroid = data['store_link_android']?.toString();
    final storeIos = data['store_link_ios']?.toString();
    await SuggestUpdateDialog.show(
      storeLinkAndroid: storeAndroid,
      storeLinkIos: storeIos,
      onLater: () {},
    );
    Shared.setValue(
      StorageKeys.lastUpdateSuggestionAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> getUnreadNotificationsCount() async {
    if (isUnreadNotificationsCountLoading) return;

    isUnreadNotificationsCountLoading = true;
    update();

    var response = await notificationsData.getUnreadCount();
    if (response.isSuccess) {
      unreadNotificationsCount = response.data['count'];
      Shared.setValue('notifications_unread_count', unreadNotificationsCount);
    }
    isUnreadNotificationsCountLoading = false;
    update();
  }
}
