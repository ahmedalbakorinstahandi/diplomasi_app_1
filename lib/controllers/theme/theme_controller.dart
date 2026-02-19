import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeControllerImp extends GetxController {
  ThemeMode themeMode = ThemeMode.system;

  bool get useSystemTheme => themeMode == ThemeMode.system;
  bool get isDarkOverride => themeMode == ThemeMode.dark;

  ThemeControllerImp() {
    _loadThemeMode();
  }


  void _loadThemeMode() {
    final stored = Shared.getValue(StorageKeys.themeMode) as String?;
    themeMode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    Shared.setValue(
      StorageKeys.themeMode,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
    Get.changeThemeMode(mode);
    update();
  }

  void setUseSystemTheme(bool enabled) {
    if (enabled) {
      setThemeMode(ThemeMode.system);
    } else {
      // Default to light when leaving system mode.
      if (themeMode == ThemeMode.system) {
        setThemeMode(ThemeMode.light);
      } else {
        update();
      }
    }
  }

  /// Only meaningful when NOT using system theme.
  void setDarkModeEnabled(bool enabled) {
    setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}

