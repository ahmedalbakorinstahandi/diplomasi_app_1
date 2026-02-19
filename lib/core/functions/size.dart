import 'package:get/get.dart';

getHeight() {
  return Get.size.height * 1;
}

double getWidth() {
  return Get.size.width * 1;
}

double width(x) {
  return x * getWidth() / 411.428;
}

double height(x) {
  return x * getHeight() / 914.285;
}

double emp(x) {
  var r = ((x * getHeight() / 914.285) + (x * getWidth() / 411.428)) / 2;
  return r;
}
