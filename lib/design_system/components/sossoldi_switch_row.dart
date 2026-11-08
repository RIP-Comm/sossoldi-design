// A white row with a label and a switch, as the two switches of the form of a
// budget (Figma 13:3507) and of an asset (13:3437): "Limit reach alert",
// "Counts for Net Worth".

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_switch.dart';

class SossoldiSwitchRow extends StatelessWidget {
  const SossoldiSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String label;
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// A line under the label (why the switch is disabled, for instance).
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.l,
        vertical: SossoldiSpacing.s,
      ),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
        ),
      ),
      child: Row(
        spacing: SossoldiSpacing.m,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.typography.labelLarge.copyWith(
                    color: colors.textHigh,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: context.typography.labelLarge.copyWith(
                      color: colors.textMed,
                    ),
                  ),
              ],
            ),
          ),
          SossoldiSwitch(
            value: value,
            onChanged: onChanged,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}
