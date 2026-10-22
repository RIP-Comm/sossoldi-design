import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('light', SossoldiTheme.light),
    ('dark', SossoldiTheme.dark),
  ]) {
    group('$name theme', () {
      final colors = theme.extension<SossoldiColors>()!;

      test('exposes colors and typography extensions', () {
        expect(theme.extension<SossoldiColors>(), isNotNull);
        expect(theme.extension<SossoldiTypography>(), isNotNull);
      });

      test('high and med text are readable on every surface (WCAG AA)', () {
        for (final surface in [
          colors.surfaceLow,
          colors.surfaceMed,
          colors.surfaceHigh,
        ]) {
          expect(
            _contrast(colors.textHigh, surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(_contrast(colors.textMed, surface), greaterThanOrEqualTo(4.5));
        }
      });

      test('role text is readable on its own surface', () {
        for (final role in [
          colors.expense,
          colors.income,
          colors.warning,
          colors.error,
          colors.success,
          colors.info,
        ]) {
          expect(_contrast(role.text, role.surface), greaterThanOrEqualTo(4.5));
        }
      });
    });
  }

  test('typography line heights match Figma', () {
    final t = SossoldiTypography.standard;
    expect(t.headlineLarge.fontSize! * t.headlineLarge.height!, 40);
    expect(t.bodyXLarge.fontSize! * t.bodyXLarge.height!, 28);
    expect(t.labelXLarge.fontSize! * t.labelXLarge.height!, 24);
    expect(t.bodyBoldXLarge.fontSize! * t.bodyBoldXLarge.height!, 28);
    expect(t.labelBoldXLarge.fontSize! * t.labelBoldXLarge.height!, 24);
    expect(t.byName, hasLength(29));
  });

  test('there are 42 category color pairs', () {
    expect(CategoryColors.all, hasLength(42));
  });
}
