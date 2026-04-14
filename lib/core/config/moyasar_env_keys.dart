import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads optional Moyasar **publishable** keys from `.env` (must be `pk_*`).
/// Secret keys (`sk_*`) must never be used in the mobile SDK — they stay on the server.
class MoyasarEnvKeys {
  MoyasarEnvKeys._();

  static String normalizeMode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'test';
    }
    final m = raw.toLowerCase().trim();
    if (m == 'live' || m == 'production') {
      return 'live';
    }
    return 'test';
  }

  /// When the API is unreachable: `MOYASAR_MODE=test|live` in `.env`.
  static String modeFromEnv() {
    return normalizeMode(dotenv.env['MOYASAR_MODE']);
  }

  /// ISO 4217 for Moyasar (must match backend `MOYASAR_CURRENCY`).
  static String billingCurrencyFromEnv() {
    final raw = dotenv.env['MOYASAR_CURRENCY']?.trim();
    if (raw == null || raw.isEmpty) {
      return 'USD';
    }
    return raw.toUpperCase();
  }

  static String? _firstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) {
        return c;
      }
    }
    return null;
  }

  static String? _sanitizePublishable(String? key) {
    if (key == null) {
      return null;
    }
    final t = key.trim();
    if (t.isEmpty) {
      return null;
    }
    if (t.startsWith('sk_')) {
      return null;
    }
    return t;
  }

  /// Pick local publishable key for [mode] (`test` | `live`).
  static String? publishableForMode(String mode) {
    final m = normalizeMode(mode);
    final raw = m == 'live'
        ? _firstNonEmpty([
            dotenv.env['MOYASAR_LIVE_PUBLIC_KEY'],
            dotenv.env['MOYASAR_LIVE_PUBLISHABLE_KEY'],
          ])
        : _firstNonEmpty([
            dotenv.env['MOYASAR_TEST_PUBLIC_KEY'],
            dotenv.env['MOYASAR_TEST_PUBLISHABLE_KEY'],
          ]);
    return _sanitizePublishable(raw);
  }
}
