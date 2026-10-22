// Textarea, from Figma component "Textarea" (node 3:3996).
// The resize handle in Figma is a desktop affordance: on mobile the field
// grows with its content between [minLines] and [maxLines] instead.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class SossoldiTextarea extends StatelessWidget {
  const SossoldiTextarea({
    super.key,
    this.controller,
    this.placeholder,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 8,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.typography.bodyXLarge;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMed,
        borderRadius: BorderRadius.circular(SossoldiRadius.s),
        border: Border.all(color: colors.strokeMinus1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          style: style.copyWith(
            color: enabled ? colors.textHigh : colors.textLow,
          ),
          cursorColor: colors.shapeHigh,
          cursorWidth: 1,
          decoration: InputDecoration.collapsed(
            hintText: placeholder,
            hintStyle: style.copyWith(
              color: enabled ? colors.textMed : colors.textLow,
            ),
          ),
        ),
      ),
    );
  }
}
