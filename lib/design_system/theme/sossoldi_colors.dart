// Semantic colors, from the Figma export Semantic.tokens.json.
// Light is the source of truth for names. Dark values marked "derived" were
// missing in Figma and follow the same logic as the light scale, mirrored.

import 'package:flutter/material.dart';

import '../tokens/primitive_colors.dart';

/// A role color group: text on neutral surfaces, a tinted surface,
/// the content placed on that surface, and the matching stroke.
@immutable
class SossoldiColorRole {
  const SossoldiColorRole({
    required this.text,
    required this.onSurface,
    required this.surface,
    required this.stroke,
  });

  final Color text;
  final Color onSurface;
  final Color surface;
  final Color stroke;

  static SossoldiColorRole lerp(
    SossoldiColorRole a,
    SossoldiColorRole b,
    double t,
  ) {
    return SossoldiColorRole(
      text: Color.lerp(a.text, b.text, t)!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      stroke: Color.lerp(a.stroke, b.stroke, t)!,
    );
  }
}

@immutable
class SossoldiColors extends ThemeExtension<SossoldiColors> {
  const SossoldiColors({
    required this.surfaceLow,
    required this.surfaceMed,
    required this.surfaceHigh,
    required this.textHigh,
    required this.textMed,
    required this.textLow,
    required this.shapeHigh,
    required this.shapeMed,
    required this.shapeLow,
    required this.strokeMinus1,
    required this.strokeDefault,
    required this.strokePlus1,
    required this.primary,
    required this.expense,
    required this.income,
    required this.warning,
    required this.error,
    required this.success,
    required this.info,
    required this.disabledSurface,
    required this.disabledOnSurface,
  });

  final Color surfaceLow;
  final Color surfaceMed;
  final Color surfaceHigh;

  final Color textHigh;
  final Color textMed;
  final Color textLow;

  final Color shapeHigh;
  final Color shapeMed;
  final Color shapeLow;

  /// Figma: Stroke/-1
  final Color strokeMinus1;

  /// Figma: Stroke/default
  final Color strokeDefault;

  /// Figma: Stroke/+1
  final Color strokePlus1;

  /// Figma: Primary (light) / Action (dark).
  final SossoldiColorRole primary;
  final SossoldiColorRole expense;
  final SossoldiColorRole income;

  /// Figma: Semantic/Warning
  final SossoldiColorRole warning;

  /// Figma: Semantic/Error
  final SossoldiColorRole error;

  /// Figma: Semantic/Success
  final SossoldiColorRole success;

  /// Figma: Semantic/info
  final SossoldiColorRole info;

  final Color disabledSurface;
  final Color disabledOnSurface;

  static const light = SossoldiColors(
    surfaceLow: SossoldiPrimitives.grey90,
    surfaceMed: SossoldiPrimitives.grey97,
    surfaceHigh: SossoldiPrimitives.grey100,
    textHigh: SossoldiPrimitives.grey10,
    textMed: SossoldiPrimitives.grey40,
    textLow: SossoldiPrimitives.grey60,
    shapeHigh: SossoldiPrimitives.grey20,
    shapeMed: SossoldiPrimitives.grey50,
    shapeLow: SossoldiPrimitives.grey70,
    strokeMinus1: SossoldiPrimitives.grey90,
    strokeDefault: SossoldiPrimitives.grey80,
    strokePlus1: SossoldiPrimitives.grey70,
    primary: SossoldiColorRole(
      text: SossoldiPrimitives.primary40,
      onSurface: SossoldiPrimitives.primary99,
      surface: SossoldiPrimitives.primary40,
      stroke: SossoldiPrimitives.primary40,
    ),
    expense: SossoldiColorRole(
      text: SossoldiPrimitives.red40,
      onSurface: SossoldiPrimitives.red40,
      surface: SossoldiPrimitives.red95,
      stroke: SossoldiPrimitives.red40,
    ),
    income: SossoldiColorRole(
      text: SossoldiPrimitives.green30,
      onSurface: SossoldiPrimitives.green30,
      surface: SossoldiPrimitives.green95,
      stroke: SossoldiPrimitives.green30,
    ),
    warning: SossoldiColorRole(
      text: SossoldiPrimitives.orange30,
      onSurface: SossoldiPrimitives.orange40,
      surface: SossoldiPrimitives.orange95,
      stroke: SossoldiPrimitives.orange40,
    ),
    error: SossoldiColorRole(
      text: SossoldiPrimitives.red30,
      onSurface: SossoldiPrimitives.red40,
      surface: SossoldiPrimitives.red95,
      stroke: SossoldiPrimitives.red40,
    ),
    success: SossoldiColorRole(
      text: SossoldiPrimitives.green20,
      onSurface: SossoldiPrimitives.green30,
      surface: SossoldiPrimitives.green95,
      stroke: SossoldiPrimitives.green30,
    ),
    info: SossoldiColorRole(
      text: SossoldiPrimitives.primary30,
      onSurface: SossoldiPrimitives.primary40,
      surface: SossoldiPrimitives.primary95,
      stroke: SossoldiPrimitives.primary40,
    ),
    disabledSurface: SossoldiPrimitives.grey80,
    disabledOnSurface: SossoldiPrimitives.grey95,
  );

  static const dark = SossoldiColors(
    surfaceLow: SossoldiPrimitives.grey5,
    surfaceMed: SossoldiPrimitives.grey10,
    surfaceHigh: SossoldiPrimitives.grey20, // derived
    textHigh: SossoldiPrimitives.grey95,
    textMed: SossoldiPrimitives.grey70,
    textLow: SossoldiPrimitives.grey50,
    shapeHigh: SossoldiPrimitives.grey90,
    shapeMed: SossoldiPrimitives.grey60,
    shapeLow: SossoldiPrimitives.grey40,
    strokeMinus1: SossoldiPrimitives.grey10,
    strokeDefault: SossoldiPrimitives.grey20,
    strokePlus1: SossoldiPrimitives.grey30,
    primary: SossoldiColorRole(
      text: SossoldiPrimitives.primary60,
      onSurface: SossoldiPrimitives.primary10,
      surface: SossoldiPrimitives.primary60,
      stroke: SossoldiPrimitives.primary60, // derived
    ),
    expense: SossoldiColorRole(
      text: SossoldiPrimitives.red70,
      onSurface: SossoldiPrimitives.red60,
      surface: SossoldiPrimitives.red10,
      stroke: SossoldiPrimitives.red60, // derived
    ),
    income: SossoldiColorRole(
      text: SossoldiPrimitives.green50,
      onSurface: SossoldiPrimitives.green50,
      surface: SossoldiPrimitives.green10,
      stroke: SossoldiPrimitives.green50, // derived
    ),
    warning: SossoldiColorRole(
      text: SossoldiPrimitives.orange50,
      onSurface: SossoldiPrimitives.orange50,
      surface: SossoldiPrimitives.orange10,
      stroke: SossoldiPrimitives.orange50, // derived
    ),
    // derived
    error: SossoldiColorRole(
      text: SossoldiPrimitives.red70,
      onSurface: SossoldiPrimitives.red60,
      surface: SossoldiPrimitives.red10,
      stroke: SossoldiPrimitives.red60,
    ),
    // derived
    success: SossoldiColorRole(
      text: SossoldiPrimitives.green60,
      onSurface: SossoldiPrimitives.green50,
      surface: SossoldiPrimitives.green10,
      stroke: SossoldiPrimitives.green50,
    ),
    // derived
    info: SossoldiColorRole(
      text: SossoldiPrimitives.primary70,
      onSurface: SossoldiPrimitives.primary60,
      surface: SossoldiPrimitives.primary10,
      stroke: SossoldiPrimitives.primary60,
    ),
    disabledSurface: SossoldiPrimitives.grey30, // derived
    disabledOnSurface: SossoldiPrimitives.grey50, // derived
  );

  @override
  SossoldiColors copyWith({
    Color? surfaceLow,
    Color? surfaceMed,
    Color? surfaceHigh,
    Color? textHigh,
    Color? textMed,
    Color? textLow,
    Color? shapeHigh,
    Color? shapeMed,
    Color? shapeLow,
    Color? strokeMinus1,
    Color? strokeDefault,
    Color? strokePlus1,
    SossoldiColorRole? primary,
    SossoldiColorRole? expense,
    SossoldiColorRole? income,
    SossoldiColorRole? warning,
    SossoldiColorRole? error,
    SossoldiColorRole? success,
    SossoldiColorRole? info,
    Color? disabledSurface,
    Color? disabledOnSurface,
  }) {
    return SossoldiColors(
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceMed: surfaceMed ?? this.surfaceMed,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      textHigh: textHigh ?? this.textHigh,
      textMed: textMed ?? this.textMed,
      textLow: textLow ?? this.textLow,
      shapeHigh: shapeHigh ?? this.shapeHigh,
      shapeMed: shapeMed ?? this.shapeMed,
      shapeLow: shapeLow ?? this.shapeLow,
      strokeMinus1: strokeMinus1 ?? this.strokeMinus1,
      strokeDefault: strokeDefault ?? this.strokeDefault,
      strokePlus1: strokePlus1 ?? this.strokePlus1,
      primary: primary ?? this.primary,
      expense: expense ?? this.expense,
      income: income ?? this.income,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      info: info ?? this.info,
      disabledSurface: disabledSurface ?? this.disabledSurface,
      disabledOnSurface: disabledOnSurface ?? this.disabledOnSurface,
    );
  }

  @override
  SossoldiColors lerp(SossoldiColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    SossoldiColorRole r(SossoldiColorRole a, SossoldiColorRole b) =>
        SossoldiColorRole.lerp(a, b, t);
    return SossoldiColors(
      surfaceLow: c(surfaceLow, other.surfaceLow),
      surfaceMed: c(surfaceMed, other.surfaceMed),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      textHigh: c(textHigh, other.textHigh),
      textMed: c(textMed, other.textMed),
      textLow: c(textLow, other.textLow),
      shapeHigh: c(shapeHigh, other.shapeHigh),
      shapeMed: c(shapeMed, other.shapeMed),
      shapeLow: c(shapeLow, other.shapeLow),
      strokeMinus1: c(strokeMinus1, other.strokeMinus1),
      strokeDefault: c(strokeDefault, other.strokeDefault),
      strokePlus1: c(strokePlus1, other.strokePlus1),
      primary: r(primary, other.primary),
      expense: r(expense, other.expense),
      income: r(income, other.income),
      warning: r(warning, other.warning),
      error: r(error, other.error),
      success: r(success, other.success),
      info: r(info, other.info),
      disabledSurface: c(disabledSurface, other.disabledSurface),
      disabledOnSurface: c(disabledOnSurface, other.disabledOnSurface),
    );
  }
}
