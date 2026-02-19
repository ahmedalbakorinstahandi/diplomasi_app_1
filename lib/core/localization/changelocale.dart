import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/assets.dart';

class LocaleController extends GetxController {
  static String languageCode = getLocalLang().languageCode;

  static changeLang(String langCode) async {
    languageCode = langCode;
    Shared.setValue("langCode", langCode);
    Locale locale = Locale(langCode);
    // final langData = myLanguages[langCode];
    // ltr = langData?['dir'] == 'ltr';
    ltr = false;

    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    getLocalLang();
    super.onInit();
  }

  static Locale getLocalLang() {
    String myLangCode = Shared.getValue(
      'langCode',
      initialValue: Get.deviceLocale?.languageCode ?? 'en',
      // initialValue: 'en',
    );

    if (!myLanguages.containsKey(myLangCode)) {
      myLangCode = 'ar';
    }

    // myLangCode = 'ar';

    // final langData = myLanguages[myLangCode];
    // ltr = langData?['dir'] == 'ltr';
    ltr = false;

    return Locale(myLangCode);
  }
}

bool ltr = false;

Map<String, Map> myLanguages = {
  'ar': {'name': 'عربي', 'dir': 'rtl', 'image': Assets.icons.svg.ar},
  'en': {'name': 'English', 'dir': 'ltr', 'image': Assets.icons.svg.en},
};
