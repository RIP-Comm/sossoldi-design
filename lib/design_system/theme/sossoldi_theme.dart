import 'package:flutter/material.dart';

import '../tokens/font_tokens.dart';
import 'sossoldi_colors.dart';
import 'sossoldi_typography.dart';

/// Builds the app ThemeData. Widgets read design values from the
/// [SossoldiColors] and [SossoldiTypography] extensions via
/// `context.colors` and `context.typography`, never from Material defaults.
abstract final class SossoldiTheme {
  static ThemeData get light => _build(Brightness.light, SossoldiColors.light);
  static ThemeData get dark => _build(Brightness.dark, SossoldiColors.dark);

  static ThemeData _build(Brightness brightness, SossoldiColors colors) {
    final typography = SossoldiTypography.standard;
    return ThemeData(
      brightness: brightness,
      fontFamily: SossoldiFont.family,
      scaffoldBackgroundColor: colors.surfaceLow,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary.surface,
        onPrimary: colors.primary.onSurface,
        secondary: colors.primary.surface,
        onSecondary: colors.primary.onSurface,
        error: colors.error.onSurface,
        onError: colors.surfaceHigh,
        surface: colors.surfaceMed,
        onSurface: colors.textHigh,
      ),
      extensions: [colors, typography],
    );
  }
}

extension SossoldiThemeContext on BuildContext {
  SossoldiColors get colors => Theme.of(this).extension<SossoldiColors>()!;
  SossoldiTypography get typography =>
      Theme.of(this).extension<SossoldiTypography>()!;
}
