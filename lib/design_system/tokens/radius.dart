// Corner radius scale, from the Figma export Spacing.tokens.json (collection "Radius").

abstract final class SossoldiRadius {
  static const double zero = 0;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;

  /// Top corners of bottom sheets. Not a Figma variable: used only by the
  /// Bottom Sheet component.
  static const double sheet = 32;

  /// Fully rounded (pills, circles).
  static const double max = 100;
}
