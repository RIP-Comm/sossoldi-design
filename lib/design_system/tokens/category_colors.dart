// Category / account colors, from the Figma frame "Palette - Categories".
// They are not Figma variables. Each color comes as a pair that always
// travels together: [CategoryColor.main] (saturated) and its lighter
// L 90 variant [CategoryColor.tint], used for backgrounds such as the
// track of a budget bar. Used for both categories and accounts.

import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

class CategoryColor {
  const CategoryColor(this.main, this.tint);

  /// Saturated color: icons, dots, filled part of a bar.
  final Color main;

  /// Light-mode companion (L 90).
  final Color tint;

  /// Opacity of [main] used as companion in dark mode, where the L 90
  /// variant would be too bright.
  static const double darkTintAlpha = 0.2;

  /// Companion color for the given brightness.
  Color tintFor(Brightness brightness) => brightness == Brightness.dark
      ? main.withValues(alpha: darkTintAlpha)
      : tint;
}

abstract final class CategoryColors {
  static const all = <CategoryColor>[
    CategoryColor(Color(0xFFFF4754), Color(0xFFFFCCD0)),
    CategoryColor(Color(0xFFF26A52), Color(0xFFFBD6D0)),
    CategoryColor(Color(0xFFF36127), Color(0xFFFCDCCF)),
    CategoryColor(Color(0xFFB64C22), Color(0xFFF7DED4)),
    CategoryColor(Color(0xFFF68428), Color(0xFFFDE3CE)),
    CategoryColor(Color(0xFFFC9619), Color(0xFFFEE8CD)),
    CategoryColor(Color(0xFFEBC35F), Color(0xFFF9EED2)),
    CategoryColor(Color(0xFFD3DD16), Color(0xFFF8FAD1)),
    CategoryColor(Color(0xFFC3EE07), Color(0xFFF5FECD)),
    CategoryColor(Color(0xFF94E30C), Color(0xFFECFCCF)),
    CategoryColor(Color(0xFF5BE30C), Color(0xFFDFFCCF)),
    CategoryColor(Color(0xFF0BC11D), Color(0xFFCFFCD3)),
    CategoryColor(Color(0xFF109B37), Color(0xFFD1FADC)),
    CategoryColor(Color(0xFF417388), Color(0xFFDCE9EF)),
    CategoryColor(Color(0xFF32A1A7), Color(0xFFD8F2F3)),
    CategoryColor(Color(0xFF13C9A2), Color(0xFFD1FAF1)),
    CategoryColor(Color(0xFF16DCB1), Color(0xFFD1FAF1)),
    CategoryColor(Color(0xFF11D6E1), Color(0xFFD0F9FB)),
    CategoryColor(Color(0xFF12BFCE), Color(0xFFD0F7FB)),
    CategoryColor(Color(0xFF16ADDF), Color(0xFFD1F0FA)),
    CategoryColor(Color(0xFF3284A7), Color(0xFFD8EBF3)),
    CategoryColor(Color(0xFF068DC7), Color(0xFFCEEFFD)),
    CategoryColor(Color(0xFF326AAF), Color(0xFFD7E4F4)),
    CategoryColor(Color(0xFF6B91C0), Color(0xFFDBE4F0)),
    CategoryColor(Color(0xFF3B90F9), Color(0xFFCEE3FD)),
    CategoryColor(Color(0xFF2675E3), Color(0xFFD2E2F9)),
    CategoryColor(Color(0xFF5819E0), Color(0xFFDED1FA)),
    CategoryColor(Color(0xFF593F92), Color(0xFFE2DBF0)),
    CategoryColor(Color(0xFF8C6AD4), Color(0xFFE0D8F3)),
    CategoryColor(Color(0xFF7236D3), Color(0xFFE2D5F6)),
    CategoryColor(Color(0xFF9827E2), Color(0xFFE9D2F9)),
    CategoryColor(Color(0xFFB655F6), Color(0xFFEACFFC)),
    CategoryColor(Color(0xFF6E3593), Color(0xFFE8D9F2)),
    CategoryColor(Color(0xFF7212B1), Color(0xFFEAD1FA)),
    CategoryColor(Color(0xFFAF12B1), Color(0xFFFAD1FA)),
    CategoryColor(Color(0xFFE31FE6), Color(0xFFF9D1FA)),
    CategoryColor(Color(0xFFD336B6), Color(0xFFF6D5F0)),
    CategoryColor(Color(0xFFF699E5), Color(0xFFFBD0F3)),
    CategoryColor(Color(0xFFCA0A7D), Color(0xFFFDCEEA)),
    CategoryColor(Color(0xFFEC3972), Color(0xFFFBD0DE)),
    CategoryColor(Color(0xFFD30547), Color(0xFFFECDDD)),
    CategoryColor(Color(0xFFD41017), Color(0xFFFBD0D1)),
  ];
}
