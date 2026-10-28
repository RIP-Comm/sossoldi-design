// Market value chart of the Investments Overview, from the Figma chart
// (node 13:4855): the market value as a line with a soft area under it and,
// as a dashed line, the capital invested. Touch or drag shows an indicator
// and a card with the day (or time), the value, the invested capital and the
// difference. Hand-drawn like the other charts (no chart library).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import 'sossoldi_chart_tooltip.dart';
import 'sossoldi_stacked_area_chart.dart';

class SossoldiValueChart extends StatefulWidget {
  const SossoldiValueChart({
    super.key,
    required this.values,
    required this.invested,
    required this.pointLabels,
    required this.pointTitles,
    required this.formatAxis,
    required this.formatValue,
    required this.valueLabel,
    required this.investedLabel,
    this.masked = false,
    this.height = 160,
    this.semanticLabel,
  });

  /// One value per point, oldest first. [invested] has the same length.
  final List<double> values;
  final List<double> invested;

  /// Short text under the axis for each point (a few are shown).
  final List<String> pointLabels;

  /// Heading of the indicator's card for each point (the date or the time).
  final List<String> pointTitles;

  /// Number on the Y axis (compact).
  final String Function(double value) formatAxis;

  /// Amount in the card, with its currency.
  final String Function(double value) formatValue;

  final String valueLabel;
  final String investedLabel;

  /// Hides the numbers (axis and card); the lines stay.
  final bool masked;

  /// The plot, X axis labels excluded.
  final double height;
  final String? semanticLabel;

  static const double yAxisWidth = 36;
  static const double xAxisHeight = 16;
  static const double _edge = 8;
  static const String maskText = '••';

  /// Round values from just under [min] to just over [max], in about four
  /// equal steps (at least two ticks).
  static List<double> axisTicks(double min, double max) {
    var lo = min, hi = max;
    if (hi - lo <= 0) {
      final pad = hi == 0 ? 1.0 : hi.abs() * 0.05;
      lo -= pad;
      hi += pad;
    }
    final raw = (hi - lo) / 4;
    var exponent = 0;
    var x = raw;
    while (x >= 10) {
      x /= 10;
      exponent++;
    }
    while (x < 1) {
      x *= 10;
      exponent--;
    }
    final unit = math.pow(10, exponent).toDouble();
    var step = raw;
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (m * unit >= raw - 1e-9) {
        step = m * unit;
        break;
      }
    }
    final first = (lo / step).floor();
    final last = (hi / step).ceil();
    return [for (var i = first; i <= last; i++) i * step];
  }

  @override
  State<SossoldiValueChart> createState() => _SossoldiValueChartState();
}

class _SossoldiValueChartState extends State<SossoldiValueChart> {
  int? _selected;

  SossoldiValueChart get c => widget;
  int get _count => c.values.length;

  void _select(double dx, double plotWidth) {
    if (_count == 0) return;
    final t = (dx / plotWidth).clamp(0.0, 1.0);
    final i = _count <= 1 ? 0 : (t * (_count - 1)).round();
    if (i != _selected) setState(() => _selected = i);
  }

  @override
  void didUpdateWidget(SossoldiValueChart old) {
    super.didUpdateWidget(old);
    if (_selected != null && _selected! >= _count) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.typography.labelSmall.copyWith(
      color: colors.textMed,
    );
    var minV = double.infinity, maxV = -double.infinity;
    for (final v in [...c.values, ...c.invested]) {
      minV = math.min(minV, v);
      maxV = math.max(maxV, v);
    }
    if (_count == 0) {
      minV = 0;
      maxV = 0;
    }
    final ticks = SossoldiValueChart.axisTicks(minV, maxV);
    final labeled = SossoldiStackedAreaChart.labeledPoints(_count);
    // Green while the value is above what was invested, red below it.
    final gaining = _count == 0 || c.values.last >= c.invested.last;
    final role = gaining ? colors.income : colors.expense;
    const yAxisWidth = SossoldiValueChart.yAxisWidth;

    final chart = Semantics(
      label: c.semanticLabel,
      container: c.semanticLabel != null,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: c.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SossoldiValueChart._edge,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: yAxisWidth,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final top = ticks.last, bottom = ticks.first;
                          double y(double v) =>
                              (top - v) /
                              (top - bottom) *
                              constraints.maxHeight;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              for (final t in ticks)
                                Positioned(
                                  right: 4,
                                  top: y(t) - 7,
                                  child: Text(
                                    c.masked
                                        ? SossoldiValueChart.maskText
                                        : c.formatAxis(t),
                                    style: labelStyle,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final plotWidth = constraints.maxWidth;
                          final selected = _selected;
                          double pointX(int i) =>
                              _count <= 1 ? 0 : plotWidth * i / (_count - 1);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (d) =>
                                    _select(d.localPosition.dx, plotWidth),
                                onHorizontalDragStart: (d) =>
                                    _select(d.localPosition.dx, plotWidth),
                                onHorizontalDragUpdate: (d) =>
                                    _select(d.localPosition.dx, plotWidth),
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: _ValuePainter(
                                    values: c.values,
                                    invested: c.invested,
                                    ticks: ticks,
                                    selected: selected,
                                    line: role.onSurface,
                                    fill: role.surface,
                                    investedLine: colors.shapeMed,
                                    grid: colors.strokeMinus1,
                                    axis: colors.strokeDefault,
                                    indicator: colors.shapeMed,
                                  ),
                                ),
                              ),
                              if (selected != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomSingleChildLayout(
                                      delegate: SossoldiChartTooltipLayout(
                                        pointX(selected),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.topLeft,
                                        child: SossoldiChartTooltip(
                                          title: selected < c.pointTitles.length
                                              ? c.pointTitles[selected]
                                              : '',
                                          rows: [
                                            (
                                              role.onSurface,
                                              c.valueLabel,
                                              c.values[selected],
                                            ),
                                            (
                                              colors.shapeMed,
                                              c.investedLabel,
                                              c.invested[selected],
                                            ),
                                          ],
                                          totalLabel: null,
                                          masked: c.masked,
                                          formatValue: c.formatValue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: SossoldiValueChart.xAxisHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: yAxisWidth),
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final i in labeled)
                        Positioned(
                          left: _count <= 1
                              ? 0
                              : constraints.maxWidth * i / (_count - 1),
                          child: FractionalTranslation(
                            translation: Offset(
                              i == labeled.first
                                  ? 0
                                  : i == labeled.last
                                  ? -1
                                  : -0.5,
                              0,
                            ),
                            child: Text(
                              i < c.pointLabels.length ? c.pointLabels[i] : '',
                              style: labelStyle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return TapRegion(
      onTapOutside: (_) {
        if (_selected != null) setState(() => _selected = null);
      },
      child: chart,
    );
  }
}

class _ValuePainter extends CustomPainter {
  _ValuePainter({
    required this.values,
    required this.invested,
    required this.ticks,
    required this.selected,
    required this.line,
    required this.fill,
    required this.investedLine,
    required this.grid,
    required this.axis,
    required this.indicator,
  });

  final List<double> values;
  final List<double> invested;
  final List<double> ticks;
  final int? selected;
  final Color line;
  final Color fill;
  final Color investedLine;
  final Color grid;
  final Color axis;
  final Color indicator;

  static const double _lineWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final top = ticks.last, bottom = ticks.first;
    double y(double v) => (top - v) / (top - bottom) * size.height;
    final n = values.length;
    double x(int i) => n <= 1 ? 0 : size.width * i / (n - 1);

    for (final t in ticks) {
      canvas.drawLine(
        Offset(0, y(t)),
        Offset(size.width, y(t)),
        Paint()
          ..color = grid
          ..strokeWidth = 1,
      );
    }
    final axisPaint = Paint()
      ..color = axis
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(0, size.height), axisPaint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );
    if (n == 0) return;

    final pts = [for (var i = 0; i < n; i++) Offset(x(i), y(values[i]))];
    if (n == 1) {
      canvas.drawCircle(pts.first, _lineWidth * 1.5, Paint()..color = line);
    } else {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
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
            colors: [fill, fill.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      // The invested capital, dashed, under the value line.
      final inv = Path()..moveTo(x(0), y(invested[0]));
      for (var i = 1; i < n; i++) {
        inv.lineTo(x(i), y(invested[i]));
      }
      canvas.drawPath(
        _dashed(inv),
        Paint()
          ..color = investedLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    if (n == 1) {
      canvas.drawCircle(
        Offset(x(0), y(invested[0])),
        2,
        Paint()..color = investedLine,
      );
    }

    final i = selected;
    if (i != null) {
      canvas.drawLine(
        Offset(x(i), 0),
        Offset(x(i), size.height),
        Paint()
          ..color = indicator
          ..strokeWidth = 1,
      );
    }
  }

  static Path _dashed(Path source) {
    const dash = 3.0, gap = 3.0;
    final out = Path();
    for (final m in source.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        out.addPath(
          m.extractPath(d, (d + dash).clamp(0, m.length)),
          Offset.zero,
        );
        d += dash + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_ValuePainter old) =>
      old.values != values ||
      old.invested != invested ||
      old.selected != selected ||
      old.line != line ||
      old.grid != grid ||
      old.ticks != ticks;
}
