// Cash flow chart, from the Figma "Income-Expense chart" (node 13:4545):
// income cumulated upwards in green and expenses cumulated downwards in red,
// each with a soft area, and the balance as a dashed line, over a whole
// period. The data stops at the last elapsed day; the rest stays empty.
// Hand-drawn like the other charts (no chart library).

import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import 'sossoldi_chart_tooltip.dart';
import 'sossoldi_stacked_area_chart.dart';

class SossoldiCashFlowChart extends StatefulWidget {
  const SossoldiCashFlowChart({
    super.key,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.length,
    required this.xLabels,
    required this.formatAxis,
    required this.pointTitles,
    required this.formatValue,
    required this.incomeLabel,
    required this.expenseLabel,
    required this.balanceLabel,
    this.masked = false,
    this.height = 160,
    this.semanticLabel,
  });

  /// Cumulative values, one per elapsed day, oldest first. [expenses] are
  /// positive numbers (they are drawn below the zero line); [balance] is
  /// income minus expenses.
  final List<double> income;
  final List<double> expenses;
  final List<double> balance;

  /// Days of the whole period: the horizontal axis spans all of them.
  final int length;

  /// Text under the axis for each of the [length] days (a few are shown).
  final List<String> xLabels;

  /// Number on the Y axis (compact, with its sign).
  final String Function(double value) formatAxis;

  /// Heading of the indicator's card for each of the [length] days.
  final List<String> pointTitles;

  /// Amount in the indicator, with its currency.
  final String Function(double value) formatValue;

  /// Names of the three rows of the indicator's card.
  final String incomeLabel;
  final String expenseLabel;
  final String balanceLabel;

  /// Hides the numbers of the Y axis; the shapes stay.
  final bool masked;

  /// The plot, X axis labels excluded.
  final double height;
  final String? semanticLabel;

  static const double yAxisWidth = 36;
  static const double xAxisHeight = 16;
  static const double _edge = 8;
  static const String maskText = '••';

  /// Round values for the Y axis covering [min]..[max] (min <= 0 <= max) in
  /// about four steps.
  static List<double> axisTicks(double min, double max) {
    final range = max - min;
    if (range <= 0) return const [-1, 0, 1];
    final raw = range / 4;
    final exponent = _floorLog10(raw);
    var step = raw;
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      final candidate = m * _pow10(exponent);
      if (candidate >= raw - 1e-9) {
        step = candidate;
        break;
      }
    }
    final first = (min / step).floor();
    final last = (max / step).ceil();
    return [for (var i = first; i <= last; i++) i * step];
  }

  static int _floorLog10(double v) {
    var e = 0;
    var x = v;
    while (x >= 10) {
      x /= 10;
      e++;
    }
    while (x < 1) {
      x *= 10;
      e--;
    }
    return e;
  }

  static double _pow10(int e) {
    var r = 1.0;
    for (var i = 0; i < e.abs(); i++) {
      r = e >= 0 ? r * 10 : r / 10;
    }
    return r;
  }

  @override
  State<SossoldiCashFlowChart> createState() => _SossoldiCashFlowChartState();
}

class _SossoldiCashFlowChartState extends State<SossoldiCashFlowChart> {
  int? _selected;

  SossoldiCashFlowChart get c => widget;

  /// The day under [dx] (in the plot), or null when it is past the last
  /// elapsed day: there is nothing to show there.
  void _select(double dx, double plotWidth) {
    if (c.income.isEmpty) return;
    final t = (dx / plotWidth).clamp(0.0, 1.0);
    final i = c.length <= 1 ? 0 : (t * (c.length - 1)).round();
    final next = i < c.income.length ? i : c.income.length - 1;
    if (next != _selected) setState(() => _selected = next);
  }

  @override
  void didUpdateWidget(SossoldiCashFlowChart old) {
    super.didUpdateWidget(old);
    if (_selected != null && _selected! >= c.income.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final income = c.income, expenses = c.expenses, balance = c.balance;
    final length = c.length, masked = c.masked, formatAxis = c.formatAxis;
    final xLabels = c.xLabels, height = c.height;
    const yAxisWidth = SossoldiCashFlowChart.yAxisWidth;
    const xAxisHeight = SossoldiCashFlowChart.xAxisHeight;
    const maskText = SossoldiCashFlowChart.maskText;
    final semanticLabel = c.semanticLabel;
    final axisTicks = SossoldiCashFlowChart.axisTicks;
    var maxV = 0.0, minV = 0.0;
    for (final v in [...income, ...balance]) {
      if (v > maxV) maxV = v;
      if (v < minV) minV = v;
    }
    for (final v in expenses) {
      if (-v < minV) minV = -v;
    }
    final ticks = axisTicks(minV, maxV);
    final labeled = SossoldiStackedAreaChart.labeledPoints(length);
    final labelStyle = typography.labelSmall.copyWith(color: colors.textMed);

    final chart = Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: height,
              // Room for the first and last number of the Y axis, which sit
              // centered on their line.
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SossoldiCashFlowChart._edge,
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
                                    t == 0
                                        ? '0'
                                        : masked
                                        ? maskText
                                        : formatAxis(t),
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
                              length <= 1 ? 0 : plotWidth * i / (length - 1);
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
                                  painter: _CashFlowPainter(
                                    income: income,
                                    expenses: expenses,
                                    balance: balance,
                                    length: length,
                                    ticks: ticks,
                                    selected: selected,
                                    incomeLine: colors.income.onSurface,
                                    incomeFill: colors.income.surface,
                                    expenseLine: colors.expense.onSurface,
                                    expenseFill: colors.expense.surface,
                                    balanceLine: colors.shapeMed,
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
                                              colors.income.onSurface,
                                              c.incomeLabel,
                                              income[selected],
                                            ),
                                            (
                                              colors.expense.onSurface,
                                              c.expenseLabel,
                                              expenses[selected],
                                            ),
                                            (
                                              colors.shapeMed,
                                              c.balanceLabel,
                                              balance[selected],
                                            ),
                                          ],
                                          totalLabel: null,
                                          masked: masked,
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
              height: xAxisHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: yAxisWidth),
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final i in labeled)
                        Positioned(
                          left: length <= 1
                              ? 0
                              : constraints.maxWidth * i / (length - 1),
                          child: FractionalTranslation(
                            // First label starts at the axis, last one ends
                            // at the right edge, the others are centered.
                            translation: Offset(
                              i == labeled.first
                                  ? 0
                                  : i == labeled.last
                                  ? -1
                                  : -0.5,
                              0,
                            ),
                            child: Text(
                              i < xLabels.length ? xLabels[i] : '',
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

class _CashFlowPainter extends CustomPainter {
  _CashFlowPainter({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.length,
    required this.ticks,
    required this.selected,
    required this.incomeLine,
    required this.incomeFill,
    required this.expenseLine,
    required this.expenseFill,
    required this.balanceLine,
    required this.grid,
    required this.axis,
    required this.indicator,
  });

  final List<double> income;
  final List<double> expenses;
  final List<double> balance;
  final int length;
  final List<double> ticks;
  final int? selected;
  final Color indicator;
  final Color incomeLine;
  final Color incomeFill;
  final Color expenseLine;
  final Color expenseFill;
  final Color balanceLine;
  final Color grid;
  final Color axis;

  static const double _lineWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final top = ticks.last, bottom = ticks.first;
    double y(double v) => (top - v) / (top - bottom) * size.height;
    double x(int i) => length <= 1 ? 0 : size.width * i / (length - 1);

    // Horizontal guides, the zero line a bit stronger.
    for (final t in ticks) {
      canvas.drawLine(
        Offset(0, y(t)),
        Offset(size.width, y(t)),
        Paint()
          ..color = t == 0 ? axis : grid
          ..strokeWidth = 1,
      );
    }
    // The Y axis.
    canvas.drawLine(
      Offset.zero,
      Offset(0, size.height),
      Paint()
        ..color = axis
        ..strokeWidth = 1,
    );

    void series(List<double> values, Color line, Color fill) {
      if (values.isEmpty) return;
      final pts = [for (final (i, v) in values.indexed) Offset(x(i), y(v))];
      if (pts.length == 1) {
        canvas.drawCircle(pts.first, _lineWidth * 1.5, Paint()..color = line);
        return;
      }
      final path = _curve(pts);
      final zero = y(0);
      final area = Path.from(path)
        ..lineTo(pts.last.dx, zero)
        ..lineTo(pts.first.dx, zero)
        ..close();
      final isAbove = pts.last.dy <= zero;
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: isAbove ? Alignment.topCenter : Alignment.bottomCenter,
            end: isAbove ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [fill, fill.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
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

    series(income, incomeLine, incomeFill);
    series([for (final v in expenses) -v], expenseLine, expenseFill);

    if (balance.length > 1) {
      final path = _curve([
        for (final (i, v) in balance.indexed) Offset(x(i), y(v)),
      ]);
      canvas.drawPath(
        _dashed(path),
        Paint()
          ..color = balanceLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    } else if (balance.length == 1) {
      canvas.drawCircle(
        Offset(x(0), y(balance.first)),
        2,
        Paint()..color = balanceLine,
      );
    }

    // The selected day: a vertical line.
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

  /// A smooth line that never goes beyond its points: each step leaves and
  /// arrives horizontally.
  static Path _curve(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      final mid = (a.dx + b.dx) / 2;
      path.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    return path;
  }

  static Path _dashed(Path source) {
    const dash = 2.0, gap = 3.0;
    final out = Path();
    for (final PathMetric m in source.computeMetrics()) {
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
  bool shouldRepaint(_CashFlowPainter old) =>
      old.income != income ||
      old.expenses != expenses ||
      old.balance != balance ||
      old.length != length ||
      old.selected != selected ||
      old.incomeLine != incomeLine ||
      old.expenseLine != expenseLine ||
      old.grid != grid;
}
