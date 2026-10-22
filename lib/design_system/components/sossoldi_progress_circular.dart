// Circular progress, from Figma component "Progress-Circular" (node 3:3754).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

/// sm: 32px, md: 40px.
enum SossoldiProgressCircularSize { sm, md }

class SossoldiProgressCircular extends StatelessWidget {
  const SossoldiProgressCircular({
    super.key,
    required this.value,
    this.size = SossoldiProgressCircularSize.sm,
    this.semanticLabel,
  });

  /// Progress from 0 to 1.
  final double value;
  final SossoldiProgressCircularSize size;
  final String? semanticLabel;

  /// Figma: track at 24% opacity.
  static const double trackOpacity = 0.24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (double box, double stroke) = switch (size) {
      SossoldiProgressCircularSize.sm => (32, 2),
      SossoldiProgressCircularSize.md => (40, 4),
    };
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: CustomPaint(
        size: Size.square(box),
        painter: _RingPainter(
          value: value.clamp(0, 1),
          track: colors.shapeMed.withValues(alpha: trackOpacity),
          progress: colors.primary.surface,
          strokeWidth: stroke,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.track,
    required this.progress,
    required this.strokeWidth,
  });

  final double value;
  final Color track;
  final Color progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = progress,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.track != track ||
      old.progress != progress ||
      old.strokeWidth != strokeWidth;
}
