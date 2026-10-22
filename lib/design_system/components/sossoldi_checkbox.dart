// Checkbox, from Figma component "Checkbox" (node 3:4210).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

/// [value] true = checked, false = unchecked, null = mixed
/// (Figma types Fill, Stroke and Mixed).
class SossoldiCheckbox extends StatelessWidget {
  const SossoldiCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool? value;

  /// Called with the next value (mixed and unchecked become checked).
  /// Null disables the checkbox.
  final ValueChanged<bool>? onChanged;
  final String? label;

  static const double _box = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    final filled = value != false;
    final fill = enabled ? colors.primary.surface : colors.disabledSurface;

    final box = SizedBox.square(
      dimension: 24,
      child: Center(
        child: Container(
          width: _box,
          height: _box,
          decoration: BoxDecoration(
            color: filled ? fill : null,
            borderRadius: BorderRadius.circular(SossoldiRadius.xs),
            border: filled
                ? null
                : Border.all(
                    color: enabled ? colors.shapeMed : colors.disabledSurface,
                    width: 1.5,
                  ),
          ),
          child: filled
              ? Icon(
                  value == true
                      ? PhosphorIconsBold.check
                      : PhosphorIconsBold.minus,
                  size: 12,
                  color: colors.primary.onSurface,
                )
              : null,
        ),
      ),
    );

    return SossoldiTappable(
      onTap: enabled ? () => onChanged!(value != true) : null,
      semanticLabel: label,
      toggled: value ?? false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          box,
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
