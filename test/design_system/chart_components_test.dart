import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../load_test_fonts.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: brightness == Brightness.dark
          ? SossoldiTheme.dark
          : SossoldiTheme.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);

SossoldiStackedAreaChart _chart({
  bool masked = false,
  List<SossoldiAreaSeries>? series,
  List<String>? labels,
}) {
  final s =
      series ??
      const [
        SossoldiAreaSeries(name: 'Rent', color: _red, values: [100, 200, 150]),
        SossoldiAreaSeries(name: 'Food', color: _green, values: [50, 0, 70]),
        SossoldiAreaSeries(name: 'Fun', color: _blue, values: [0, 30, 20]),
      ];
  final n = s.first.values.length;
  final l = labels ?? [for (var i = 0; i < n; i++) 'P$i'];
  return SossoldiStackedAreaChart(
    series: s,
    pointLabels: l,
    pointTitles: [for (var i = 0; i < n; i++) 'Title $i'],
    formatValue: (v) => '€${v.toStringAsFixed(0)}',
    formatAxis: (v) => v.toStringAsFixed(0),
    totalLabel: 'Total',
    masked: masked,
  );
}

void main() {
  setUpAll(loadTestFonts);

  group('axis helpers', () {
    test('niceAxisMax gives three equal nice steps over the data', () {
      expect(SossoldiStackedAreaChart.niceAxisMax(0), 3);
      expect(SossoldiStackedAreaChart.niceAxisMax(3), 3);
      expect(SossoldiStackedAreaChart.niceAxisMax(3.1), 6);
      expect(SossoldiStackedAreaChart.niceAxisMax(100), 150);
      expect(SossoldiStackedAreaChart.niceAxisMax(600), 600);
      expect(SossoldiStackedAreaChart.niceAxisMax(0.5), closeTo(0.6, 1e-9));
      expect(SossoldiStackedAreaChart.niceAxisMax(1234), 1500);
      for (final v in [1.0, 7.0, 99.0, 451.0, 2999.0, 12345.0]) {
        final max = SossoldiStackedAreaChart.niceAxisMax(v);
        expect(max, greaterThanOrEqualTo(v));
        expect(max, lessThan(v * 3.01 + 3));
      }
    });

    test('labeledPoints picks all up to four, else four evenly spaced', () {
      expect(SossoldiStackedAreaChart.labeledPoints(0), isEmpty);
      expect(SossoldiStackedAreaChart.labeledPoints(1), [0]);
      expect(SossoldiStackedAreaChart.labeledPoints(4), [0, 1, 2, 3]);
      expect(SossoldiStackedAreaChart.labeledPoints(5), [0, 1, 3, 4]);
      expect(SossoldiStackedAreaChart.labeledPoints(10), [0, 3, 6, 9]);
      final many = SossoldiStackedAreaChart.labeledPoints(53);
      expect(many.first, 0);
      expect(many.last, 52);
      expect(many, hasLength(4));
    });
  });

  group('donut chart', () {
    testWidgets('draws with any number of segments, and with none', (
      tester,
    ) async {
      for (final n in [0, 1, 2, 12]) {
        await tester.pumpWidget(
          _wrap(
            SossoldiDonutChart(
              segments: [
                for (var i = 0; i < n; i++)
                  SossoldiChartSegment(value: i + 1.0, color: _red),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
      expect(
        tester.getSize(find.byType(SossoldiDonutChart)),
        const Size(224, 224),
      );
    });

    testWidgets('exposes a label to screen readers when given one', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const SossoldiDonutChart(
            segments: [SossoldiChartSegment(value: 1, color: _red)],
            semanticLabel: 'By category',
          ),
        ),
      );
      expect(find.bySemanticsLabel('By category'), findsOneWidget);
      handle.dispose();
    });
  });

  group('legend', () {
    testWidgets('shows names, optional values, and wraps', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: SossoldiChartLegend(
              items: [
                for (var i = 0; i < 6; i++)
                  SossoldiLegendItem(
                    color: _red,
                    label: 'Category $i',
                    value: i.isEven ? '€$i' : null,
                  ),
              ],
            ),
          ),
        ),
      );
      expect(
        find.textContaining('Category 0', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('€2', findRichText: true), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a very long name does not overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 120,
            child: SossoldiChartLegend(
              items: [
                SossoldiLegendItem(color: _red, label: 'N' * 90, value: '€1'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('stacked area chart', () {
    Future<void> pump(
      WidgetTester tester,
      Widget chart, {
      Brightness b = Brightness.light,
      double width = 358,
    }) {
      return tester.pumpWidget(
        _wrap(
          SizedBox(width: width, child: chart),
          brightness: b,
        ),
      );
    }

    testWidgets('has the height asked and no indicator at first', (
      tester,
    ) async {
      await pump(tester, _chart());
      expect(tester.getSize(find.byType(SossoldiStackedAreaChart)).height, 200);
      expect(find.text('Title 0'), findsNothing);
    });

    testWidgets('a tap shows the values of the nearest point, top first', (
      tester,
    ) async {
      await pump(tester, _chart());
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      // The plot starts after the 30px Y axis; the second point is in the middle.
      await tester.tapAt(
        Offset(box.left + 30 + (box.width - 30) / 2, box.center.dy),
      );
      await tester.pump();
      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('€200'), findsOneWidget);
      expect(find.text('€30'), findsOneWidget);
      // Food is 0 at that point: it has no row.
      expect(find.text('Food'), findsNothing);
      // Total row for the point: 200 + 0 + 30.
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('€230'), findsOneWidget);
      final names = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(names.indexOf('Fun'), lessThan(names.indexOf('Rent')));
    });

    testWidgets('dragging moves the indicator between points', (tester) async {
      await pump(tester, _chart());
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      final gesture = await tester.startGesture(
        Offset(box.left + 40, box.center.dy),
      );
      // The press is recognised after a short delay.
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Title 0'), findsOneWidget);
      await gesture.moveTo(Offset(box.right - 2, box.center.dy));
      await tester.pump();
      expect(find.text('Title 2'), findsOneWidget);
      expect(find.text('Title 0'), findsNothing);
      await gesture.up();
      await tester.pump();
      // It stays after the finger is lifted.
      expect(find.text('Title 2'), findsOneWidget);
    });

    testWidgets('tapping outside the chart removes the indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              SizedBox(width: 358, child: _chart()),
              const SizedBox(height: 40, child: Text('outside')),
            ],
          ),
        ),
      );
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.left + 40, box.center.dy));
      await tester.pump();
      expect(find.text('Title 0'), findsOneWidget);
      await tester.tap(find.text('outside'));
      await tester.pump();
      expect(find.text('Title 0'), findsNothing);
    });

    testWidgets('the card moves to the left near the right edge', (
      tester,
    ) async {
      await pump(tester, _chart());
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.right - 2, box.center.dy));
      await tester.pump();
      final card = tester.getRect(find.text('Title 2'));
      expect(card.right, lessThanOrEqualTo(box.right));
    });

    testWidgets('masked: values and Y labels are hidden, shapes stay', (
      tester,
    ) async {
      await pump(tester, _chart(masked: true));
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.left + 40, box.center.dy));
      await tester.pump();
      expect(find.text('Title 0'), findsOneWidget);
      expect(find.text('••••'), findsWidgets);
      expect(find.textContaining('€'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one point is drawn as a flat band', (tester) async {
      await pump(
        tester,
        _chart(
          series: const [
            SossoldiAreaSeries(name: 'Rent', color: _red, values: [100]),
            SossoldiAreaSeries(name: 'Food', color: _green, values: [50]),
          ],
        ),
      );
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.center.dx, box.center.dy));
      await tester.pump();
      expect(find.text('Title 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('many series, many points, narrow width, dark mode', (
      tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: [
            for (var s = 0; s < 14; s++)
              SossoldiAreaSeries(
                name: 'Category $s',
                color: Color(0xFF000000 + s * 0x111111),
                values: [for (var i = 0; i < 53; i++) (i * 7 + s * 13) % 90.0],
              ),
          ],
        ),
        b: Brightness.dark,
        width: 250,
      );
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.right - 3, box.center.dy));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a data set with fewer points drops a stale selection', (
      tester,
    ) async {
      await pump(tester, _chart());
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.right - 2, box.center.dy));
      await tester.pump();
      await pump(
        tester,
        _chart(
          series: const [
            SossoldiAreaSeries(name: 'Rent', color: _red, values: [1, 2]),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Title 2'), findsNothing);
    });
  });
}
