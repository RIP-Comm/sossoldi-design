// The space of the free colors of accounts and categories, the one the color
// picker moves in. It is HCT (material_color_utilities): the tone, which is
// the perceived lightness, stays fixed while hue and chroma change, so every
// hue looks as light as the others and a yellow does not jump out next to a
// blue. The palette of [CategoryColors] is the reference: its colors sit around
// this tone and keep most of the chroma the hue can have.

import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:material_color_utilities/material_color_utilities.dart';

abstract final class CategoryColorSpace {
  /// The fixed tone. The palette goes from 32 to 88 with a median of 56;
  /// 60 keeps text and icons readable on the tint and the dots visible.
  static const double tone = 60;

  /// Where the hue slider starts and how far it goes (degrees of HCT hue):
  /// orange to red, as the track of the Figma slider, a little short of a
  /// whole turn so that the two ends are different colors.
  static const double hueStart = 30;
  static const double hueSpan = 350;

  /// The saturation slider goes from [minSaturation] to [maxSaturation] of
  /// the chroma the hue can have at [tone]. The floor keeps colors from
  /// turning grey (the greyest of the palette has 29 of chroma, at a hue that
  /// has 41 at most).
  static const double minSaturation = 0.6;
  static const double maxSaturation = 1.0;

  /// No color is more saturated than the most saturated of the palette (97
  /// of chroma): the pinks could have a little more at this tone.
  static const double chromaCeiling = 97;

  static final Map<int, double> _maxChroma = {};

  /// The most chroma [hue] (degrees) can have at [tone] inside sRGB, up to
  /// [chromaCeiling].
  static double maxChroma(double hue) => _maxChroma.putIfAbsent(
    hue.round() % 360,
    () =>
        math.min(Hct.from(hue.round() % 360, 200, tone).chroma, chromaCeiling),
  );

  /// Hue (degrees) at [position] of the hue slider, 0 to 1.
  static double hueAt(double position) =>
      (hueStart + position.clamp(0.0, 1.0) * hueSpan) % 360;

  /// Position of the hue slider closest to [hue]. The hues in the gap between
  /// the two ends go to the nearer end.
  static double hueToPosition(double hue) {
    final offset = ((hue - hueStart) % 360 + 360) % 360;
    if (offset <= hueSpan) return offset / hueSpan;
    return offset - hueSpan < 360 - offset ? 1 : 0;
  }

  /// Chroma at [position] of the saturation slider, 0 to 1, for [hue].
  static double chromaAt(double hue, double position) =>
      maxChroma(hue) *
      (minSaturation +
          position.clamp(0.0, 1.0) * (maxSaturation - minSaturation));

  /// The color at the given positions of the two sliders.
  static Color colorAt(double huePosition, double saturationPosition) {
    final hue = hueAt(huePosition);
    return Color(
      Hct.from(hue, chromaAt(hue, saturationPosition), tone).toInt(),
    );
  }

  /// The positions of the two sliders closest to [color] (any color: those of
  /// the palette are at other tones).
  static ({double hue, double saturation}) positionsOf(Color color) {
    final hct = Hct.fromInt(color.toARGB32());
    final max = maxChroma(hct.hue);
    final fraction = max <= 0 ? maxSaturation : hct.chroma / max;
    return (
      hue: hueToPosition(hct.hue),
      saturation: ((fraction - minSaturation) / (maxSaturation - minSaturation))
          .clamp(0.0, 1.0),
    );
  }
}
