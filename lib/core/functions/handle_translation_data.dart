import 'package:diplomasi_app/core/localization/changelocale.dart';

getLocalizedValue(Map data, {bool fallbackToDefault = true}) {
  var languageCode = LocaleController.getLocalLang().languageCode;
  String? res;

  if (data.containsKey(languageCode)) {
    res = data[languageCode];
  }

  if (fallbackToDefault && (res == '' || res == null)) {
    res = data['en'];
  }

  return res ?? "";
}
