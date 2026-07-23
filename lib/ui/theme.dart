import 'package:flutter/material.dart';

/// Approximates the design's OKLCH hue-based palette using HSL, since
/// Flutter's Color has no native OKLCH support. Visually close enough for
/// parity with the prototype.
Color hueColor(double hue, {double lightness = 0.55, double saturation = 0.55}) {
  return HSLColor.fromAHSL(1, hue % 360, saturation, lightness).toColor();
}

Color hueColorAlpha(
  double hue,
  double alpha, {
  double lightness = 0.6,
  double saturation = 0.55,
}) {
  return HSLColor.fromAHSL(alpha, hue % 360, saturation, lightness).toColor();
}

class SiftColors {
  const SiftColors._();

  static const double accentHue = 250;
  static Color get accent => hueColor(accentHue, lightness: 0.52);
  static Color get accentDark => hueColor(accentHue, lightness: 0.42);
  static Color get accentSoft => hueColorAlpha(accentHue, 0.1, lightness: 0.55);
  static Color get accentSoftBorder =>
      hueColorAlpha(accentHue, 0.16, lightness: 0.55);

  static const Color background = Color(0xFFE9E7E2);
  static const Color surface = Colors.white;
  static const Color sidebar = Color(0xFFF6F7F9);
  static const Color border = Color(0xFFE6E9EE);
  static const Color textPrimary = Color(0xFF1B2432);
  static const Color textSecondary = Color(0xFF5B647A);
  static const Color textMuted = Color(0xFF9AA4B2);
  static const Color danger = Color(0xFFC0483F);
  static const Color warning = Color(0xFFB4750F);
  static const Color warningSoft = Color(0xFFFBF0DD);

  static const Map<String, double> docTypeHue = {
    'PDF': 30,
    'DOC': 280,
    'IMG': 90,
    'XLS': 150,
    'PPT': 220,
    'TXT': 250,
  };
}

const _sansFamily = 'IBM Plex Sans';
const _monoFamily = 'IBM Plex Mono';

ThemeData buildSiftTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SiftColors.accent,
      primary: SiftColors.accent,
    ),
    scaffoldBackgroundColor: SiftColors.background,
    fontFamily: _sansFamily,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: SiftColors.surface,
      foregroundColor: SiftColors.textPrimary,
      elevation: 0,
    ),
  );
}

TextStyle monoStyle({
  double fontSize = 11,
  FontWeight fontWeight = FontWeight.w500,
  Color color = SiftColors.textMuted,
}) => TextStyle(
  fontFamily: _monoFamily,
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
);
