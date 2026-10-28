// Chip, from Figma component "Chip" (node 3:4134).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_colors.dart';
import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';

/// Figma "Alert" is [error].
enum SossoldiChipType {
  standard,
  subtle,
  info,
  warning,
  error,
  success,
  expense,
  income,
}

class SossoldiChip extends StatelessWidget {
  const SossoldiChip({
    super.key,
    required this.label,
    this.type = SossoldiChipType.standard,
    this.iconLeft,
    this.iconRight,
  });

  final String label;
  final SossoldiChipType type;
  final IconData? iconLeft;
  final IconData? iconRight;

  /// Figma uses 6, which is not on the radius scale.
  static const double radius = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color background, Color foreground, Color? border) = switch (type) {
      SossoldiChipType.standard => (
        colors.surfaceHigh,
        colors.textHigh,
        colors.strokeDefault,
      ),
      SossoldiChipType.subtle => (colors.surfaceMed, colors.textMed, null),
      SossoldiChipType.info => _role(colors.info),
      SossoldiChipType.warning => _role(colors.warning),
      SossoldiChipType.error => _role(colors.error),
      SossoldiChipType.success => _role(colors.success),
      SossoldiChipType.expense => _role(colors.expense),
      SossoldiChipType.income => _role(colors.income),
    };

    Widget icon(IconData data) => Icon(data, size: 16, color: foreground);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.xs,
        vertical: SossoldiSpacing.xs / 2,
      ),
      decoration: ShapeDecoration(
        color: background,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(radius),
          side: border == null ? BorderSide.none : BorderSide(color: border),
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
              style: context.typography.labelMedium.copyWith(color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (iconRight != null) icon(iconRight!),
        ],
      ),
    );
  }

  static (Color, Color, Color?) _role(SossoldiColorRole role) =>
      (role.surface, role.text, null);
}
