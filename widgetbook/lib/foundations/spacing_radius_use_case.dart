import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'foundation_page.dart';

class SpacingRadiusUseCase extends StatelessWidget {
  const SpacingRadiusUseCase({super.key});

  static const _spacing = {
    'XS': SossoldiSpacing.xs,
    'S': SossoldiSpacing.s,
    'M': SossoldiSpacing.m,
    'L': SossoldiSpacing.l,
    'XL': SossoldiSpacing.xl,
    '2XL': SossoldiSpacing.xxl,
    '3XL': SossoldiSpacing.xxxl,
  };

  static const _radius = {
    'ZERO': SossoldiRadius.zero,
    'XS': SossoldiRadius.xs,
    'S': SossoldiRadius.s,
    'M': SossoldiRadius.m,
    'L': SossoldiRadius.l,
    'MAX': SossoldiRadius.max,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = context.typography.labelSmall.copyWith(color: c.textMed);
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Spacing',
          children: [
            for (final MapEntry(key: name, value: v) in _spacing.entries)
              Column(
                children: [
                  Container(width: v, height: 40, color: c.primary.surface),
                  const SizedBox(height: SossoldiSpacing.xs),
                  Text('$name · ${v.toInt()}', style: label),
                ],
              ),
          ],
        ),
        FoundationSection(
          title: 'Radius',
          children: [
            for (final MapEntry(key: name, value: v) in _radius.entries)
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: c.surfaceHigh,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(v),
                        side: BorderSide(color: c.strokePlus1),
                      ),
                    ),
                  ),
                  const SizedBox(height: SossoldiSpacing.xs),
                  Text('$name · ${v.toInt()}', style: label),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
