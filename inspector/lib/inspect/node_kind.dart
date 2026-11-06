// The kinds of layer the Inspector tells apart, each with its icon: a design
// system component is purple, as in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

enum NodeKind {
  /// A component of the design system (`lib/design_system/components`).
  component,

  /// A screen, tab or card of the app (`lib/features`, `lib/app`).
  feature,
  text,
  icon,
  image,
  row,
  column,
  stack,
  scroll,
  textField,
  paint,
  box;

  IconData get glyph => switch (this) {
    component => PhosphorIconsRegular.diamondsFour,
    feature => PhosphorIconsRegular.frameCorners,
    text => PhosphorIconsRegular.textT,
    icon => PhosphorIconsRegular.shapes,
    image => PhosphorIconsRegular.image,
    row => PhosphorIconsRegular.columns,
    column => PhosphorIconsRegular.rows,
    stack => PhosphorIconsRegular.stack,
    scroll => PhosphorIconsRegular.arrowsDownUp,
    textField => PhosphorIconsRegular.textbox,
    paint => PhosphorIconsRegular.paintBrush,
    box => PhosphorIconsRegular.square,
  };

  String get label => switch (this) {
    component => 'Component',
    feature => 'Feature',
    text => 'Text',
    icon => 'Icon',
    image => 'Image',
    row => 'Row',
    column => 'Column',
    stack => 'Stack',
    scroll => 'Scroll view',
    textField => 'Text field',
    paint => 'Custom paint',
    box => 'Box',
  };

  /// A purple from the palette of the categories, like the component icon of
  /// Figma; the other kinds are neutral.
  static final Color componentColor = CategoryColors.all[30].main;

  Color color(SossoldiColors colors) =>
      this == component ? componentColor : colors.textMed;
}
