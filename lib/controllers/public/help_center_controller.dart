import 'package:diplomasi_app/data/resource/remote/general/settings_data.dart';
import 'package:get/get.dart';

abstract class HelpCenterController extends GetxController {
  String helpCenter = '';

  SettingsData settingsData = SettingsData();

  bool isLoading = false;

  Future<void> getHelpCenter();
}

class HelpCenterControllerImp extends HelpCenterController {
  @override
  void onInit() {
    super.onInit();
    getHelpCenter();
  }

  @override
  Future<void> getHelpCenter() async {
    isLoading = true;
    update();
    var response = await settingsData.get(idOrKey: "app.help_center");
    if (response.isSuccess) {
      helpCenter = response.data['value'];
    }
    isLoading = false;
    update();
  }
}