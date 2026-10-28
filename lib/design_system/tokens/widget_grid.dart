// Dashboard widget grid metrics, from the Figma Dashboard (node 13:3841):
// 2 columns, 16 gap, widgets 170 high. S = 1x1, M = 2x1, L = 2x2.

import 'spacing.dart';

abstract final class SossoldiWidgetGrid {
  static const int columns = 2;

  /// Space between widgets, horizontally and vertically (Figma padding-grid).
  static const double gap = SossoldiSpacing.l;

  /// Height of a one-row widget (S and M).
  static const double rowHeight = 170;

  /// Height of a widget spanning [rows] rows, including the gaps between them.
  static double heightFor(int rows) => rowHeight * rows + gap * (rows - 1);
}
