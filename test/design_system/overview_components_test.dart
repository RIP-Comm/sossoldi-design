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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: 358, child: child),
        ),
      ),
    );

SossoldiCashFlowChart _chart({
  List<double> income = const [0, 100, 100],
  List<double> expenses = const [20, 50, 300],
  List<double> balance = const [-20, 50, -200],
  int length = 31,
  bool masked = false,
}) => SossoldiCashFlowChart(
  income: income,
  expenses: expenses,
  balance: balance,
  length: length,
  xLabels: [for (var i = 1; i <= length; i++) 'D$i'],
  formatAxis: (v) => v.toStringAsFixed(0),
  pointTitles: [for (var i = 1; i <= length; i++) 'Day $i'],
  formatValue: (v) => '€${v.toStringAsFixed(0)}',
  incomeLabel: 'Income',
  expenseLabel: 'Expense',
  balanceLabel: 'Balance',
  masked: masked,
);

void main() {
  setUpAll(loadTestFonts);

  group('alert tone', () {
    testWidgets('each tone fills and outlines with its state color', (
      tester,
    ) async {
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      final roles = {
        SossoldiAlertTone.info: colors.info,
        SossoldiAlertTone.success: colors.success,
        SossoldiAlertTone.warning: colors.warning,
        SossoldiAlertTone.error: colors.error,
      };
      for (final e in roles.entries) {
        await tester.pumpWidget(
          _wrap(SossoldiAlert(tone: e.key, title: 'T', message: 'M')),
        );
        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SossoldiAlert),
                matching: find.byType(Container),
              )
              .first,
        );
        final d = box.decoration! as ShapeDecoration;
        expect(d.color, e.value.surface, reason: '${e.key}');
        expect(
          (d.shape as RoundedSuperellipseBorder).side.color,
          e.value.stroke,
        );
      }
    });

    testWidgets('neutral is unchanged: white, no border', (tester) async {
      await tester.pumpWidget(_wrap(const SossoldiAlert(message: 'M')));
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SossoldiAlert),
              matching: find.byType(Container),
            )
            .first,
      );
      final d = box.decoration! as ShapeDecoration;
      expect(
        d.color,
        SossoldiTheme.light.extension<SossoldiColors>()!.surfaceHigh,
      );
      expect((d.shape as RoundedSuperellipseBorder).side, BorderSide.none);
    });
  });

  group('cash flow chart', () {
    test('axis ticks are round and include zero', () {
      final t = SossoldiCashFlowChart.axisTicks(-1730, 420);
      expect(t, contains(0));
      expect(t.first, lessThanOrEqualTo(-1730));
      expect(t.last, greaterThanOrEqualTo(420));
      final step = t[1] - t[0];
      for (var i = 1; i < t.length; i++) {
        expect(t[i] - t[i - 1], closeTo(step, 1e-9));
      }
      expect(SossoldiCashFlowChart.axisTicks(0, 0), [-1, 0, 1]);
      expect(SossoldiCashFlowChart.axisTicks(-3, 0).contains(0), isTrue);
    });

    testWidgets('draws in both themes, with any amount of data', (
      tester,
    ) async {
      for (final b in Brightness.values) {
        for (final n in [0, 1, 2, 31]) {
          await tester.pumpWidget(
            _wrap(
              _chart(
                income: List.filled(n, 5),
                expenses: List.filled(n, 7),
                balance: List.filled(n, -2),
              ),
              brightness: b,
            ),
          );
          expect(tester.takeException(), isNull, reason: '$b $n');
        }
      }
    });

    testWidgets('a tap shows the day with income, expense and balance', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_chart()));
      expect(find.byType(SossoldiChartTooltip), findsNothing);
      final plot = tester.getTopLeft(find.byType(CustomPaint).last);
      final box = tester.getSize(find.byType(CustomPaint).last);
      // Halfway along the 31 days: day 16, past the 3 days of data.
      await tester.tapAt(plot + Offset(box.width * 2 / 30, 10));
      await tester.pump();
      expect(find.byType(SossoldiChartTooltip), findsOneWidget);
      expect(find.text('Day 3'), findsOneWidget);
      expect(find.text('€100'), findsOneWidget); // income
      expect(find.text('€300'), findsOneWidget); // expense
      expect(find.text('€-200'), findsOneWidget); // balance
      // A tap past the last day of data shows the last day.
      await tester.tapAt(plot + Offset(box.width * 0.9, 10));
      await tester.pump();
      expect(find.text('Day 3'), findsOneWidget);
      // Outside: it goes away.
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      expect(find.byType(SossoldiChartTooltip), findsNothing);
    });

    testWidgets('the amounts in the card are hidden when masked', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_chart(masked: true)));
      final plot = tester.getTopLeft(find.byType(CustomPaint).last);
      await tester.tapAt(plot + const Offset(5, 10));
      await tester.pump();
      expect(find.text('••••'), findsNWidgets(3));
    });

    testWidgets('X labels at the ends, Y axis numbers; masked hides them', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_chart()));
      expect(find.text('D1'), findsOneWidget);
      expect(find.text('D31'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      await tester.pumpWidget(_wrap(_chart(masked: true)));
      expect(find.text('••'), findsWidgets);
    });
  });

  group('budget card', () {
    testWidgets('title, figures and bar; exceeded has the error chip', (
      tester,
    ) async {
      SossoldiBudgetItem item(SossoldiBudgetTone tone) => SossoldiBudgetItem(
        card: true,
        title: 'Groceries',
        percent: '126%',
        remaining: '34,62 € over',
        tone: tone,
        bar: const SossoldiBudgetBar(
          value: 1,
          color: Colors.blue,
          trackColor: Colors.grey,
        ),
      );
      await tester.pumpWidget(_wrap(item(SossoldiBudgetTone.ok)));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.byType(SossoldiChip), findsNothing);
      await tester.pumpWidget(_wrap(item(SossoldiBudgetTone.exceeded)));
      expect(
        tester.widget<SossoldiChip>(find.byType(SossoldiChip)).type,
        SossoldiChipType.error,
      );
    });

    testWidgets('a narrow 160px card with long text does not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SossoldiTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 160,
              child: SossoldiBudgetItem(
                card: true,
                title: 'A category with a really long name · Monthly',
                percent: '1234%',
                remaining: '123.456.789,00 € over',
                tone: SossoldiBudgetTone.exceeded,
                bar: const SossoldiBudgetBar(
                  value: 1,
                  color: Colors.blue,
                  trackColor: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
