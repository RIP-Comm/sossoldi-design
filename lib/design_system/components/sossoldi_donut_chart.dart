// Donut chart, from Figma "Donut" (node 13:4631): a ring split into
// colored segments, the largest first, starting at 12 o'clock and going
// clockwise. Colors come from the caller (category colors).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

class SossoldiChartSegment {
  const SossoldiChartSegment({required this.value, required this.color});

  /// Size of the segment relative to the others; must be positive.
  final double value;
  final Color color;
}

class SossoldiDonutChart extends StatelessWidget {
  const SossoldiDonutChart({
    super.key,
    required this.segments,
    this.size = 224,
    this.thickness = 28,
    this.semanticLabel,
  });

  final List<SossoldiChartSegment> segments;

  /// Outer diameter (Figma: 224).
  final double size;

  /// Width of the ring.
  final double thickness;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final chart = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          thickness: thickness,
          track: context.colors.surfaceLow,
        ),
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: chart)
        : Semantics(label: semanticLabel, image: true, child: chart);
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.thickness,
    required this.track,
  });

  final List<SossoldiChartSegment> segments;
  final double thickness;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(thickness / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true;
    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
      return;
    }
    var start = -math.pi / 2;
    for (final s in segments) {
      final sweep = s.value / total * math.pi * 2;
      canvas.drawArc(rect, start, sweep, false, paint..color = s.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.thickness != thickness ||
      old.track != track ||
      !_same(old.segments, segments);

  static bool _same(
    List<SossoldiChartSegment> a,
    List<SossoldiChartSegment> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value || a[i].color != b[i].color) return false;
    }
    return true;
  }
}
