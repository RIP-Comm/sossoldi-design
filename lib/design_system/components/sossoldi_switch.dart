// Switch, from Figma component "Switch" (node 3:3915).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

/// [small] is not in Figma: a 40 × 22 switch for dense toolbars (the
/// Inspector's light/dark switch).
enum SossoldiSwitchSize { regular, small }

class SossoldiSwitch extends StatelessWidget {
  const SossoldiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.size = SossoldiSwitchSize.regular,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final SossoldiSwitchSize size;

  /// Figma disables the switch with a 60% light overlay.
  static const double _disabledOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    // Track width and height, padding around the knob, and the knob.
    final (
      double width,
      double height,
      double padding,
      double knob,
    ) = switch (size) {
      SossoldiSwitchSize.regular => (52, 28, SossoldiSpacing.xs, 20),
      SossoldiSwitchSize.small => (40, 22, 3, 16),
    };

    return SossoldiTappable(
      onTap: enabled ? () => onChanged!(!value) : null,
      semanticLabel: semanticLabel,
      toggled: value,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: value ? colors.primary.surface : colors.surfaceLow,
            borderRadius: BorderRadius.circular(SossoldiRadius.max),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knob,
              height: knob,
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
