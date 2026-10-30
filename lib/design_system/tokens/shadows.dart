// Shadow styles, from the Figma effect styles.

import 'package:flutter/painting.dart';

abstract final class SossoldiShadows {
  /// Figma: New/Shadow/S
  static const s = [
    BoxShadow(color: Color(0x1F161A1D), offset: Offset(1, 1), blurRadius: 2),
  ];

  /// Figma: New/Shadow/M
  static const m = [
    BoxShadow(color: Color(0x14161A1D), offset: Offset(2, 4), blurRadius: 10),
  ];

  /// Not in Figma: above the bottom bar (snackbar), deeper than [m].
  static const xl = [
    BoxShadow(color: Color(0x33161A1D), offset: Offset(0, 4), blurRadius: 12),
    BoxShadow(color: Color(0x40161A1D), offset: Offset(0, 12), blurRadius: 32),
  ];

  /// Figma: Light/shadow-lg (dropdowns, popovers)
  static const lg = [
    BoxShadow(color: Color(0x66000000), blurRadius: 1),
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ];

  /// Figma: Light/shadow-sm (switch knob, tooltips)
  static const sm = [
    BoxShadow(color: Color(0x66000000), blurRadius: 1),
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 6),
      blurRadius: 6,
      spreadRadius: -6,
    ),
  ];
}
