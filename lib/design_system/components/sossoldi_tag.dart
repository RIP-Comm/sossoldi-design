// Tag, from Figma component "Tag" (node 3:3947).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.
// Figma note: labels are not uppercase.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// [info] (blue) is not in Figma: added to name a variable or a reference
/// (the Inspector's design tokens).
enum SossoldiTagType { standard, positive, negative, info }

class SossoldiTag extends StatelessWidget {
  const SossoldiTag({
    super.key,
    required this.label,
    this.type = SossoldiTagType.standard,
    this.hasStroke = false,
    this.iconLeft,
    this.iconRight,
  });

  final String label;
  final SossoldiTagType type;
  final bool hasStroke;
  final IconData? iconLeft;
  final IconData? iconRight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color background, Color foreground, Color stroke) = switch (type) {
      SossoldiTagType.standard => (
        colors.surfaceHigh,
        colors.textMed,
        colors.strokeDefault,
      ),
      SossoldiTagType.positive => (
        colors.income.surface,
        colors.income.onSurface,
        colors.income.stroke,
      ),
      SossoldiTagType.negative => (
        colors.expense.surface,
        colors.expense.onSurface,
        colors.expense.stroke,
      ),
      SossoldiTagType.info => (
        colors.info.surface,
        colors.info.onSurface,
        colors.info.stroke,
      ),
    };

    Widget icon(IconData data) => Icon(data, size: 12, color: foreground);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.xs,
        vertical: SossoldiSpacing.xs / 2,
      ),
      decoration: ShapeDecoration(
        color: background,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.xs),
          side: hasStroke
              ? BorderSide(color: stroke, width: 0.5)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          if (iconLeft != null) icon(iconLeft!),
          Flexible(
            child: Text(
              label,
              style: context.typography.labelSmall.copyWith(color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (iconRight != null) icon(iconRight!),
        ],
      ),
    );
  }
}
