import 'dart:convert';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/services/services.dart';

class Shared extends GetxController {
  static MyServices myServices = Get.find();
  @override
  void onInit() {
    //MyServices.initialServices();
    super.onInit();
  }

  static setValue(key, value) {
    if (value is String) {
      myServices.sharedPreferences.setString(key, value);
    }
    if (value is bool) {
      myServices.sharedPreferences.setBool(key, value);
    }
    if (value is double) {
      myServices.sharedPreferences.setDouble(key, value);
    }
    if (value is int) {
      myServices.sharedPreferences.setInt(key, value);
    }
    if (value is List<String>) {
      myServices.sharedPreferences.setStringList(key, value);
    }
    if (value is Map || value is List) {
      myServices.sharedPreferences.setString(key, json.encode(value));
    }
  }

  static getValue(key, {Object? initialValue}) {
    return myServices.sharedPreferences.get(key) ?? initialValue;
  }

  static remove(key) {
    return myServices.sharedPreferences.remove(key);
  }

  static getMapValue(key) {
    String value = myServices.sharedPreferences.get(key).toString();

    return json.decode(value) ?? {};
  }

  static Map<String, dynamic>? getMapValueOrNull(key) {
    final value = myServices.sharedPreferences.get(key);
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static getListValue(key) {
    String value = myServices.sharedPreferences.get(key).toString();

    return json.decode(value) ?? [];
  }

  static clear() {
    myServices.sharedPreferences.clear();
  }
}
