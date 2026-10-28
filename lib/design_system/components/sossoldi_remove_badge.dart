// Remove badge shown on a widget in edit mode, from Figma (node 13:3924):
// a small white round "-" button with the S shadow, top-left of the widget.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/shadows.dart';
import 'sossoldi_tappable.dart';

class SossoldiRemoveBadge extends StatelessWidget {
  const SossoldiRemoveBadge({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;

  /// Visible diameter (4px padding around a 20px icon slot).
  static const double size = 28;

  /// Extra touch area around the visible circle.
  static const double slop = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SossoldiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.all(slop),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.surfaceHigh,
            shape: BoxShape.circle,
            boxShadow: SossoldiShadows.s,
          ),
          child: Icon(
            PhosphorIconsRegular.minus,
            size: 16,
            color: colors.textHigh,
          ),
        ),
      ),
    );
  }
}
