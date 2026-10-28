// Page indicator, from Figma component "Pages indicator" (node 13:10740,
// children "Page indicator" Active=Yes/No): 6px dots, 6px apart.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

class SossoldiPageIndicator extends StatelessWidget {
  const SossoldiPageIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;

  /// Active page (can be fractional while swiping; the nearest dot is lit).
  final double index;

  static const double _dot = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = index.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: _dot,
            height: _dot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active ? colors.shapeMed : colors.strokeDefault,
            ),
          ),
      ],
    );
  }
}
