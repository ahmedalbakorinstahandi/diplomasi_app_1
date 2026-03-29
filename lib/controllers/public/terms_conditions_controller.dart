import 'package:diplomasi_app/core/functions/legal_platform.dart';
import 'package:diplomasi_app/data/resource/remote/general/settings_data.dart';
import 'package:get/get.dart';

abstract class TermsConditionsController extends GetxController {
  String termsConditions = '';

  SettingsData settingsData = SettingsData();

  bool isLoading = false;

  Future<void> getTermsConditions();
}

class TermsConditionsControllerImp extends TermsConditionsController {
  @override
  void onInit() {
    super.onInit();
    getTermsConditions();
  }

  @override
  Future<void> getTermsConditions() async {
    isLoading = true;
    update();
    var response = await settingsData.getFirstSuccessfulKey(
      legalTermsSettingsKeys(),
    );
    if (response.isSuccess) {
      termsConditions = response.data['value'];
    }
    isLoading = false;
    update();
  }
}
