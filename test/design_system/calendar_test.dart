import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../load_test_fonts.dart';

Widget _wrap(
  Widget child, {
  Brightness brightness = Brightness.light,
  Locale? locale,
}) => MaterialApp(
  locale: locale,
  supportedLocales: const [Locale('en'), Locale('it')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: brightness == Brightness.dark
      ? SossoldiTheme.dark
      : SossoldiTheme.light,
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

final _oct = DateTime(2026, 10);
final _today = DateTime(2026, 10, 23);

SossoldiCalendar _calendar({
  DateTime? month,
  DateTime? selected,
  Map<int, Set<SossoldiCalendarDot>> dots = const {},
  ValueChanged<DateTime>? onTap,
}) => SossoldiCalendar(
  month: month ?? _oct,
  today: _today,
  selectedDay: selected,
  dots: dots,
  onDayTap: onTap ?? (_) {},
);

void main() {
  setUpAll(() async {
    await loadTestFonts();
    await initializeDateFormatting();
  });

  group('calendar', () {
    testWidgets('weeks start on Monday, names are localized', (tester) async {
      await tester.pumpWidget(_wrap(_calendar()));
      final names = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
      for (final n in names) {
        expect(find.text(n), findsOneWidget);
      }
      // Left to right: Mo comes before Su.
      expect(
        tester.getTopLeft(find.text('Mo')).dx,
        lessThan(tester.getTopLeft(find.text('Su')).dx),
      );
      await tester.pumpWidget(_wrap(_calendar(), locale: const Locale('it')));
      await tester.pumpAndSettle();
      expect(find.text('Lu'), findsOneWidget);
      expect(find.text('Do'), findsOneWidget);
    });

    testWidgets('the neighbouring months are dimmed and not tappable', (
      tester,
    ) async {
      final tapped = <DateTime>[];
      await tester.pumpWidget(_wrap(_calendar(onTap: tapped.add)));
      // October 2026 starts on a Thursday: 28, 29, 30 of September lead,
      // and November 1 closes the last row.
      final dimmed = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (t.style?.color ==
              SossoldiTheme.light.extension<SossoldiColors>()!.textLow)
            t.data,
      ];
      expect(dimmed, ['28', '29', '30', '1']);
      expect(find.byType(SossoldiTappable), findsNWidgets(31));
      await tester.tap(find.text('1').last, warnIfMissed: false);
      expect(tapped, isEmpty);
      await tester.tap(find.text('15'));
      expect(tapped, [DateTime(2026, 10, 15)]);
    });

    testWidgets('the number of rows follows the month', (tester) async {
      Future<double> heightOf(DateTime month) async {
        await tester.pumpWidget(_wrap(_calendar(month: month)));
        return tester.getSize(find.byType(SossoldiCalendar)).height;
      }

      final five = await heightOf(DateTime(2026, 10));
      final four = await heightOf(DateTime(2027, 2)); // 28 days from a Monday
      final six = await heightOf(DateTime(2027, 5)); // starts on a Saturday
      expect(five - four, closeTo(48, 0.01));
      expect(six - five, closeTo(48, 0.01));
    });

    testWidgets('dots: one per kind, several on the same day', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _calendar(
            dots: {
              1: {SossoldiCalendarDot.expense},
              2: {
                SossoldiCalendarDot.expense,
                SossoldiCalendarDot.income,
                SossoldiCalendarDot.transfer,
              },
              28: {SossoldiCalendarDot.transfer},
            },
          ),
        ),
      );
      expect(find.byKey(const ValueKey('dot-expense')), findsNWidgets(2));
      expect(find.byKey(const ValueKey('dot-income')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-transfer')), findsNWidgets(2));
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      Color colorOf(String kind) =>
          (tester
                      .widget<Container>(
                        find.byKey(ValueKey('dot-$kind')).first,
                      )
                      .decoration!
                  as BoxDecoration)
              .color!;
      expect(colorOf('expense'), colors.expense.stroke);
      expect(colorOf('income'), colors.income.stroke);
      expect(colorOf('transfer'), colors.info.stroke);
      // 6px dots.
      expect(
        tester.getSize(find.byKey(const ValueKey('dot-expense')).first),
        const Size(6, 6),
      );
    });

    testWidgets('dots of the days outside the month are not drawn', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _calendar(
            dots: {
              30: {SossoldiCalendarDot.expense},
            },
          ),
        ),
      );
      // Only the 30th of October has the dot, not the 30th of September.
      expect(find.byKey(const ValueKey('dot-expense')), findsOneWidget);
    });

    testWidgets('today is circled, the selected day is filled', (tester) async {
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      Finder circle(String day) => find
          .ancestor(of: find.text(day), matching: find.byType(Container))
          .first;
      BoxDecoration decoration(String day) =>
          tester.widget<Container>(circle(day)).decoration! as BoxDecoration;

      await tester.pumpWidget(
        _wrap(_calendar(selected: DateTime(2026, 10, 7))),
      );
      expect(decoration('23').border!.top.color, colors.primary.stroke);
      expect(decoration('23').shape, BoxShape.circle);
      expect(decoration('7').color, colors.primary.surface);
      expect(decoration('8').color, isNull);
      expect(decoration('8').border, isNull);
    });

    testWidgets('works in dark mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _calendar(
            selected: DateTime(2026, 10, 2),
            dots: {
              2: {SossoldiCalendarDot.expense},
            },
          ),
          brightness: Brightness.dark,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tap does nothing without a callback', (tester) async {
      await tester.pumpWidget(
        _wrap(SossoldiCalendar(month: _oct, today: _today)),
      );
      expect(find.byType(SossoldiTappable), findsNothing);
    });
  });

  group('month selector', () {
    testWidgets('arrows, label and tap', (tester) async {
      var prev = 0, next = 0, open = 0;
      await tester.pumpWidget(
        _wrap(
          SossoldiMonthSelector(
            month: _oct,
            onPrevious: () => prev++,
            onNext: () => next++,
            onTap: () => open++,
            previousSemanticLabel: 'Previous',
            nextSemanticLabel: 'Next',
            pickSemanticLabel: 'Pick',
          ),
        ),
      );
      expect(find.text('October 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Previous'));
      await tester.tap(find.bySemanticsLabel('Next'));
      await tester.tap(find.text('October 2026'));
      expect([prev, next, open], [1, 1, 1]);
    });

    testWidgets('a null callback disables the arrow', (tester) async {
      var next = 0;
      await tester.pumpWidget(
        _wrap(
          SossoldiMonthSelector(
            month: _oct,
            onPrevious: null,
            onNext: () => next++,
            onTap: () {},
            previousSemanticLabel: 'Previous',
            nextSemanticLabel: 'Next',
            pickSemanticLabel: 'Pick',
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Previous'), warnIfMissed: false);
      expect(next, 0);
    });
  });

  group('month picker', () {
    Future<DateTime?> open(
      WidgetTester tester, {
      int firstYear = 2021,
      int lastYear = 2031,
      Brightness brightness = Brightness.light,
    }) async {
      DateTime? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showSossoldiMonthPicker(
                  context: context,
                  selected: DateTime(2026, 10),
                  firstYear: firstYear,
                  lastYear: lastYear,
                  title: 'Select month',
                  closeSemanticLabel: 'Close',
                  previousYearSemanticLabel: 'Prev year',
                  nextYearSemanticLabel: 'Next year',
                );
              },
              child: const Text('open'),
            ),
          ),
          brightness: brightness,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('twelve months, current year, pick returns the first day', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('2026'), findsOneWidget);
      for (final m in [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
      ]) {
        expect(find.text(m), findsOneWidget);
      }
      await tester.tap(find.bySemanticsLabel('Next year'));
      await tester.pump();
      expect(find.text('2027'), findsOneWidget);
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(find.text('Select month'), findsNothing);
    });

    testWidgets('the year stops at the limits', (tester) async {
      await open(tester, firstYear: 2026, lastYear: 2026);
      expect(find.text('2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next year'), warnIfMissed: false);
      await tester.tap(find.bySemanticsLabel('Prev year'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('2026'), findsOneWidget);
    });

    testWidgets('closes without a result and works in dark mode', (
      tester,
    ) async {
      await open(tester, brightness: Brightness.dark);
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Select month'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
