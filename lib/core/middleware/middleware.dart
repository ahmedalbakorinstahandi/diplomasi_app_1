import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';

class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    String mainRoute = AppRoutes.home;
    Future.delayed(const Duration(seconds: 1), () {
      int step = Shared.getValue(StorageKeys.step, initialValue: 0);
      switch (step) {
        case 0:
          Get.offNamed(mainRoute);
          break;
        case 1:
          Get.offNamed(mainRoute);
          break;
        default:
          Get.offNamed(mainRoute);
      }
    });

    return RouteSettings(name: mainRoute);
  }
}
