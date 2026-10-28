// Trend chart used by dashboard widgets, from the Figma "Monthly balance"
// widget (node 13:3846): the current period as a solid line with a soft
// fill underneath, drawn up to today, and the reference period (e.g. the
// previous month) as a dashed grey line across the whole width. Both
// lines share the same vertical scale.

import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

/// Colors the current line: income (green) or expense (red).
enum SossoldiTrendTone { positive, negative }

class SossoldiTrendChart extends StatelessWidget {
  const SossoldiTrendChart({
    super.key,
    required this.current,
    required this.length,
    this.reference = const [],
    this.tone = SossoldiTrendTone.positive,
  });

  /// Values of the current period, one per elapsed day, oldest first.
  final List<double> current;

  /// Number of days of the whole period: the horizontal axis spans it, so
  /// the line stops proportionally to how much of the period has passed.
  final int length;

  /// Values of the reference period, mapped over the whole width.
  final List<double> reference;
  final SossoldiTrendTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final role = tone == SossoldiTrendTone.positive
        ? colors.income
        : colors.expense;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.infinite,
        painter: _TrendPainter(
          current: current,
          length: length,
          reference: reference,
          line: role.onSurface,
          fill: role.surface,
          referenceLine: colors.shapeLow,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.current,
    required this.length,
    required this.reference,
    required this.line,
    required this.fill,
    required this.referenceLine,
  });

  final List<double> current;
  final int length;
  final List<double> reference;
  final Color line;
  final Color fill;
  final Color referenceLine;

  static const double _lineWidth = 1.5;
  static const double _referenceWidth = 1;
  static const double _dash = 2;
  static const double _gap = 3;

  /// Breathing room above the highest point.
  static const double _topInset = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...current, ...reference];
    if (all.isEmpty || size.isEmpty) return;
    final minV = all.reduce((a, b) => a < b ? a : b);
    final maxV = all.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV == 0 ? 1.0 : maxV - minV;
    final top = _topInset;
    final bottom = size.height - _lineWidth / 2;

    double y(double v) => bottom - (v - minV) / range * (bottom - top);

    List<Offset> points(List<double> values, int slots) => [
      for (final (i, v) in values.indexed)
        Offset(slots <= 1 ? 0 : size.width * i / (slots - 1), y(v)),
    ];

    if (reference.length > 1) {
      final path = _smooth(points(reference, reference.length));
      canvas.drawPath(
        _dashed(path),
        Paint()
          ..color = referenceLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = _referenceWidth,
      );
    }

    if (current.length == 1) {
      canvas.drawCircle(
        points(current, length).first,
        _lineWidth * 1.5,
        Paint()..color = line,
      );
    } else if (current.length > 1) {
      final pts = points(current, length);
      final path = _smooth(pts);
      final area = Path.from(path)
        ..lineTo(pts.last.dx, size.height)
        ..lineTo(pts.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fill,
              fill.withValues(alpha: 0.8),
              fill.withValues(alpha: 0.4),
            ],
            stops: const [0, 0.51, 1],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Smooth curve through [pts] (horizontal tangents at each point, so it
  /// never overshoots the data).
  Path _smooth(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final midX = (a.dx + b.dx) / 2;
      path.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
    }
    return path;
  }

  Path _dashed(Path source) {
    final result = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        result.addPath(
          metric.extractPath(distance, distance + _dash),
          Offset.zero,
        );
        distance += _dash + _gap;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.current != current ||
      old.reference != reference ||
      old.length != length ||
      old.line != line ||
      old.fill != fill ||
      old.referenceLine != referenceLine;
}

/// Legend under a [SossoldiTrendChart], from the Figma "Legend" (node
/// 13:4020): a solid swatch for the current period, a dashed one for the
/// reference period.
class SossoldiTrendLegend extends StatelessWidget {
  const SossoldiTrendLegend({
    super.key,
    required this.currentLabel,
    required this.referenceLabel,
    this.tone = SossoldiTrendTone.positive,
  });

  final String currentLabel;
  final String referenceLabel;
  final SossoldiTrendTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final role = tone == SossoldiTrendTone.positive
        ? colors.income
        : colors.expense;
    final style = context.typography.captionSmall.copyWith(
      color: colors.textMed,
    );
    Widget item(Color color, bool dashed, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        CustomPaint(
          size: const Size(12, 1),
          painter: _SwatchPainter(color: color, dashed: dashed),
        ),
        Text(label, style: style),
      ],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        item(role.onSurface, false, currentLabel),
        item(colors.shapeLow, true, referenceLabel),
      ],
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    for (var x = 0.0; x < size.width; x += 5) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + 2).clamp(0, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.color != color || old.dashed != dashed;
}
