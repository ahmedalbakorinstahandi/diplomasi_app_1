import 'package:flutter/material.dart';

/// App-wide semantic colors.
///
/// IMPORTANT:
/// - Widgets should NOT use hard-coded colors (no `Color(0x...)`, no `Colors.*`).
/// - Widgets should read colors from `ThemeData` via:
///   `Theme.of(context).colorScheme` OR `Theme.of(context).extension<AppColors>()`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Brand
  final Color brandPrimary;
  final Color brandSecondary;
  final Color brandTertiary;

  // Backgrounds / Surfaces
  final Color backgroundPrimary; // scaffold/screen background
  final Color backgroundSecondary; // subtle sections
  final Color surface; // generic surface
  final Color surfaceCard; // card surface

  // Content
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color iconPrimary;

  // Lines / Shadows
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color shadow;

  // States
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;
  final Color info;
  final Color onInfo;

  // Feature accents (used for premium/badges)
  final Color highlight;
  final Color highlightText;
  final Color onHighlight;

  // Shimmer
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.brandTertiary,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconPrimary,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.shadow,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.info,
    required this.onInfo,
    required this.highlight,
    required this.highlightText,
    required this.onHighlight,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Light palette (mapped from current app colors).
  static const AppColors light = AppColors(
    brandPrimary: Color(0xFF062B4C),
    brandSecondary: Color(0xFFFCAC19),
    brandTertiary: Color(0xFF00749F),
    backgroundPrimary: Color(0xFFF8F9FA),
    backgroundSecondary: Color(0xFFFBFBFB),
    surface: Color(0xFFFFFFFF),
    surfaceCard: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF24414B),
    textSecondary: Color(0xFF6A8094),
    textMuted: Color(0xFF8295A5),
    iconPrimary: Color(0xFF24414B),
    border: Color(0xFFE6EAED),
    borderStrong: Color(0xFF8295A5),
    divider: Color(0xFFE6EAED),
    shadow: Color(0x1A000000), // 10% black
    success: Color(0xFF1AD598),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFFFC32C),
    onWarning: Color(0xFF24414B),
    error: Color(0xFFEA3A3D),
    onError: Color(0xFFFFFFFF),
    info: Color(0xFF00749F),
    onInfo: Color(0xFFFFFFFF),
    highlight: Color(0xFFFFC32C),
    highlightText: Color(0xFF915032),
    onHighlight: Color(0xFF24414B),
    shimmerBase: Color(0xFFE6EAED),
    shimmerHighlight: Color(0xFFF5F7F8),
  );

  /// Dark palette (used later by DarkTheme).
  static const AppColors dark = AppColors(
    brandPrimary: Color(0xFF8AB4F8),
    brandSecondary: Color(0xFFFFC32C),
    brandTertiary: Color(0xFF4FB3D9),
    backgroundPrimary: Color(0xFF0B1220),
    backgroundSecondary: Color(0xFF0F172A),
    surface: Color(0xFF0F172A),
    surfaceCard: Color(0xFF111C33),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFB7C5D3),
    textMuted: Color(0xFF93A4B5),
    iconPrimary: Color(0xFFF8FAFC),
    border: Color(0xFF22304A),
    borderStrong: Color(0xFF344764),
    divider: Color(0xFF22304A),
    shadow: Color(0x66000000),
    success: Color(0xFF23D9A3),
    onSuccess: Color(0xFF0B1220),
    warning: Color(0xFFFFD15C),
    onWarning: Color(0xFF0B1220),
    error: Color(0xFFFF5C5C),
    onError: Color(0xFF0B1220),
    info: Color(0xFF4FB3D9),
    onInfo: Color(0xFF0B1220),
    highlight: Color(0xFFFFD15C),
    highlightText: Color(0xFFFFF3D1),
    onHighlight: Color(0xFF0B1220),
    shimmerBase: Color(0xFF1B2A3F),
    shimmerHighlight: Color(0xFF243753),
  );

  @override
  AppColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? brandTertiary,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surface,
    Color? surfaceCard,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? iconPrimary,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? shadow,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
    Color? info,
    Color? onInfo,
    Color? highlight,
    Color? highlightText,
    Color? onHighlight,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandTertiary: brandTertiary ?? this.brandTertiary,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      highlight: highlight ?? this.highlight,
      highlightText: highlightText ?? this.highlightText,
      onHighlight: onHighlight ?? this.onHighlight,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      brandTertiary: Color.lerp(brandTertiary, other.brandTertiary, t)!,
      backgroundPrimary: Color.lerp(
        backgroundPrimary,
        other.backgroundPrimary,
        t,
      )!,
      backgroundSecondary: Color.lerp(
        backgroundSecondary,
        other.backgroundSecondary,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightText: Color.lerp(highlightText, other.highlightText, t)!,
      onHighlight: Color.lerp(onHighlight, other.onHighlight, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

extension AppColorsContextX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
