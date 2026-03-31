import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/steps.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

/// How the app treats the current platform (for testing).
/// Use [real] in production. Change to [forceAndroid] or [forceIOS] manually
/// to test platform-specific flows (e.g. subscriptions/payments) without a real device.
enum AppPlatformMode { real, forceAndroid, forceIOS }

/// Current platform mode. Change manually for testing; set back to [AppPlatformMode.real] when done.
AppPlatformMode appPlatformMode = AppPlatformMode.real;

bool get isTestPlatformOverrideEnabled =>
    appPlatformMode != AppPlatformMode.real;

bool get isEffectiveIOS =>
    appPlatformMode == AppPlatformMode.forceIOS ||
    (appPlatformMode == AppPlatformMode.real && Platform.isIOS);

bool get isEffectiveAndroid =>
    appPlatformMode == AppPlatformMode.forceAndroid ||
    (appPlatformMode == AppPlatformMode.real && Platform.isAndroid);

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

String get currentAccountState {
  final fromStorage = Shared.getValue(StorageKeys.accountState, initialValue: '');
  if (fromStorage is String && fromStorage.isNotEmpty) {
    return fromStorage;
  }

  final user = getUserData();
  if (user == null) {
    return 'unauthenticated';
  }

  return user.accountState;
}

bool get isGuestAccount => currentAccountState == 'guest';

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
