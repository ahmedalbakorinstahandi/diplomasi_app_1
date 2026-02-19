import 'package:get/get_utils/get_utils.dart';

abstract class TranslationFile {
//Validator
  static String get fieldRequired => ('field_required').tr;
  static String get invalidText => ('invalid_text').tr;
  static String get invalidEmail => ('invalid_email').tr;
  static String get invalidPhone => ('invalid_phone').tr;
  static String get invalidPasswordUppercase =>
      ('invalid_password_uppercase').tr;
  static String get invalidPasswordLowercase =>
      ('invalid_password_lowercase').tr;
  static String get invalidPasswordDigit => ('invalid_password_digit').tr;
  static String get invalidPasswordSpecial => ('invalid_password_special').tr;
  static String get invalidNumber => ('invalid_number').tr;
  static String get invalidPrice => ('invalid_price').tr;
  static String get invalidCount => ('invalid_count').tr;
  static String get invalidUrl => ('invalid_url').tr;
  static String get invalidDescription => ('invalid_description').tr;
  static String get invalidDate => ('invalid_date').tr;
  static String get invalidTime => ('invalid_time').tr;
  static String get minLength => ('min_length').tr;
  static String get maxLength => ('max_length').tr;
  static String get minValue => ('min_value').tr;
  static String get maxValue => ('max_value').tr;
}
