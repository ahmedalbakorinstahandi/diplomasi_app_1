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
    var response = await settingsData.get(idOrKey: "legal.terms_conditions");
    if (response.isSuccess) {
      termsConditions = response.data['value'];
    }
    isLoading = false;
    update();
  }
}
