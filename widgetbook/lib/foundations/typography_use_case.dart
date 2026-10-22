import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'foundation_page.dart';

class TypographyUseCase extends StatelessWidget {
  const TypographyUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final styles = context.typography.byName;
    return FoundationPage(
      children: [
        for (final MapEntry(key: name, value: style) in styles.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: SossoldiSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    name.contains('Uppercase') ? name.toUpperCase() : name,
                    style: style.copyWith(color: context.colors.textHigh),
                  ),
                ),
                Text(
                  '${style.fontSize!.toInt()} / '
                  '${(style.fontSize! * style.height!).round()} · '
                  'w${style.fontWeight!.value}',
                  style: context.typography.captionSmall.copyWith(
                    color: context.colors.textMed,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
