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

void main() {
  setUpAll(loadTestFonts);

  group('date range picker', () {
    Widget picker({
      DateTime? start,
      DateTime? end,
      required void Function(DateTime, DateTime?) onChanged,
      DateTime? first,
    }) => _wrap(
      SossoldiDateRangePicker(
        start: start,
        end: end,
        firstDate: first,
        lastDate: DateTime(2026, 10, 22),
        onChanged: onChanged,
        previousMonthSemanticLabel: 'Previous month',
        nextMonthSemanticLabel: 'Next month',
      ),
    );

    testWidgets('shows the month of the selection, all its days', (
      tester,
    ) async {
      await tester.pumpWidget(
        picker(
          start: DateTime(2026, 9, 3),
          end: DateTime(2026, 9, 9),
          onChanged: (_, _) {},
        ),
      );
      expect(find.text('September 2026'), findsOneWidget);
      for (var d = 1; d <= 30; d++) {
        expect(find.text('$d'), findsOneWidget, reason: 'day $d');
      }
      expect(find.text('31'), findsNothing);
    });

    testWidgets('first tap starts a range, second ends it', (tester) async {
      final calls = <(DateTime, DateTime?)>[];
      await tester.pumpWidget(picker(onChanged: (s, e) => calls.add((s, e))));
      await tester.tap(find.text('5'));
      expect(calls.last, (DateTime(2026, 10, 5), null));
    });

    testWidgets('the second tap closes the range, even backwards', (
      tester,
    ) async {
      final calls = <(DateTime, DateTime?)>[];
      await tester.pumpWidget(
        picker(
          start: DateTime(2026, 10, 10),
          onChanged: (s, e) => calls.add((s, e)),
        ),
      );
      await tester.tap(find.text('15'));
      expect(calls.last, (DateTime(2026, 10, 10), DateTime(2026, 10, 15)));
      await tester.tap(find.text('3'));
      expect(calls.last, (DateTime(2026, 10, 3), DateTime(2026, 10, 10)));
    });

    testWidgets('a tap with a finished range starts a new one', (tester) async {
      final calls = <(DateTime, DateTime?)>[];
      await tester.pumpWidget(
        picker(
          start: DateTime(2026, 10, 2),
          end: DateTime(2026, 10, 8),
          onChanged: (s, e) => calls.add((s, e)),
        ),
      );
      await tester.tap(find.text('12'));
      expect(calls.last, (DateTime(2026, 10, 12), null));
    });

    testWidgets('days after the last date cannot be picked', (tester) async {
      final calls = <(DateTime, DateTime?)>[];
      await tester.pumpWidget(picker(onChanged: (s, e) => calls.add((s, e))));
      await tester.tap(find.text('25'));
      expect(calls, isEmpty);
      await tester.tap(find.text('22'));
      expect(calls, hasLength(1));
    });

    testWidgets('month arrows move through months, next stops at the last', (
      tester,
    ) async {
      await tester.pumpWidget(picker(onChanged: (_, _) {}));
      expect(find.text('October 2026'), findsOneWidget);
      final next = find.byWidgetPredicate(
        (w) => w is SossoldiIconButton && w.semanticLabel == 'Next month',
      );
      expect(tester.widget<SossoldiIconButton>(next).onPressed, isNull);
      final previous = find.byWidgetPredicate(
        (w) => w is SossoldiIconButton && w.semanticLabel == 'Previous month',
      );
      await tester.tap(previous);
      await tester.pump();
      expect(find.text('September 2026'), findsOneWidget);
    });

    testWidgets('renders in dark mode without overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SossoldiDateRangePicker(
            start: DateTime(2026, 10, 3),
            end: DateTime(2026, 10, 12),
            lastDate: DateTime(2026, 10, 22),
            onChanged: (_, _) {},
            previousMonthSemanticLabel: 'p',
            nextMonthSemanticLabel: 'n',
          ),
          brightness: Brightness.dark,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('small finance components', () {
    testWidgets('filter button shows the dot only when active', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              SossoldiFilterButton(onPressed: null, semanticLabel: 'a'),
              SossoldiFilterButton(
                onPressed: null,
                semanticLabel: 'b',
                active: true,
              ),
            ],
          ),
        ),
      );
      Finder dots(int i) => find.descendant(
        of: find.byType(SossoldiFilterButton).at(i),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 10,
        ),
      );
      expect(dots(0), findsNothing);
      expect(dots(1), findsOneWidget);
    });

    testWidgets('day header: total chip is optional, colors follow sign', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              SossoldiDayHeader(title: 'Mon', total: '+ 10 €'),
              SossoldiDayHeader(title: 'Tue', total: '- 5 €', positive: false),
              SossoldiDayHeader(title: 'Wed'),
            ],
          ),
        ),
      );
      final chips = tester.widgetList<SossoldiChip>(find.byType(SossoldiChip));
      expect(chips.map((c) => c.type), [
        SossoldiChipType.income,
        SossoldiChipType.expense,
      ]);
      expect(find.text('Wed'), findsOneWidget);
    });

    testWidgets('day header truncates a long title', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 160,
            child: SossoldiDayHeader(title: 'A' * 80, total: '+ 1.790,01€'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state shows its button only with an action', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(
          SossoldiEmptyState(
            icon: Icons.search,
            title: 'Nothing',
            message: 'Try again',
            actionLabel: 'Clear',
            onAction: () => tapped++,
          ),
        ),
      );
      expect(find.text('Nothing'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      expect(tapped, 1);

      await tester.pumpWidget(
        _wrap(const SossoldiEmptyState(icon: Icons.search, title: 'Nothing')),
      );
      expect(find.byType(SossoldiButton), findsNothing);
    });
  });
}
