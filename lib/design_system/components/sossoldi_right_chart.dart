// Right chart, from Figma component "Right chart" (node 3:4415).
// Small trend line with the current value and its change, shown on the
// right side of list rows (e.g. Asset). Color follows the change sign.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_change_tag.dart';

class SossoldiRightChart extends StatelessWidget {
  const SossoldiRightChart({
    super.key,
    required this.points,
    required this.value,
    required this.currencyCode,
    required this.change,
    this.trend,
    this.masked = false,
  });

  /// Values over time, oldest first. Needs at least 2 points; with fewer the
  /// chart is left out and only the value and its change show.
  final List<double> points;
  final num value;
  final String currencyCode;

  /// Change as a fraction (0.0123 = +1,23%).
  final num change;

  /// Sign of what the line shows when that is not [change] (the line of
  /// the last month next to a total profit and loss). Default: [change].
  final num? trend;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final role = (trend ?? change) < 0 ? colors.expense : colors.income;
    final hasChart = points.length >= 2;
    // Sized by its value row, at least 85 wide, so it can sit in a Row.
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 85),
        child: SizedBox(
          height: hasChart ? 60 : null,
          child: Column(
            mainAxisSize: hasChart ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              if (hasChart)
                Expanded(
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        points: points,
                        line: role.onSurface,
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: SossoldiSpacing.xs,
                children: [
                  SossoldiAmount(
                    value: value,
                    currencyCode: currencyCode,
                    masked: masked,
                    style: context.typography.labelSmall,
                  ),
                  SossoldiChangeTag.percent(value: change),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.line});

  final List<double> points;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.isEmpty) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    const strokeWidth = 1.5;

    Offset at(int i) => Offset(
      size.width * i / (points.length - 1),
      strokeWidth / 2 +
          (size.height - strokeWidth) * (1 - (points[i] - minV) / range),
    );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = at(i - 1);
      final p1 = at(i);
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.2), line.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points || old.line != line;
}
