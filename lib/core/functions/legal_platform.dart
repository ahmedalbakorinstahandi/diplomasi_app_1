import 'package:diplomasi_app/core/constants/variables.dart';

/// Keys to try for legal HTML settings: platform-specific first, then general.
List<String> legalTermsSettingsKeys() {
  return _keysWithPlatformFallback('legal.terms_conditions');
}

List<String> legalPrivacySettingsKeys() {
  return _keysWithPlatformFallback('legal.privacy_policy');
}

List<String> _keysWithPlatformFallback(String baseKey) {
  if (isEffectiveIOS) {
    return ['${baseKey}_ios', baseKey];
  }
  if (isEffectiveAndroid) {
    return ['${baseKey}_android', baseKey];
  }
  return [baseKey];
}
