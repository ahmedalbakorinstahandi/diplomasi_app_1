import 'dart:math';

double getRandomDecimal(double min, double max) {
  final random = Random();
  // توليد الرقم العشوائي مع تحديد خانة واحدة بعد الفاصلة
  double value = min + random.nextDouble() * (max - min);
  return double.parse(value.toStringAsFixed(1)); // استخدام .toStringAsFixed(1)
}

int getRandomInt(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1); // +1 لضمان شمول الحد الأعلى
}
