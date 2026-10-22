// Button, from Figma component "Button" (node 3:4225).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

enum SossoldiButtonSize { small, large }

enum SossoldiButtonType { fill, outline, ghost }

class SossoldiButton extends StatelessWidget {
  const SossoldiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = SossoldiButtonSize.small,
    this.type = SossoldiButtonType.fill,
    this.iconLeft,
    this.iconRight,
    this.expanded = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final SossoldiButtonSize size;
  final SossoldiButtonType type;
  final IconData? iconLeft;
  final IconData? iconRight;

  /// Stretches to the available width.
  final bool expanded;

  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final enabled = onPressed != null;
    final isLarge = size == SossoldiButtonSize.large;

    // Disabled look is not in Figma: it reuses the Disabled tokens.
    final Color? background;
    final Color foreground;
    final Color? border;
    switch (type) {
      case SossoldiButtonType.fill:
        background = enabled ? colors.primary.surface : colors.disabledSurface;
        foreground = enabled
            ? colors.primary.onSurface
            : colors.disabledOnSurface;
        border = null;
      case SossoldiButtonType.outline:
        background = colors.surfaceHigh;
        foreground = enabled ? colors.primary.text : colors.textLow;
        border = enabled ? colors.primary.stroke : colors.strokeDefault;
      case SossoldiButtonType.ghost:
        background = null;
        foreground = enabled ? colors.primary.text : colors.textLow;
        border = null;
    }

    final EdgeInsets padding;
    final double radius;
    final TextStyle textStyle;
    if (type == SossoldiButtonType.ghost) {
      padding = EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.s,
        vertical: SossoldiSpacing.xs,
      );
      radius = SossoldiRadius.s;
      textStyle = isLarge
          ? typography.labelBoldLarge
          : typography.labelBoldMedium;
    } else {
      padding = isLarge
          ? const EdgeInsets.symmetric(
              horizontal: SossoldiSpacing.l,
              vertical: SossoldiSpacing.m,
            )
          : const EdgeInsets.symmetric(
              horizontal: SossoldiSpacing.m,
              // Figma: 6, between the XS and S steps.
              vertical: (SossoldiSpacing.xs + SossoldiSpacing.s) / 2,
            );
      radius = isLarge ? SossoldiRadius.m : SossoldiRadius.s;
      textStyle = typography.labelBoldLarge;
    }

    Widget icon(IconData data) =>
        Icon(data, size: _iconSize, color: foreground);

    return SossoldiTappable(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: SossoldiSpacing.xs,
          children: [
            if (iconLeft != null) icon(iconLeft!),
            Flexible(
              child: Text(
                label,
                style: textStyle.copyWith(color: foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (iconRight != null) icon(iconRight!),
          ],
        ),
      ),
    );
  }
}
