// Label + field + supporting text layout shared by Text input and Select
// (Figma "Text + input" and "Supporting text").

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class SossoldiFieldFrame extends StatelessWidget {
  const SossoldiFieldFrame({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.isError = false,
  });

  final Widget child;
  final String? label;
  final String? helperText;
  final bool isError;

  /// Border color for a field container in the given state.
  static Color borderColor(
    BuildContext context, {
    required bool enabled,
    required bool focused,
    required bool hasValue,
    required bool isError,
  }) {
    final colors = context.colors;
    if (!enabled) return colors.strokeMinus1;
    if (isError) return colors.error.stroke;
    if (focused) return colors.primary.stroke;
    if (hasValue) return colors.strokePlus1;
    return colors.strokeDefault;
  }

  static BoxDecoration decoration(BuildContext context, Color border) {
    return BoxDecoration(
      color: context.colors.surfaceHigh,
      borderRadius: BorderRadius.circular(SossoldiRadius.s),
      border: Border.all(color: border),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xs,
      children: [
        if (label != null)
          Text(
            label!,
            style: typography.labelMedium.copyWith(color: colors.textHigh),
          ),
        child,
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.m),
            child: Text(
              helperText!,
              style: typography.bodySmall.copyWith(
                color: isError ? colors.error.text : colors.textMed,
              ),
            ),
          ),
      ],
    );
  }
}
