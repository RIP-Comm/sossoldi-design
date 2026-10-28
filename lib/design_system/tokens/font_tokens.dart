// Font primitives, from the Figma export Font.tokens.json.
// Text styles are composed from these in theme/sossoldi_typography.dart.

import 'package:flutter/painting.dart';

abstract final class SossoldiFont {
  /// Bundled in assets/fonts/dm_sans (SIL Open Font License), declared in
  /// the app pubspec. The widgetbook app declares the same files from this
  /// package (packages/sossoldi/...), so the plain family name works in both.
  static const family = 'DMSans';

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
}

abstract final class SossoldiFontSize {
  static const double xxs = 11;
  static const double xs = 12;
  static const double s = 14;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double xxxl = 32;
}

abstract final class SossoldiLineHeight {
  static const double xxs = 12;
  static const double xs = 16;
  static const double s = 20;
  static const double m = 24;
  static const double l = 28;
  static const double xl = 32;
  static const double xxl = 36;
  static const double xxxl = 40;
}
