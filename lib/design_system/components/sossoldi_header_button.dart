// Header button, from Figma component "Header button" (node 13:3786), used in
// the top action bar of the main screens: a 54px white round button with
// an icon and the medium shadow.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/shadows.dart';
import 'sossoldi_tappable.dart';

class SossoldiHeaderButton extends StatelessWidget {
  const SossoldiHeaderButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.filled = false,
  });

  final IconData icon;

  /// Primary-colored variant (e.g. the "done" check in edit mode).
  final bool filled;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Read by screen readers, since there is no visible label.
  final String semanticLabel;

  static const double size = 54;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SossoldiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? colors.primary.surface : colors.surfaceHigh,
          shape: BoxShape.circle,
          boxShadow: SossoldiShadows.m,
        ),
        child: Icon(
          icon,
          size: 24,
          color: filled ? colors.primary.onSurface : colors.textHigh,
        ),
      ),
    );
  }
}
