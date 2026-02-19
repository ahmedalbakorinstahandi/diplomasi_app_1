import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;
  MyServices._();
  static initialServices() async {
    await Get.putAsync(() => MyServices._()._init());
  }

  Future<MyServices> _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }
}
