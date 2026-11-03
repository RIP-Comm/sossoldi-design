// Reverse lookup from a measured value to the design system token it comes
// from: what a developer needs to rebuild the screen with the same tokens.
// Keep in sync with lib/design_system/tokens and theme.

import 'package:flutter/painting.dart';
import 'package:sossoldi/design_system/design_system.dart';

/// Semantic colors of [colors] (light or dark) by name, then the primitives.
List<(String, Color)> colorTokens(SossoldiColors colors) {
  List<(String, Color)> role(String name, SossoldiColorRole r) => [
    ('$name.text', r.text),
    ('$name.onSurface', r.onSurface),
    ('$name.surface', r.surface),
    ('$name.stroke', r.stroke),
  ];
  return [
    ('surfaceLow', colors.surfaceLow),
    ('surfaceMed', colors.surfaceMed),
    ('surfaceHigh', colors.surfaceHigh),
    ('selectedSurface', colors.selectedSurface),
    ('selectedPrimarySurface', colors.selectedPrimarySurface),
    ('textHigh', colors.textHigh),
    ('textMed', colors.textMed),
    ('textLow', colors.textLow),
    ('shapeHigh', colors.shapeHigh),
    ('shapeMed', colors.shapeMed),
    ('shapeLow', colors.shapeLow),
    ('strokeMinus1', colors.strokeMinus1),
    ('strokeDefault', colors.strokeDefault),
    ('strokePlus1', colors.strokePlus1),
    ...role('primary', colors.primary),
    ...role('expense', colors.expense),
    ...role('income', colors.income),
    ...role('warning', colors.warning),
    ...role('error', colors.error),
    ...role('success', colors.success),
    ...role('info', colors.info),
    ('disabledSurface', colors.disabledSurface),
    ('disabledOnSurface', colors.disabledOnSurface),
  ];
}

const _primitives = <(String, Color)>[
  ('primary5', SossoldiPrimitives.primary5),
  ('primary10', SossoldiPrimitives.primary10),
  ('primary20', SossoldiPrimitives.primary20),
  ('primary30', SossoldiPrimitives.primary30),
  ('primary40', SossoldiPrimitives.primary40),
  ('primary50', SossoldiPrimitives.primary50),
  ('primary60', SossoldiPrimitives.primary60),
  ('primary70', SossoldiPrimitives.primary70),
  ('primary80', SossoldiPrimitives.primary80),
  ('primary90', SossoldiPrimitives.primary90),
  ('primary95', SossoldiPrimitives.primary95),
  ('primary97', SossoldiPrimitives.primary97),
  ('primary99', SossoldiPrimitives.primary99),
  ('grey5', SossoldiPrimitives.grey5),
  ('grey10', SossoldiPrimitives.grey10),
  ('grey20', SossoldiPrimitives.grey20),
  ('grey30', SossoldiPrimitives.grey30),
  ('grey40', SossoldiPrimitives.grey40),
  ('grey50', SossoldiPrimitives.grey50),
  ('grey60', SossoldiPrimitives.grey60),
  ('grey70', SossoldiPrimitives.grey70),
  ('grey80', SossoldiPrimitives.grey80),
  ('grey90', SossoldiPrimitives.grey90),
  ('grey93', SossoldiPrimitives.grey93),
  ('grey95', SossoldiPrimitives.grey95),
  ('grey97', SossoldiPrimitives.grey97),
  ('grey100', SossoldiPrimitives.grey100),
  ('red5', SossoldiPrimitives.red5),
  ('red10', SossoldiPrimitives.red10),
  ('red20', SossoldiPrimitives.red20),
  ('red30', SossoldiPrimitives.red30),
  ('red40', SossoldiPrimitives.red40),
  ('red50', SossoldiPrimitives.red50),
  ('red60', SossoldiPrimitives.red60),
  ('red70', SossoldiPrimitives.red70),
  ('red80', SossoldiPrimitives.red80),
  ('red90', SossoldiPrimitives.red90),
  ('red95', SossoldiPrimitives.red95),
  ('red99', SossoldiPrimitives.red99),
  ('green5', SossoldiPrimitives.green5),
  ('green10', SossoldiPrimitives.green10),
  ('green20', SossoldiPrimitives.green20),
  ('green30', SossoldiPrimitives.green30),
  ('green40', SossoldiPrimitives.green40),
  ('green50', SossoldiPrimitives.green50),
  ('green60', SossoldiPrimitives.green60),
  ('green70', SossoldiPrimitives.green70),
  ('green80', SossoldiPrimitives.green80),
  ('green90', SossoldiPrimitives.green90),
  ('green95', SossoldiPrimitives.green95),
  ('green99', SossoldiPrimitives.green99),
  ('orange5', SossoldiPrimitives.orange5),
  ('orange10', SossoldiPrimitives.orange10),
  ('orange20', SossoldiPrimitives.orange20),
  ('orange30', SossoldiPrimitives.orange30),
  ('orange40', SossoldiPrimitives.orange40),
  ('orange50', SossoldiPrimitives.orange50),
  ('orange60', SossoldiPrimitives.orange60),
  ('orange70', SossoldiPrimitives.orange70),
  ('orange80', SossoldiPrimitives.orange80),
  ('orange90', SossoldiPrimitives.orange90),
  ('orange95', SossoldiPrimitives.orange95),
  ('orange99', SossoldiPrimitives.orange99),
  ('mutedBlueText', SossoldiPrimitives.mutedBlueText),
  ('mutedBlue', SossoldiPrimitives.mutedBlue),
  ('mutedBlueSurface', SossoldiPrimitives.mutedBlueSurface),
  ('mutedGreenText', SossoldiPrimitives.mutedGreenText),
  ('mutedGreen', SossoldiPrimitives.mutedGreen),
  ('mutedGreenSurface', SossoldiPrimitives.mutedGreenSurface),
  ('mutedOrangeText', SossoldiPrimitives.mutedOrangeText),
  ('mutedOrange', SossoldiPrimitives.mutedOrange),
  ('mutedOrangeSurface', SossoldiPrimitives.mutedOrangeSurface),
  ('mutedRedText', SossoldiPrimitives.mutedRedText),
  ('mutedRedSurface', SossoldiPrimitives.mutedRedSurface),
  ('mutedRed', SossoldiPrimitives.mutedRed),
];

/// A color described by its tokens: the semantic ones first (all of them,
/// since several roles can share a value), then the primitive.
class ColorInfo {
  const ColorInfo(this.color, this.semantic, this.primitive);

  final Color color;
  final List<String> semantic;
  final String? primitive;

  /// "#RRGGBB", with the alpha in front when not opaque ("#80RRGGBB").
  String get hex {
    String two(double v) =>
        (v * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final rgb = '${two(color.r)}${two(color.g)}${two(color.b)}';
    return color.a < 1 ? '#${two(color.a)}$rgb' : '#$rgb';
  }

  /// Opacity in percent, or null when opaque.
  int? get opacityPercent => color.a < 1 ? (color.a * 100).round() : null;
}

ColorInfo describeColor(Color color, SossoldiColors colors) {
  final argb = color.toARGB32();
  // A translucent color is often an opaque token with an opacity.
  final opaque = color.withValues(alpha: 1).toARGB32();
  final semantic = [
    for (final (name, c) in colorTokens(colors))
      if (c.toARGB32() == argb) name,
  ];
  if (semantic.isEmpty && argb != opaque) {
    for (final (name, c) in colorTokens(colors)) {
      if (c.toARGB32() == opaque) semantic.add(name);
    }
  }
  String? primitive;
  for (final (name, c) in _primitives) {
    if (c.toARGB32() == argb || c.toARGB32() == opaque) {
      primitive = name;
      break;
    }
  }
  return ColorInfo(color, semantic, primitive);
}

/// The text style token with the same font size, weight and line height.
String? typographyToken(TextStyle style, SossoldiTypography t) {
  final styles = <String, TextStyle>{
    'headlineLarge': t.headlineLarge,
    'headlineMedium': t.headlineMedium,
    'headlineSmall': t.headlineSmall,
    'titleLarge': t.titleLarge,
    'titleMedium': t.titleMedium,
    'titleSmall': t.titleSmall,
    'bodyXLarge': t.bodyXLarge,
    'bodyLarge': t.bodyLarge,
    'bodyMedium': t.bodyMedium,
    'bodySmall': t.bodySmall,
    'bodyBoldXLarge': t.bodyBoldXLarge,
    'bodyBoldLarge': t.bodyBoldLarge,
    'bodyBoldMedium': t.bodyBoldMedium,
    'bodyBoldSmall': t.bodyBoldSmall,
    'labelXLarge': t.labelXLarge,
    'labelLarge': t.labelLarge,
    'labelMedium': t.labelMedium,
    'labelSmall': t.labelSmall,
    'labelBoldXLarge': t.labelBoldXLarge,
    'labelBoldLarge': t.labelBoldLarge,
    'labelBoldMedium': t.labelBoldMedium,
    'labelBoldSmall': t.labelBoldSmall,
    'labelUppercaseLarge': t.labelUppercaseLarge,
    'labelUppercaseMedium': t.labelUppercaseMedium,
    'labelUppercaseSmall': t.labelUppercaseSmall,
    'labelUppercaseBoldLarge': t.labelUppercaseBoldLarge,
    'labelUppercaseBoldMedium': t.labelUppercaseBoldMedium,
    'labelUppercaseBoldSmall': t.labelUppercaseBoldSmall,
    'captionSmall': t.captionSmall,
  };
  final matches = [
    for (final MapEntry(:key, :value) in styles.entries)
      if (value.fontSize == style.fontSize &&
          value.fontWeight == style.fontWeight &&
          _close(value.height, style.height) &&
          (value.letterSpacing ?? 0) == (style.letterSpacing ?? 0))
        key,
  ];
  // Several tokens share the same metrics (label vs body): list them all.
  return matches.isEmpty ? null : matches.join(' / ');
}

bool _close(double? a, double? b) =>
    a == null || b == null ? a == b : (a - b).abs() < 0.001;

String? spacingToken(double value) => switch (value) {
  SossoldiSpacing.xs => 'xs',
  SossoldiSpacing.s => 's',
  SossoldiSpacing.m => 'm',
  SossoldiSpacing.l => 'l',
  SossoldiSpacing.xl => 'xl',
  SossoldiSpacing.xxl => 'xxl',
  SossoldiSpacing.xxxl => 'xxxl',
  _ => null,
};

String? radiusToken(double value) => switch (value) {
  SossoldiRadius.xs => 'xs',
  SossoldiRadius.s => 's',
  SossoldiRadius.m => 'm',
  SossoldiRadius.l => 'l',
  SossoldiRadius.sheet => 'sheet',
  SossoldiRadius.max => 'max',
  _ => null,
};

/// "16" or "16.5": logical pixels without a needless ".0".
String px(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.toInt().toString() : r.toStringAsFixed(1);
}
