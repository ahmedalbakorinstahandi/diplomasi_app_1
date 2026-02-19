import 'package:get/get.dart';
import 'package:diplomasi_app/core/constants/translation_file.dart';

class MyValidator {
  static String? validate(
    String? value, {
    required ValidatorType type,
    String fieldName = 'هذا الحقل',
    int? min,
    int? max,
    bool required = true,
  }) {
    value = value ?? "";

    if (required && value.trim().isEmpty) {
      // return "${fieldName.tr} ${TranslationFile.fieldRequired}";
      return "${fieldName.tr} مطلوب";
    }

    switch (type) {
      case ValidatorType.text:
        // if (!GetUtils.isTxt(value)) {
        //   return "${fieldName.tr} ${TranslationFile.invalidText}";
        // }
        break;

      case ValidatorType.email:
        if (!GetUtils.isEmail(value) && required) {
          return "${fieldName.tr} ${TranslationFile.invalidEmail}";
        }
        break;

      case ValidatorType.phone:
        if (!GetUtils.isPhoneNumber(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidPhone}";
        }
        break;

      case ValidatorType.password:
        // if (!RegExp(r'[A-Z]').hasMatch(value)) {
        //   return "${fieldName.tr} ${TranslationFile.invalidPasswordUppercase}";
        // }
        // if (!RegExp(r'[a-z]').hasMatch(value)) {
        //   return "${fieldName.tr} ${TranslationFile.invalidPasswordLowercase}";
        // }
        // if (!RegExp(r'[0-9]').hasMatch(value)) {
        //   return "${fieldName.tr} ${TranslationFile.invalidPasswordDigit}";
        // }
        // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        //   return "${fieldName.tr} ${TranslationFile.invalidPasswordSpecial}";
        // }
        break;

      case ValidatorType.number:
        if (!GetUtils.isNumericOnly(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidNumber}";
        }
        break;

      case ValidatorType.price:
        if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidPrice}";
        }
        break;

      case ValidatorType.count:
        if (!GetUtils.isNumericOnly(value) || int.tryParse(value) == null) {
          return "${fieldName.tr} ${TranslationFile.invalidCount}";
        }
        break;

      case ValidatorType.url:
        if (!GetUtils.isURL(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidUrl}";
        }
        break;

      case ValidatorType.description:
        if (value.length < 10) {
          return "${fieldName.tr} ${TranslationFile.invalidDescription}";
        }
        break;

      case ValidatorType.date:
        if (!GetUtils.isDateTime(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidDate}";
        }
        break;

      case ValidatorType.time:
        if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
          return "${fieldName.tr} ${TranslationFile.invalidTime}";
        }
        break;

      case ValidatorType.dropdown:
        return null;
    }

    switch (type) {
      case ValidatorType.number:
      case ValidatorType.price:
      case ValidatorType.count:
        if (min != null && int.parse(value) < min) {
          return "${fieldName.tr} ${TranslationFile.minValue.trParams({'min': min.toString()})}";
        }
        if (max != null && int.parse(value) > max) {
          return "${fieldName.tr} ${TranslationFile.maxValue.trParams({'max': max.toString()})}";
        }
        break;

      default:
        if (min != null && value.trim().length < min) {
          return "${fieldName.tr} ${TranslationFile.minLength.trParams({'min': min.toString()})}";
        }

        if (max != null && value.trim().length > max) {
          return "${fieldName.tr} ${TranslationFile.maxLength.trParams({'max': max.toString()})}";
        }
        break;
    }

    return null;
  }
}

enum ValidatorType {
  text, // نصوص عامة
  email, // البريد الإلكتروني
  phone, // أرقام الهواتف
  password, // كلمات المرور
  number, // أرقام فقط
  price, // أسعار
  count, // الأعداد
  url, // الروابط
  description, // الوصف
  date, // التاريخ
  time, // الوقت
  dropdown, // الوقت
}
