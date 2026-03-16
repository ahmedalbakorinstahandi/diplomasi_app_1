import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

bool isInternetConnected = true;

UserModel? getUserData() {
  var userData = Shared.getMapValue('user-data');
  if (userData.isEmpty) {
    return null;
  }
  try {
    return UserModel.fromJson(userData);
  } catch (e) {
    return null;
  }
}

bool get isUserLoggedIn {
  return Shared.getValue(StorageKeys.step, initialValue: Steps.login) ==
      Steps.homeApp;
}

int get notificationsUnreadCount {
  return Shared.getValue('notifications_unread_count', initialValue: 0);
}

bool get showMultipleInputLanguages => false;

bool get isDarkMode {
  return Theme.of(Get.context!).brightness == Brightness.dark;
}

bool get isVisible {
  return true;
}
