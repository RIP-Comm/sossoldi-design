// Stacked area chart, from Figma "Chart container" (node 13:4661): colored
// areas stacked bottom to top, a Y axis with 4 labels (0 and three steps),
// an X axis with a few labels, and, from the hidden "Today" layer, a
// vertical indicator with the values of the touched point.
//
// Touch or drag horizontally to move the indicator; tapping outside the
// chart removes it. With [masked] the Y labels and the values in the
// indicator are hidden; the shapes stay.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import 'sossoldi_chart_tooltip.dart';

class SossoldiAreaSeries {
  const SossoldiAreaSeries({
    required this.name,
    required this.color,
    required this.values,
  });

  final String name;
  final Color color;

  /// One value per point, not negative. All series have the same length.
  final List<double> values;
}

class SossoldiStackedAreaChart extends StatefulWidget {
  const SossoldiStackedAreaChart({
    super.key,
    required this.series,
    required this.pointLabels,
    required this.pointTitles,
    required this.formatValue,
    required this.formatAxis,
    this.totalLabel,
    this.masked = false,
    this.height = 200,
    this.semanticLabel,
  });

  /// Bottom series first.
  final List<SossoldiAreaSeries> series;

  /// Short text under the axis for each point (a few are shown).
  final List<String> pointLabels;

  /// Heading of the indicator's card for each point.
  final List<String> pointTitles;

  /// Amount in the indicator, with its currency.
  final String Function(double value) formatValue;

  /// Number on the Y axis (compact, no currency).
  final String Function(double value) formatAxis;

  /// When set, the indicator's card ends with a total row with this label.
  final String? totalLabel;
  final bool masked;

  /// Whole chart, X axis labels included (Figma: 200).
  final double height;
  final String? semanticLabel;

  static const double _yAxisWidth = 30;
  static const double _xAxisHeight = 16;
  static const double _edge = 6;
  static const String maskText = '••••';

  /// The top of the Y axis for data up to [max]: three equal steps of
  /// 1, 2, 2.5 or 5 times a power of ten.
  static double niceAxisMax(double max) {
    if (max <= 0) return 3;
    final exponent = (math.log(max / 3) / math.ln10).floor();
    for (final e in [exponent, exponent + 1]) {
      final unit = math.pow(10, e).toDouble();
      for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
        if (m * unit * 3 >= max - 1e-9) return m * unit * 3;
      }
    }
    return max;
  }

  /// Indices of the points whose label is drawn: all up to 4, else 4 evenly
  /// spaced ones.
  static List<int> labeledPoints(int count) {
    if (count <= 4) return [for (var i = 0; i < count; i++) i];
    return {for (var k = 0; k < 4; k++) (k * (count - 1) / 3).round()}.toList();
  }

  @override
  State<SossoldiStackedAreaChart> createState() =>
      _SossoldiStackedAreaChartState();
}

class _SossoldiStackedAreaChartState extends State<SossoldiStackedAreaChart> {
  int? _selected;

  int get _count =>
      widget.series.isEmpty ? 0 : widget.series.first.values.length;

  double _stackMax() {
    var max = 0.0;
    for (var i = 0; i < _count; i++) {
      var sum = 0.0;
      for (final s in widget.series) {
        sum += s.values[i];
      }
      max = math.max(max, sum);
    }
    return max;
  }

  int _indexAt(double dx, double plotWidth) {
    if (_count <= 1) return 0;
    final t = ((dx - SossoldiStackedAreaChart._yAxisWidth) / plotWidth).clamp(
      0.0,
      1.0,
    );
    return (t * (_count - 1)).round();
  }

  void _select(double dx, double plotWidth) {
    final i = _indexAt(dx, plotWidth);
    if (i != _selected) setState(() => _selected = i);
  }

  @override
  void didUpdateWidget(SossoldiStackedAreaChart old) {
    super.didUpdateWidget(old);
    final count = _count;
    if (_selected != null && _selected! >= count) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.typography.captionSmall.copyWith(
      color: colors.shapeMed,
    );
    final axisMax = SossoldiStackedAreaChart.niceAxisMax(_stackMax());
    final chart = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final plotWidth = width - SossoldiStackedAreaChart._yAxisWidth;
        final selected = _selected;
        double pointX(int i) =>
            SossoldiStackedAreaChart._yAxisWidth +
            (_count <= 1 ? 0 : i / (_count - 1) * plotWidth);
        return SizedBox(
          width: width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _select(d.localPosition.dx, plotWidth),
                onHorizontalDragStart: (d) =>
                    _select(d.localPosition.dx, plotWidth),
                onHorizontalDragUpdate: (d) =>
                    _select(d.localPosition.dx, plotWidth),
                child: CustomPaint(
                  size: Size(width, widget.height),
                  painter: _AreaPainter(
                    series: widget.series,
                    pointLabels: widget.pointLabels,
                    axisMax: axisMax,
                    selected: selected,
                    masked: widget.masked,
                    formatAxis: widget.formatAxis,
                    labelStyle: labelStyle,
                    areaStroke: colors.surfaceHigh,
                    axisColor: colors.strokeDefault,
                    indicatorColor: colors.shapeMed,
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
              if (selected != null)
                Positioned.fill(
                  bottom: SossoldiStackedAreaChart._xAxisHeight,
                  child: IgnorePointer(
                    child: CustomSingleChildLayout(
                      delegate: SossoldiChartTooltipLayout(pointX(selected)),
                      // With very many categories the card shrinks to fit the
                      // plot instead of overflowing.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: SossoldiChartTooltip(
                          title: widget.pointTitles[selected],
                          rows: [
                            // Top of the stack first, as it reads on the chart.
                            for (final s in widget.series.reversed)
                              if (s.values[selected] > 0)
                                (s.color, s.name, s.values[selected]),
                          ],
                          totalLabel: widget.totalLabel,
                          masked: widget.masked,
                          formatValue: widget.formatValue,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    return TapRegion(
      onTapOutside: (_) {
        if (_selected != null) setState(() => _selected = null);
      },
      child: widget.semanticLabel == null
          ? ExcludeSemantics(child: chart)
          : Semantics(label: widget.semanticLabel, image: true, child: chart),
    );
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter({
    required this.series,
    required this.pointLabels,
    required this.axisMax,
    required this.selected,
    required this.masked,
    required this.formatAxis,
    required this.labelStyle,
    required this.areaStroke,
    required this.axisColor,
    required this.indicatorColor,
    required this.textDirection,
  });

  final List<SossoldiAreaSeries> series;
  final List<String> pointLabels;
  final double axisMax;
  final int? selected;
  final bool masked;
  final String Function(double) formatAxis;
  final TextStyle labelStyle;
  final Color areaStroke;
  final Color axisColor;
  final Color indicatorColor;
  final TextDirection textDirection;

  static const double _left = SossoldiStackedAreaChart._yAxisWidth;
  static const double _edge = SossoldiStackedAreaChart._edge;
  static const double _tick = 4;

  TextPainter _text(String text, {double maxWidth = 80}) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: textDirection,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final count = series.isEmpty ? 0 : series.first.values.length;
    final plotWidth = size.width - _left;
    final plotHeight = size.height - SossoldiStackedAreaChart._xAxisHeight;
    // Value 0 sits on the X axis and the top step on the first Y label.
    final baseline = plotHeight - _edge;
    final top = _edge;
    double yOf(double v) => baseline - v / axisMax * (baseline - top);
    double xOf(int i) => _left + (count <= 1 ? 0 : i / (count - 1) * plotWidth);

    // Areas, bottom series first.
    final lower = List<double>.filled(count, 0);
    for (final s in series) {
      final upper = [for (var i = 0; i < count; i++) lower[i] + s.values[i]];
      final path = Path();
      if (count == 1) {
        path
          ..moveTo(_left, yOf(upper[0]))
          ..lineTo(size.width, yOf(upper[0]))
          ..lineTo(size.width, yOf(lower[0]))
          ..lineTo(_left, yOf(lower[0]));
      } else if (count > 1) {
        path.moveTo(xOf(0), yOf(upper[0]));
        for (var i = 1; i < count; i++) {
          path.lineTo(xOf(i), yOf(upper[i]));
        }
        for (var i = count - 1; i >= 0; i--) {
          path.lineTo(xOf(i), yOf(lower[i]));
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = s.color);
      for (var i = 0; i < count; i++) {
        lower[i] = upper[i];
      }
    }

    // Axes.
    final axis = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(_left, 0), Offset(_left, baseline), axis);
    canvas.drawLine(
      Offset(_left, baseline),
      Offset(size.width, baseline),
      axis,
    );

    // Y labels: 0 and three steps, each with a tick.
    for (var k = 0; k <= 3; k++) {
      final value = axisMax * k / 3;
      final y = yOf(value);
      canvas.drawLine(Offset(_left - _tick, y), Offset(_left, y), axis);
      if (!masked) {
        final p = _text(formatAxis(value), maxWidth: _left - _tick - 4);
        p.paint(canvas, Offset(_left - _tick - 4 - p.width, y - p.height / 2));
      }
    }

    // X labels under a few points.
    for (final i in SossoldiStackedAreaChart.labeledPoints(count)) {
      final x = xOf(i);
      canvas.drawLine(Offset(x, baseline), Offset(x, baseline + _tick), axis);
      final p = _text(pointLabels[i], maxWidth: plotWidth / 3);
      final left = (x - p.width / 2).clamp(_left - 4, size.width - p.width);
      p.paint(canvas, Offset(left, baseline + _tick));
    }

    // The indicator.
    if (selected != null && count > 0) {
      final x = xOf(selected!);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, baseline),
        Paint()
          ..color = indicatorColor
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_AreaPainter old) => true;
}
