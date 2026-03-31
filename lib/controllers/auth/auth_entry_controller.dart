import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/auth_data.dart';
import 'package:get/get.dart';

abstract class AuthEntryController extends GetxController {
  bool isGuestLoading = false;

  void goToLogin();
  void goToRegister();
  Future<void> continueAsGuest();
}

class AuthEntryControllerImp extends AuthEntryController {
  final AuthData authData = AuthData();

  @override
  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  @override
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  Future<void> continueAsGuest() async {
    if (isGuestLoading) return;
    isGuestLoading = true;
    update();

    final response = await authData.startGuest(deviceToken: "deviceToken");
    if (response.isSuccess) {
      Shared.setValue(StorageKeys.accessToken, response.response['access_token']);
      Shared.setValue('user-data', response.data);
      if (response.data != null && response.data['account_state'] != null) {
        Shared.setValue(StorageKeys.accountState, response.data['account_state']);
      }
      Shared.setValue(StorageKeys.step, Steps.homeApp);
      Get.offAllNamed(AppRoutes.app);
    } else {
      customSnackBar(text: response.message ?? "حدث خطأ");
    }

    isGuestLoading = false;
    update();
  }
}
