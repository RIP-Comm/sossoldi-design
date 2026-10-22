import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'foundation_page.dart';

class PrimitiveColorsUseCase extends StatelessWidget {
  const PrimitiveColorsUseCase({super.key});

  static const _scales = <String, Map<int, Color>>{
    'Primary': {
      5: SossoldiPrimitives.primary5,
      10: SossoldiPrimitives.primary10,
      20: SossoldiPrimitives.primary20,
      30: SossoldiPrimitives.primary30,
      40: SossoldiPrimitives.primary40,
      50: SossoldiPrimitives.primary50,
      60: SossoldiPrimitives.primary60,
      70: SossoldiPrimitives.primary70,
      80: SossoldiPrimitives.primary80,
      90: SossoldiPrimitives.primary90,
      95: SossoldiPrimitives.primary95,
      99: SossoldiPrimitives.primary99,
    },
    'Grey': {
      5: SossoldiPrimitives.grey5,
      10: SossoldiPrimitives.grey10,
      20: SossoldiPrimitives.grey20,
      30: SossoldiPrimitives.grey30,
      40: SossoldiPrimitives.grey40,
      50: SossoldiPrimitives.grey50,
      60: SossoldiPrimitives.grey60,
      70: SossoldiPrimitives.grey70,
      80: SossoldiPrimitives.grey80,
      90: SossoldiPrimitives.grey90,
      93: SossoldiPrimitives.grey93,
      95: SossoldiPrimitives.grey95,
      97: SossoldiPrimitives.grey97,
      100: SossoldiPrimitives.grey100,
    },
    'Red': {
      5: SossoldiPrimitives.red5,
      10: SossoldiPrimitives.red10,
      20: SossoldiPrimitives.red20,
      30: SossoldiPrimitives.red30,
      40: SossoldiPrimitives.red40,
      50: SossoldiPrimitives.red50,
      60: SossoldiPrimitives.red60,
      70: SossoldiPrimitives.red70,
      80: SossoldiPrimitives.red80,
      90: SossoldiPrimitives.red90,
      95: SossoldiPrimitives.red95,
      99: SossoldiPrimitives.red99,
    },
    'Green': {
      5: SossoldiPrimitives.green5,
      10: SossoldiPrimitives.green10,
      20: SossoldiPrimitives.green20,
      30: SossoldiPrimitives.green30,
      40: SossoldiPrimitives.green40,
      50: SossoldiPrimitives.green50,
      60: SossoldiPrimitives.green60,
      70: SossoldiPrimitives.green70,
      80: SossoldiPrimitives.green80,
      90: SossoldiPrimitives.green90,
      95: SossoldiPrimitives.green95,
      99: SossoldiPrimitives.green99,
    },
    'Orange': {
      5: SossoldiPrimitives.orange5,
      10: SossoldiPrimitives.orange10,
      20: SossoldiPrimitives.orange20,
      30: SossoldiPrimitives.orange30,
      40: SossoldiPrimitives.orange40,
      50: SossoldiPrimitives.orange50,
      60: SossoldiPrimitives.orange60,
      70: SossoldiPrimitives.orange70,
      80: SossoldiPrimitives.orange80,
      90: SossoldiPrimitives.orange90,
      95: SossoldiPrimitives.orange95,
      99: SossoldiPrimitives.orange99,
    },
  };

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        for (final MapEntry(key: family, value: steps) in _scales.entries)
          FoundationSection(
            title: family,
            children: [
              for (final MapEntry(key: step, value: color) in steps.entries)
                ColorSwatchTile(name: '$family/$step', color: color),
            ],
          ),
      ],
    );
  }
}
