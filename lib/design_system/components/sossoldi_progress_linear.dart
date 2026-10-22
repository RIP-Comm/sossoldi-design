// Linear progress, from Figma component "Progress-Linear" (node 3:3761):
// an 8px bar with a white knob at the current value.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import 'sossoldi_progress_circular.dart';

class SossoldiProgressLinear extends StatelessWidget {
  const SossoldiProgressLinear({
    super.key,
    required this.value,
    this.showKnob = true,
    this.semanticLabel,
  });

  /// Progress from 0 to 1.
  final double value;
  final bool showKnob;
  final String? semanticLabel;

  static const double _height = 8;
  static const double _knob = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      child: SizedBox(
        height: _knob,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: _height,
                  decoration: BoxDecoration(
                    color: colors.shapeMed.withValues(
                      alpha: SossoldiProgressCircular.trackOpacity,
                    ),
                    borderRadius: BorderRadius.circular(SossoldiRadius.max),
                  ),
                ),
                Container(
                  width: width * v,
                  height: _height,
                  decoration: BoxDecoration(
                    color: colors.primary.surface,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(SossoldiRadius.max),
                    ),
                  ),
                ),
                if (showKnob)
                  Positioned(
                    left: (width * v - _knob / 2).clamp(0, width - _knob),
                    child: Container(
                      width: _knob,
                      height: _knob,
                      decoration: BoxDecoration(
                        color: colors.surfaceHigh,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
