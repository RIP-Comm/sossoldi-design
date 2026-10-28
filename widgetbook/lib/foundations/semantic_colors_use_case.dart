import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'foundation_page.dart';

class SemanticColorsUseCase extends StatelessWidget {
  const SemanticColorsUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    List<Widget> role(SossoldiColorRole r) => [
      ColorSwatchTile(name: 'text', color: r.text),
      ColorSwatchTile(name: 'on surface', color: r.onSurface),
      ColorSwatchTile(name: 'surface', color: r.surface),
      ColorSwatchTile(name: 'stroke', color: r.stroke),
    ];
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Surface',
          children: [
            ColorSwatchTile(name: 'low', color: c.surfaceLow),
            ColorSwatchTile(name: 'med', color: c.surfaceMed),
            ColorSwatchTile(name: 'high', color: c.surfaceHigh),
            ColorSwatchTile(name: 'selected', color: c.selectedSurface),
            ColorSwatchTile(
              name: 'selected primary',
              color: c.selectedPrimarySurface,
            ),
          ],
        ),
        FoundationSection(
          title: 'Text',
          children: [
            ColorSwatchTile(name: 'high', color: c.textHigh),
            ColorSwatchTile(name: 'med', color: c.textMed),
            ColorSwatchTile(name: 'low', color: c.textLow),
          ],
        ),
        FoundationSection(
          title: 'Shape',
          children: [
            ColorSwatchTile(name: 'high', color: c.shapeHigh),
            ColorSwatchTile(name: 'med', color: c.shapeMed),
            ColorSwatchTile(name: 'low', color: c.shapeLow),
          ],
        ),
        FoundationSection(
          title: 'Stroke',
          children: [
            ColorSwatchTile(name: '-1', color: c.strokeMinus1),
            ColorSwatchTile(name: 'default', color: c.strokeDefault),
            ColorSwatchTile(name: '+1', color: c.strokePlus1),
          ],
        ),
        FoundationSection(title: 'Primary', children: role(c.primary)),
        FoundationSection(title: 'Expense', children: role(c.expense)),
        FoundationSection(title: 'Income', children: role(c.income)),
        FoundationSection(title: 'Warning', children: role(c.warning)),
        FoundationSection(title: 'Error', children: role(c.error)),
        FoundationSection(title: 'Success', children: role(c.success)),
        FoundationSection(title: 'Info', children: role(c.info)),
        FoundationSection(
          title: 'Disabled',
          children: [
            ColorSwatchTile(name: 'surface', color: c.disabledSurface),
            ColorSwatchTile(name: 'on surface', color: c.disabledOnSurface),
          ],
        ),
      ],
    );
  }
}
