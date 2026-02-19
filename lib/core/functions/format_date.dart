import 'package:diplomasi_app/core/localization/changelocale.dart';
import 'package:intl/intl.dart';

String formatDateWithLanguage(String date) {
  DateTime dateTime = DateTime.parse(date);

  String formattedDate = DateFormat(
    'yyyy-MM-dd',
    LocaleController.languageCode,
  ).format(dateTime);

  return formattedDate;
}

String formatDateByDate(DateTime date) {
  String formattedDate = DateFormat(
    'yyyy-MM-dd',
    LocaleController.languageCode,
  ).format(date);

  return formattedDate;
}

String formatDate(String date) {
  DateTime dateTime = DateTime.parse(date);

  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}

String formatDateAndTime(String date) {
  DateTime dateTime = DateTime.parse(date);

  String formattedDate = DateFormat(
    'yyyy-MM-dd | hh:mm a',
    LocaleController.languageCode,
  ).format(dateTime);

  return formattedDate;
}

String formatTime24Hour(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String hours = dateTime.hour.toString().padLeft(2, '0');
  String minutes = dateTime.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

// String formatDateTime(String dateTimeString) {
//   DateTime dateTime = DateTime.parse(dateTimeString);

//   String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
//   String formattedTime = DateFormat('hh:mm a').format(dateTime);

//   return '$formattedDate | $formattedTime';
// }
