import 'package:diplomasi_app/core/localization/changelocale.dart';
import 'package:intl/intl.dart';

/// Parses an API UTC timestamp (e.g. ISO 8601) and returns local DateTime for display.
/// Backend always returns UTC; use this so UI shows device local time.
DateTime parseUtcToLocal(String date) {
  return DateTime.parse(date).toLocal();
}

/// Date only — use for fields that represent a calendar date (e.g. issued_at as date).
/// Output: e.g. "2026-03-05" or locale equivalent.
String formatDateOnly(String? date) {
  if (date == null || date.isEmpty) return '';
  try {
    final dateTime = parseUtcToLocal(date);
    return DateFormat(
      'yyyy-MM-dd',
      LocaleController.languageCode,
    ).format(dateTime);
  } catch (_) {
    return date;
  }
}

/// Date + time with hours, minutes, seconds and AM/PM.
/// Output: e.g. "2026-03-05 02:30:45 م" or "2026-03-05 10:15:00 ص".
String formatDateTime(String? date) {
  if (date == null || date.isEmpty) return '';
  try {
    final dateTime = parseUtcToLocal(date);
    return DateFormat(
      'yyyy-MM-dd hh:mm:ss a',
      LocaleController.languageCode,
    ).format(dateTime);
  } catch (_) {
    return date;
  }
}

/// Time only — hours, minutes, seconds, AM/PM.
String formatTimeOnly(String? date) {
  if (date == null || date.isEmpty) return '';
  try {
    final dateTime = parseUtcToLocal(date);
    return DateFormat(
      'hh:mm:ss a',
      LocaleController.languageCode,
    ).format(dateTime);
  } catch (_) {
    return date;
  }
}

/// Relative date for lists (e.g. notifications): اليوم / أمس / يوم شهر.
String formatDateRelative(String? dateString) {
  if (dateString == null || dateString.isEmpty) return dateString ?? '';
  try {
    final date = parseUtcToLocal(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'اليوم';
    }
    if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'أمس';
    }
    return '${date.day} ${_monthNameAr(date.month)}';
  } catch (_) {
    return dateString;
  }
}

String _monthNameAr(int month) {
  const months = [
    '',
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return months[month];
}

/// Date only with language (legacy name).
String formatDateWithLanguage(String date) {
  return formatDateOnly(date);
}

/// Date only from DateTime (e.g. for date picker display).
String formatDateByDate(DateTime date) {
  return DateFormat('yyyy-MM-dd', LocaleController.languageCode).format(date);
}

/// Date only, neutral locale (legacy).
String formatDate(String date) {
  if (date.isEmpty) return '';
  try {
    final dateTime = parseUtcToLocal(date);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (_) {
    return date;
  }
}

/// Date + time with AM/PM (legacy — same as formatDateTime).
String formatDateAndTime(String date) {
  return formatDateTime(date);
}

/// 24h time only (legacy).
String formatTime24Hour(String dateTimeString) {
  if (dateTimeString.isEmpty) return '';
  try {
    final dateTime = parseUtcToLocal(dateTimeString);
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } catch (_) {
    return dateTimeString;
  }
}
