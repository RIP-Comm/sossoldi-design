// Text styles, from the Figma typography frame (node 7:6469).
//
// Styles carry no color: widgets apply a SossoldiColors value.
// "Uppercase" styles don't transform text by themselves: Flutter has no
// text-transform, so components uppercase the string with toUpperCase().

import 'package:flutter/material.dart';

import '../tokens/font_tokens.dart';

TextStyle _style(FontWeight weight, double size, double lineHeight) {
  return TextStyle(
    fontFamily: SossoldiFont.family,
    fontWeight: weight,
    fontSize: size,
    height: lineHeight / size,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0,
  );
}

@immutable
class SossoldiTypography extends ThemeExtension<SossoldiTypography> {
  const SossoldiTypography({
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyXLarge,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.bodyBoldXLarge,
    required this.bodyBoldLarge,
    required this.bodyBoldMedium,
    required this.bodyBoldSmall,
    required this.labelXLarge,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.labelBoldXLarge,
    required this.labelBoldLarge,
    required this.labelBoldMedium,
    required this.labelBoldSmall,
    required this.labelUppercaseLarge,
    required this.labelUppercaseMedium,
    required this.labelUppercaseSmall,
    required this.labelUppercaseBoldLarge,
    required this.labelUppercaseBoldMedium,
    required this.labelUppercaseBoldSmall,
    required this.captionSmall,
  });

  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyXLarge;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle bodyBoldXLarge;
  final TextStyle bodyBoldLarge;
  final TextStyle bodyBoldMedium;
  final TextStyle bodyBoldSmall;
  final TextStyle labelXLarge;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle labelBoldXLarge;
  final TextStyle labelBoldLarge;
  final TextStyle labelBoldMedium;
  final TextStyle labelBoldSmall;
  final TextStyle labelUppercaseLarge;
  final TextStyle labelUppercaseMedium;
  final TextStyle labelUppercaseSmall;
  final TextStyle labelUppercaseBoldLarge;
  final TextStyle labelUppercaseBoldMedium;
  final TextStyle labelUppercaseBoldSmall;
  final TextStyle captionSmall;

  static final standard = SossoldiTypography(
    headlineLarge: _style(
      SossoldiFont.bold,
      SossoldiFontSize.xxxl,
      SossoldiLineHeight.xxxl,
    ),
    headlineMedium: _style(
      SossoldiFont.bold,
      SossoldiFontSize.xxl,
      SossoldiLineHeight.xxl,
    ),
    headlineSmall: _style(
      SossoldiFont.bold,
      SossoldiFontSize.xl,
      SossoldiLineHeight.xl,
    ),
    titleLarge: _style(
      SossoldiFont.bold,
      SossoldiFontSize.l,
      SossoldiLineHeight.l,
    ),
    titleMedium: _style(
      SossoldiFont.bold,
      SossoldiFontSize.m,
      SossoldiLineHeight.m,
    ),
    titleSmall: _style(
      SossoldiFont.bold,
      SossoldiFontSize.s,
      SossoldiLineHeight.s,
    ),
    bodyXLarge: _style(
      SossoldiFont.regular,
      SossoldiFontSize.l,
      SossoldiLineHeight.l,
    ),
    bodyLarge: _style(
      SossoldiFont.regular,
      SossoldiFontSize.m,
      SossoldiLineHeight.m,
    ),
    bodyMedium: _style(
      SossoldiFont.regular,
      SossoldiFontSize.s,
      SossoldiLineHeight.s,
    ),
    bodySmall: _style(
      SossoldiFont.regular,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    bodyBoldXLarge: _style(
      SossoldiFont.bold,
      SossoldiFontSize.l,
      SossoldiLineHeight.l,
    ),
    bodyBoldLarge: _style(
      SossoldiFont.bold,
      SossoldiFontSize.m,
      SossoldiLineHeight.m,
    ),
    bodyBoldMedium: _style(
      SossoldiFont.bold,
      SossoldiFontSize.s,
      SossoldiLineHeight.s,
    ),
    bodyBoldSmall: _style(
      SossoldiFont.bold,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    labelXLarge: _style(
      SossoldiFont.regular,
      SossoldiFontSize.l,
      SossoldiLineHeight.m,
    ),
    labelLarge: _style(
      SossoldiFont.regular,
      SossoldiFontSize.m,
      SossoldiLineHeight.s,
    ),
    labelMedium: _style(
      SossoldiFont.regular,
      SossoldiFontSize.s,
      SossoldiLineHeight.xs,
    ),
    labelSmall: _style(
      SossoldiFont.regular,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    labelBoldXLarge: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.l,
      SossoldiLineHeight.m,
    ),
    labelBoldLarge: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.m,
      SossoldiLineHeight.s,
    ),
    labelBoldMedium: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.s,
      SossoldiLineHeight.xs,
    ),
    labelBoldSmall: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    labelUppercaseLarge: _style(
      SossoldiFont.medium,
      SossoldiFontSize.s,
      SossoldiLineHeight.s,
    ),
    labelUppercaseMedium: _style(
      SossoldiFont.medium,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    labelUppercaseSmall: _style(
      SossoldiFont.medium,
      SossoldiFontSize.xxs,
      SossoldiLineHeight.xs,
    ),
    labelUppercaseBoldLarge: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.s,
      SossoldiLineHeight.s,
    ),
    labelUppercaseBoldMedium: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.xs,
      SossoldiLineHeight.xs,
    ),
    labelUppercaseBoldSmall: _style(
      SossoldiFont.semibold,
      SossoldiFontSize.xxs,
      SossoldiLineHeight.xs,
    ),
    captionSmall: _style(
      SossoldiFont.regular,
      SossoldiFontSize.xxs,
      SossoldiLineHeight.xxs,
    ),
  );

  /// All styles with their Figma names, for widgetbook and checks.
  Map<String, TextStyle> get byName => {
    'Headline/Large': headlineLarge,
    'Headline/Medium': headlineMedium,
    'Headline/Small': headlineSmall,
    'Title/Large': titleLarge,
    'Title/Medium': titleMedium,
    'Title/Small': titleSmall,
    'Body/X-Large': bodyXLarge,
    'Body/Large': bodyLarge,
    'Body/Medium': bodyMedium,
    'Body/Small': bodySmall,
    'Body/Bold/X-Large': bodyBoldXLarge,
    'Body/Bold/Large': bodyBoldLarge,
    'Body/Bold/Medium': bodyBoldMedium,
    'Body/Bold/Small': bodyBoldSmall,
    'Label/X-Large': labelXLarge,
    'Label/Large': labelLarge,
    'Label/Medium': labelMedium,
    'Label/Small': labelSmall,
    'Label/Bold/X-Large': labelBoldXLarge,
    'Label/Bold/Large': labelBoldLarge,
    'Label/Bold/Medium': labelBoldMedium,
    'Label/Bold/Small': labelBoldSmall,
    'Label/Uppercase/Large': labelUppercaseLarge,
    'Label/Uppercase/Medium': labelUppercaseMedium,
    'Label/Uppercase/Small': labelUppercaseSmall,
    'Label/Uppercase/Bold/Large': labelUppercaseBoldLarge,
    'Label/Uppercase/Bold/Medium': labelUppercaseBoldMedium,
    'Label/Uppercase/Bold/Small': labelUppercaseBoldSmall,
    'Caption/Small': captionSmall,
  };

  @override
  SossoldiTypography copyWith() => this;

  @override
  SossoldiTypography lerp(SossoldiTypography? other, double t) {
    // Text styles don't change between light and dark.
    return this;
  }
}
