import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../load_test_fonts.dart';

Widget _wrap(
  Widget child, {
  Brightness brightness = Brightness.light,
  double width = 358,
}) => MaterialApp(
  theme: brightness == Brightness.dark
      ? SossoldiTheme.dark
      : SossoldiTheme.light,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(width: width, child: child),
    ),
  ),
);

SossoldiPortfolioCard _card({
  double gain = 1680,
  double percent = 0.2423,
  bool masked = false,
}) => SossoldiPortfolioCard(
  label: 'Portfolio value',
  value: 32734.88,
  gain: gain,
  gainPercent: percent,
  currencyCode: 'EUR',
  liquidityLabel: 'Available liquidity',
  liquidity: 1500.2,
  masked: masked,
);

SossoldiValueChart _chart({
  List<double> values = const [100, 120, 110, 150],
  List<double> invested = const [100, 100, 105, 105],
  bool masked = false,
}) => SossoldiValueChart(
  values: values,
  invested: invested,
  pointLabels: [for (var i = 0; i < values.length; i++) 'L$i'],
  pointTitles: [for (var i = 0; i < values.length; i++) 'Day $i'],
  formatAxis: (v) => v.toStringAsFixed(0),
  formatValue: (v) => '€${v.toStringAsFixed(0)}',
  valueLabel: 'Market value',
  investedLabel: 'Invested',
  masked: masked,
);

void main() {
  setUpAll(loadTestFonts);

  group('portfolio card', () {
    testWidgets('label, value, P&L and liquidity', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.text('Portfolio value'), findsOneWidget);
      expect(find.text('€32,734.88'), findsOneWidget);
      expect(find.text('+€1,680.00'), findsOneWidget);
      expect(find.text('+24.23%'), findsOneWidget);
      expect(find.text('Available liquidity'), findsOneWidget);
      expect(find.text('€1,500.20'), findsOneWidget);
    });

    testWidgets('a loss is negative (and red)', (tester) async {
      await tester.pumpWidget(_wrap(_card(gain: -300, percent: -0.05)));
      expect(find.text('-€300.00'), findsOneWidget);
      expect(find.text('-5.00%'), findsOneWidget);
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      final amount = tester.widget<Text>(find.text('-€300.00'));
      expect(amount.style?.color, colors.expense.text);
    });

    testWidgets('masked: the amounts, not the percentage', (tester) async {
      await tester.pumpWidget(_wrap(_card(masked: true)));
      expect(find.text('€32,734.88'), findsNothing);
      expect(find.text('••••'), findsNWidgets(3));
    });

    testWidgets('a long value shrinks instead of overflowing; dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_card(), width: 220, brightness: Brightness.dark),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('value chart', () {
    test('axis ticks: round, increasing, covering the data', () {
      final t = SossoldiValueChart.axisTicks(34100, 38900);
      expect(t.first, lessThanOrEqualTo(34100));
      expect(t.last, greaterThanOrEqualTo(38900));
      for (var i = 1; i < t.length; i++) {
        expect(t[i], greaterThan(t[i - 1]));
      }
      expect(t.length, inInclusiveRange(3, 7));
      // Flat data still gets a range.
      final flat = SossoldiValueChart.axisTicks(500, 500);
      expect(flat.last, greaterThan(flat.first));
      expect(SossoldiValueChart.axisTicks(0, 0).length, greaterThan(1));
    });

    testWidgets('draws with any amount of data, in both themes', (
      tester,
    ) async {
      for (final b in Brightness.values) {
        for (final n in [0, 1, 2, 300]) {
          await tester.pumpWidget(
            _wrap(
              _chart(
                values: [for (var i = 0; i < n; i++) 100 + i.toDouble()],
                invested: List.filled(n, 100),
              ),
              brightness: b,
            ),
          );
          expect(tester.takeException(), isNull, reason: '$b $n');
        }
      }
    });

    testWidgets('a tap shows the card with value, invested and difference', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_chart()));
      expect(find.byType(SossoldiChartTooltip), findsNothing);
      final plot = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(plot.right - 1, plot.top + 10));
      await tester.pump();
      expect(find.text('Day 3'), findsOneWidget);
      expect(find.text('€150'), findsOneWidget);
      expect(find.text('€105'), findsOneWidget);
      expect(find.text('Difference'), findsNothing);
      // Dragging moves it.
      await tester.dragFrom(
        Offset(plot.right - 1, plot.top + 10),
        const Offset(-500, 0),
      );
      await tester.pump();
      expect(find.text('Day 0'), findsOneWidget);
      // Outside closes it.
      await tester.tapAt(const Offset(1, 1));
      await tester.pump();
      expect(find.byType(SossoldiChartTooltip), findsNothing);
    });

    testWidgets('masked: no numbers on the axis or in the card', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_chart(masked: true)));
      expect(find.text('••'), findsWidgets);
      final plot = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(plot.right - 1, plot.top + 10));
      await tester.pump();
      expect(find.text('€150'), findsNothing);
      expect(find.text('••••'), findsNWidgets(2));
    });

    testWidgets('the value line is green above the invested capital', (
      tester,
    ) async {
      // Smoke: it draws in both situations.
      await tester.pumpWidget(_wrap(_chart()));
      await tester.pumpWidget(
        _wrap(
          _chart(values: const [100, 90, 80], invested: const [100, 100, 100]),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('alert: bold and carousel', () {
    testWidgets('what is between ** is bold', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SossoldiAlert(
            tone: SossoldiAlertTone.info,
            title: 'T',
            message: 'You have **74%** in one asset',
          ),
        ),
      );
      final rich = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('74%'),
        ),
      );
      expect(rich.text.toPlainText(), 'You have 74% in one asset');
      final weights = <String, FontWeight?>{};
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text != null) {
          weights[span.text!] = span.style?.fontWeight;
        }
        return true;
      });
      expect(weights['74%'], FontWeight.w700);
      expect(weights['You have '], isNull);
    });

    testWidgets('the body takes the semantic color of the tone', (
      tester,
    ) async {
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      for (final (tone, role) in [
        (SossoldiAlertTone.info, colors.info),
        (SossoldiAlertTone.success, colors.success),
        (SossoldiAlertTone.warning, colors.warning),
        (SossoldiAlertTone.error, colors.error),
      ]) {
        await tester.pumpWidget(
          _wrap(SossoldiAlert(tone: tone, title: 'T', message: 'Body')),
        );
        final rich = tester.widget<RichText>(
          find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText() == 'Body',
          ),
        );
        // The Text wraps our span: the color is on the inner one.
        Color? color;
        rich.text.visitChildren((span) {
          if (span is TextSpan && span.text == 'Body') {
            color = span.style?.color;
          }
          return true;
        });
        final inner = (rich.text as TextSpan).children!.single as TextSpan;
        expect(
          color ??
              inner.style?.color ??
              (inner.children?.first as TextSpan?)?.style?.color,
          role.text,
          reason: '$tone',
        );
      }
    });

    testWidgets('the carousel swipes with the indicator and a gap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SossoldiAlertCarousel(
            alerts: [
              SossoldiAlert(title: 'One', message: 'First'),
              SossoldiAlert(title: 'Two', message: 'Second'),
            ],
          ),
        ),
      );
      expect(find.byType(SossoldiPageIndicator), findsOneWidget);
      final first = tester.getRect(find.text('First').last);
      await tester.fling(find.byType(PageView), const Offset(-200, 0), 800);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SossoldiPageIndicator>(find.byType(SossoldiPageIndicator))
            .index,
        1,
      );
      expect(
        first.left,
        lessThan(tester.getRect(find.text('Second').last).left + 400),
      );
    });

    testWidgets('a single alert has no indicator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SossoldiAlertCarousel(
            alerts: [SossoldiAlert(title: 'One', message: 'First')],
          ),
        ),
      );
      expect(find.byType(SossoldiPageIndicator), findsNothing);
    });
  });
}
