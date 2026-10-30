// Unit navigator, from Figma component "Unit navigator" (node 3:5716).
// A selectable pill with icon and label (e.g. a period or unit choice).

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiUnitNavigator extends StatelessWidget {
  const SossoldiUnitNavigator({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Keeps the icon in its own color, selected or not (a category chip).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.primary.text : colors.textMed;
    return SossoldiTappable(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.s),
        decoration: ShapeDecoration(
          color: colors.surfaceHigh,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(SossoldiRadius.s),
            side: BorderSide(
              color: selected ? colors.primary.stroke : colors.strokePlus1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SossoldiSpacing.xs,
          children: [
            if (icon != null)
              Icon(icon, size: 16, color: iconColor ?? foreground),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.labelLarge.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
