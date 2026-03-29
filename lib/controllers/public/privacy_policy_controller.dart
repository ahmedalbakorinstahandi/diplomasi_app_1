import 'package:diplomasi_app/core/functions/legal_platform.dart';
import 'package:diplomasi_app/data/resource/remote/general/settings_data.dart';
import 'package:get/get.dart';

abstract class PrivacyPolicyController extends GetxController {
  String privacyPolicy = '';

  SettingsData settingsData = SettingsData();

  bool isLoading = false;

  Future<void> getPrivacyPolicy();
}

class PrivacyPolicyControllerImp extends PrivacyPolicyController {
  @override
  void onInit() {
    super.onInit();
    getPrivacyPolicy();
  }

  @override
  Future<void> getPrivacyPolicy() async {
    isLoading = true;
    update();
    var response = await settingsData.getFirstSuccessfulKey(
      legalPrivacySettingsKeys(),
    );
    if (response.isSuccess) {
      privacyPolicy = response.data['value'];
    }
    isLoading = false;
    update();
  }
}
