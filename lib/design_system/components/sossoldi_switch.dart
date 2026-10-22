// Switch, from Figma component "Switch" (node 3:3915).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiSwitch extends StatelessWidget {
  const SossoldiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  /// Figma disables the switch with a 60% light overlay.
  static const double _disabledOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;

    return SossoldiTappable(
      onTap: enabled ? () => onChanged!(!value) : null,
      semanticLabel: semanticLabel,
      toggled: value,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 28,
          padding: const EdgeInsets.all(SossoldiSpacing.xs),
          decoration: BoxDecoration(
            color: value ? colors.primary.surface : colors.surfaceLow,
            borderRadius: BorderRadius.circular(SossoldiRadius.max),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.surfaceHigh,
                shape: BoxShape.circle,
                boxShadow: SossoldiShadows.sm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
