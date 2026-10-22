// Icon button, from Figma component "Icon button" (node 3:4495).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import 'sossoldi_tappable.dart';

/// XS: 20px, Small: 28px, Large: 40px.
enum SossoldiIconButtonSize { xs, small, large }

enum SossoldiIconButtonType { fill, outline, ghost }

/// Primary: brand blue. Neutral: grey content (Large ghost has a
/// surface-low background). White: elevated white button with shadow.
enum SossoldiIconButtonVariant { primary, neutral, white }

class SossoldiIconButton extends StatelessWidget {
  const SossoldiIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = SossoldiIconButtonSize.small,
    this.type = SossoldiIconButtonType.ghost,
    this.variant = SossoldiIconButtonVariant.primary,
  });

  final IconData icon;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Read by screen readers, since there is no visible label.
  final String semanticLabel;
  final SossoldiIconButtonSize size;
  final SossoldiIconButtonType type;
  final SossoldiIconButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;

    final (double box, double iconSize) = switch (size) {
      SossoldiIconButtonSize.xs => (20, 16),
      SossoldiIconButtonSize.small => (28, 20),
      SossoldiIconButtonSize.large => (40, 24),
    };

    Color? background;
    Color? border;
    List<BoxShadow>? shadow;
    Color foreground;
    switch ((type, variant)) {
      case (SossoldiIconButtonType.fill, SossoldiIconButtonVariant.white):
        background = colors.surfaceHigh;
        shadow = SossoldiShadows.s;
        foreground = colors.textHigh;
      case (SossoldiIconButtonType.fill, _):
        background = colors.primary.surface;
        foreground = colors.primary.onSurface;
      case (SossoldiIconButtonType.outline, _):
        border = colors.primary.stroke;
        foreground = colors.primary.text;
      case (SossoldiIconButtonType.ghost, SossoldiIconButtonVariant.neutral):
        if (size == SossoldiIconButtonSize.large) {
          background = colors.surfaceLow;
        }
        foreground = colors.textHigh;
      case (SossoldiIconButtonType.ghost, _):
        foreground = colors.primary.text;
    }

    if (!enabled) {
      shadow = null;
      border = border == null ? null : colors.strokeDefault;
      if (background != null) {
        background = colors.disabledSurface;
        foreground = colors.disabledOnSurface;
      } else {
        foreground = colors.disabledSurface;
      }
    }

    return SossoldiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        width: box,
        height: box,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(SossoldiRadius.max),
          border: border == null ? null : Border.all(color: border),
          boxShadow: shadow,
        ),
        child: Icon(icon, size: iconSize, color: foreground),
      ),
    );
  }
}
