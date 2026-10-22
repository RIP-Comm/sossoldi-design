// Radio button, from Figma component "Radio button" (node 3:3801).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiRadio<T> extends StatelessWidget {
  const SossoldiRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  final T value;
  final T? groupValue;

  /// Null disables the radio.
  final ValueChanged<T>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    final selected = value == groupValue;
    final color = enabled ? colors.primary.surface : colors.disabledSurface;

    final circle = SizedBox.square(
      dimension: 24,
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: selected
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(SossoldiRadius.max),
                  ),
                )
              : null,
        ),
      ),
    );

    return SossoldiTappable(
      onTap: enabled ? () => onChanged!(value) : null,
      semanticLabel: label,
      selected: selected,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.s,
        children: [
          circle,
          if (label != null)
            Flexible(
              child: Text(
                label!,
                style: context.typography.bodyMedium.copyWith(
                  color: enabled ? colors.textHigh : colors.textLow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
