import 'package:flutter_timezone/flutter_timezone.dart';

/// Returns headers for timezone context to send with API requests.
/// - X-Timezone: IANA timezone identifier (e.g. Asia/Damascus)
/// - X-UTC-Offset-Minutes: offset from UTC in minutes (optional, for fallback)
Future<Map<String, String>> getTimezoneHeaders() async {
  String ianaTimezone = 'UTC';
  int offsetMinutes = 0;

  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    ianaTimezone = timezoneInfo.identifier;
    offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  } catch (_) {
    // Fallback: use offset only when IANA lookup fails
    offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
  }

  return {
    'X-Timezone': ianaTimezone,
    'X-UTC-Offset-Minutes': offsetMinutes.toString(),
  };
}
