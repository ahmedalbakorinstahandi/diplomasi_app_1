import 'package:get/get.dart';
import 'package:diplomasi_app/core/localization/changelocale.dart';
import 'package:diplomasi_app/core/localization/languages/ar.dart';

class MyTranslation extends Translations {
  static var languages = {
    // 'en': en,
    'ar': ar,
  };
  @override
  Map<String, Map<String, String>> get keys => languages;

  static String get currentLanguage => LocaleController.languageCode;

  // Function to get key from value
  static String getKeyFromValue(String value) {
    // Get the current language map based on the current language code
    Map<String, String>? translations = languages[currentLanguage];

    if (translations == null) {
      return ''; // Return empty if no translations found
    }

    // Search for the key that matches the given value
    return translations.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }
}
