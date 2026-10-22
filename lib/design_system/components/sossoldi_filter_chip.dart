// Filter chip, from Figma component "Chip-Filter" (node 3:4199).
// Shows an active filter as "Name: value" with an optional remove button.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_chip.dart';
import 'sossoldi_tappable.dart';

class SossoldiFilterChip extends StatelessWidget {
  const SossoldiFilterChip({
    super.key,
    required this.value,
    this.name,
    this.icon,
    this.onRemove,
    this.removeSemanticLabel,
  });

  /// Selected filter value (Figma: "Text").
  final String value;

  /// Filter name, shown before the value as "Name:".
  final String? name;
  final IconData? icon;

  /// Shows the remove (X) button when not null.
  final VoidCallback? onRemove;

  /// Screen reader label for the remove button, e.g. "Remove filter".
  final String? removeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.typography.labelMedium;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.s,
        vertical: SossoldiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiChip.radius),
        border: Border.all(color: colors.strokeMinus1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          if (icon != null) Icon(icon, size: 16, color: colors.textHigh),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  if (name != null) ...[
                    TextSpan(
                      text: name,
                      style: style.copyWith(color: colors.textHigh),
                    ),
                    TextSpan(
                      text: ': ',
                      style: style.copyWith(color: colors.textMed),
                    ),
                  ],
                  TextSpan(
                    text: value,
                    style: style.copyWith(color: colors.textMed),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRemove != null)
            SossoldiTappable(
              onTap: onRemove,
              semanticLabel: removeSemanticLabel,
              child: Icon(
                PhosphorIconsRegular.x,
                size: 16,
                color: colors.textMed,
              ),
            ),
        ],
      ),
    );
  }
}
