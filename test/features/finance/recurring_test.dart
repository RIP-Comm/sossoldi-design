import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';
import 'package:sossoldi/features/finance/recurring/recurring_detail_screen.dart';
import 'package:sossoldi/features/transactions/transaction_detail_screen.dart';
import 'package:sossoldi/features/finance/recurring/recurring_item.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

class _Harness {
  _Harness(this.state, this.finance);
  final AppState state;
  final FinanceController finance;
  MockRepository get repo => state.repository;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 3000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: MockRepository(now: _now));
  final finance = FinanceController(state.repository)
    ..selectTab(FinanceTab.recurring);
  addTearDown(finance.dispose);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          theme: brightness == Brightness.dark
              ? SossoldiTheme.dark
              : SossoldiTheme.light,
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FinanceScreen(controller: finance)),
        ),
      ),
    ),
  );
  await tester.pump();
  return _Harness(state, finance);
}

Finder _item(String description) =>
    find.widgetWithText(RecurringItem, description);

/// The descriptions of the rows of the list, top to bottom.
List<String> _rows(WidgetTester tester) => [
  for (final w in tester.widgetList<RecurringItem>(find.byType(RecurringItem)))
    w.description,
];

Finder _day(String n) =>
    find.descendant(of: find.byType(SossoldiCalendar), matching: find.text(n));

Future<void> _openDetail(WidgetTester tester, String description) async {
  await tester.tap(_item(description).first);
  await tester.pumpAndSettle();
}

Future<void> _edit(WidgetTester tester) async {
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
}

Finder get _amountInput => find.descendant(
  of: find.byType(SossoldiTextInput),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(loadTestFonts);

  group('Recurring tab', () {
    testWidgets('current month, calendar and the whole month by date', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.byType(SossoldiCalendar), findsOneWidget);
      final rows = _rows(tester);
      final dates = [
        for (final w in tester.widgetList<RecurringItem>(
          find.byType(RecurringItem),
        ))
          w.date,
      ];
      expect(rows, isNotEmpty);
      expect(dates, [...dates]..sort());
      expect(
        rows.length,
        h.repo.recurringOccurrences(2026, 10).length,
        reason: 'every date of the month',
      );
      expect(find.text('Add recurrent transaction'), findsOneWidget);
    });

    testWidgets('the dots of the calendar follow the occurrences', (
      tester,
    ) async {
      final h = await _pump(tester);
      final types = h.repo.recurringDayTypes(2026, 10);
      final expenses = types.values
          .where((s) => s.any((t) => t.name == 'expense'))
          .length;
      final incomes = types.values
          .where((s) => s.any((t) => t.name == 'income'))
          .length;
      final transfers = types.values
          .where((s) => s.any((t) => t.name == 'transfer'))
          .length;
      expect(
        find.byKey(const ValueKey('dot-expense')),
        findsNWidgets(expenses),
      );
      expect(find.byKey(const ValueKey('dot-income')), findsNWidgets(incomes));
      expect(
        find.byKey(const ValueKey('dot-transfer')),
        findsNWidgets(transfers),
      );
    });

    testWidgets('a paused recurrence is not listed', (tester) async {
      await _pump(tester);
      expect(_item('Disney+'), findsNothing);
    });

    testWidgets('tap a day: only that day; again: the whole month', (
      tester,
    ) async {
      final h = await _pump(tester);
      final all = _rows(tester);
      await tester.tap(_day('27'));
      await tester.pump();
      expect(_rows(tester), ['Salary']);
      expect(
        find.byKey(const ValueKey('dot-income')),
        findsOneWidget,
        reason: 'dots stay',
      );
      expect(h.finance.recurring.selectedDay, DateTime(2026, 10, 27));
      await tester.tap(_day('27'));
      await tester.pump();
      expect(_rows(tester), all);
      expect(h.finance.recurring.selectedDay, isNull);
    });

    testWidgets('a day with two kinds lists both', (tester) async {
      await _pump(tester);
      await tester.tap(_day('2'));
      await tester.pump();
      expect(
        _rows(tester).toSet(),
        containsAll(['Cleaning service', 'Investment contribution']),
      );
    });

    testWidgets('a day without recurrences: empty state, Add stays', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(_day('24'));
      await tester.pump();
      expect(_rows(tester), isEmpty);
      expect(find.text('Nothing on this day'), findsOneWidget);
      expect(find.text('Add recurrent transaction'), findsOneWidget);
    });

    testWidgets('the days of the neighbouring months do nothing', (
      tester,
    ) async {
      final h = await _pump(tester);
      // The first 30 is September's (leading cell), the second October's.
      await tester.tap(_day('30').first, warnIfMissed: false);
      await tester.pump();
      expect(h.finance.recurring.selectedDay, isNull);
    });

    testWidgets('months: arrows, past and future, selection cleared', (
      tester,
    ) async {
      final h = await _pump(tester);
      await tester.tap(_day('27'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
      expect(h.finance.recurring.selectedDay, isNull);
      expect(
        _rows(tester).length,
        h.repo.recurringOccurrences(2026, 11).length,
      );
      // Salary on the 27th, still planned.
      expect(_item('Salary'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump();
      expect(find.text('September 2026'), findsOneWidget);
      expect(_rows(tester).length, h.repo.recurringOccurrences(2026, 9).length);
    });

    testWidgets('the picker jumps to another month and year', (tester) async {
      final h = await _pump(tester);
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Next year'));
      await tester.pump();
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(find.text('March 2027'), findsOneWidget);
      expect(h.finance.recurring.month, DateTime(2027, 3));
      // A month with no yearly or quarterly: monthly ones are still there.
      expect(_item('Rent'), findsOneWidget);
    });

    testWidgets('the month is kept when changing tab', (tester) async {
      final h = await _pump(tester);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      h.finance.selectTab(FinanceTab.budget);
      await tester.pump();
      h.finance.selectTab(FinanceTab.recurring);
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
    });

    testWidgets('the date chip is blue for what is to come, grey after', (
      tester,
    ) async {
      await _pump(tester);
      SossoldiChipType typeOf(String label) => tester
          .widget<SossoldiChip>(find.widgetWithText(SossoldiChip, label))
          .type;
      expect(typeOf('1st October'), SossoldiChipType.subtle);
      expect(typeOf('27th October'), SossoldiChipType.info);
    });

    testWidgets('Add recurrent transaction opens the Add sheet, recurring on', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('Add recurrent transaction'));
      await tester.pumpAndSettle();
      expect(find.text('New transaction'), findsOneWidget);
      expect(find.text('Frequency'), findsOneWidget);
    });

    testWidgets('hidden amounts', (tester) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.textContaining('2.150'), findsNothing);
      expect(find.textContaining('••••'), findsWidgets);
    });

    testWidgets('Italian, dark mode', (tester) async {
      await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      expect(find.text('Ottobre 2026'), findsOneWidget);
      expect(find.text('Lu'), findsOneWidget);
      expect(find.text('27 ottobre'), findsOneWidget);
      expect(find.text('Aggiungi transazione ricorrente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a month with nothing', (tester) async {
      final h = await _pump(tester);
      // Remove every recurrence: the list of the month is empty.
      for (final r in List.of(h.repo.recurringTransactions())) {
        h.repo.deleteRecurring(r.id);
      }
      await tester.pump();
      expect(_rows(tester), isEmpty);
      expect(find.text('No recurring transactions this month'), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-expense')), findsNothing);
    });
  });

  group('Recurring page', () {
    testWidgets('read-only details and the old transactions', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Salary');
      expect(find.byType(RecurringDetailScreen), findsOneWidget);
      // No title above the box; the period and status are chips.
      expect(find.text('Details'), findsNothing);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      // The amount is in the box, and again in each old transaction.
      expect(find.textContaining('2,150.00'), findsWidgets);
      expect(find.text('Old transactions'), findsOneWidget);
      expect(find.text('Last 6 months'), findsOneWidget);
      expect(find.text('Delete recurrence'), findsNothing);
      // No fields until Edit.
      expect(find.byType(TextField), findsNothing);
      final groups = h.repo.recurringHistory('rec_salary');
      expect(find.text('${groups.first.year}'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RecurringDetailScreen),
          matching: find.byType(RecurringItem),
        ),
        findsNWidgets(groups.fold(0, (s, g) => s + g.transactions.length)),
      );
      expect(find.byType(SossoldiSwitch), findsNothing);
    });

    testWidgets('an old transaction opens its own page', (tester) async {
      await _pump(tester);
      await _openDetail(tester, 'Rent');
      await tester.tap(
        find
            .descendant(
              of: find.byType(RecurringDetailScreen),
              matching: find.byType(RecurringItem),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
      expect(find.text('Show recurrence'), findsOneWidget);
    });

    testWidgets('the time range changes the list', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Rent');
      int rows() => tester
          .widgetList(
            find.descendant(
              of: find.byType(RecurringDetailScreen),
              matching: find.byType(RecurringItem),
            ),
          )
          .length;
      expect(rows(), 6);
      await tester.tap(find.text('Last 6 months'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 3 months'));
      await tester.pumpAndSettle();
      expect(rows(), 3);
      await tester.tap(find.text('Last 3 months'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(
        rows(),
        h.repo.transactions.where((t) => t.recurringId == 'rec_rent').length,
      );
    });

    testWidgets('the year total chip is red for expenses', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Rent');
      final total = h.repo.recurringHistory('rec_rent').first.total;
      expect(total, lessThan(0));
      final chip = tester.widget<SossoldiChip>(
        find.byWidgetPredicate(
          (w) => w is SossoldiChip && w.type == SossoldiChipType.expense,
        ),
      );
      expect(chip.label, contains('5,100.00'));
    });

    testWidgets('Edit makes the fields editable, Done saves', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete recurrence'), findsOneWidget);
      expect(tester.widget<TextField>(_amountInput).enabled, isTrue);
      // The currency sits at the end of the field; no helper text.
      expect(find.text('€'), findsOneWidget);
      expect(find.text('Amounts in EUR'), findsNothing);
      expect(
        tester.widget<SossoldiSwitch>(find.byType(SossoldiSwitch)).onChanged,
        isNotNull,
      );
      await tester.enterText(_amountInput, '12,50');
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.recurring('rec_spotify').amount, 12.5);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete recurrence'), findsNothing);
      expect(find.textContaining('12.50'), findsOneWidget);
    });

    testWidgets('an invalid amount is not saved', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      for (final (text, message) in [
        ('', 'Enter an amount.'),
        ('abc', 'Enter an amount.'),
        ('0', 'The amount must be greater than zero.'),
        ('-4', 'The amount must be greater than zero.'),
      ]) {
        await tester.enterText(_amountInput, text);
        await tester.tap(find.text('Done'));
        await tester.pump();
        expect(find.text(message), findsOneWidget, reason: '"$text"');
        expect(find.text('Done'), findsOneWidget, reason: 'still editing');
      }
      expect(h.repo.recurring('rec_spotify').amount, 10.99);
    });

    testWidgets('a tap outside the field closes the keyboard and checks it', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      await tester.tap(_amountInput);
      await tester.pump();
      expect(
        tester.widget<TextField>(_amountInput).focusNode?.hasFocus,
        isTrue,
      );
      await tester.enterText(_amountInput, '0');
      await tester.tap(find.text('Details'));
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.widget is EditableText,
        isFalse,
      );
      expect(
        find.text('The amount must be greater than zero.'),
        findsOneWidget,
      );
      // A valid amount: no error, still editing, saved with Done.
      await tester.enterText(_amountInput, '15');
      await tester.tap(find.text('Details'));
      await tester.pump();
      expect(find.text('The amount must be greater than zero.'), findsNothing);
      expect(find.text('Done'), findsOneWidget);
      expect(h.repo.recurring('rec_spotify').amount, 10.99);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.recurring('rec_spotify').amount, 15);
    });

    testWidgets('Cancel forgets the changes', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      await tester.enterText(_amountInput, '99');
      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(h.repo.recurring('rec_spotify').amount, 10.99);
      expect(h.repo.recurring('rec_spotify').status, RecurringStatus.active);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('pausing removes the future dates from the calendar', (
      tester,
    ) async {
      final h = await _pump(tester);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(_item('Spotify'), findsOneWidget);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pump();
      expect(
        tester.widget<SossoldiSwitch>(find.byType(SossoldiSwitch)).value,
        isFalse,
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.recurring('rec_spotify').status, RecurringStatus.paused);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      expect(_item('Spotify'), findsNothing);
      // October's already happened.
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump();
      expect(_item('Spotify'), findsOneWidget);
    });

    testWidgets('a new frequency changes which months have it', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Gym membership');
      await _edit(tester);
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yearly').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.recurring('rec_gym').frequency, RecurrenceFrequency.yearly);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      // November 5th is the next date; December has none.
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(_item('Gym membership'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(_item('Gym membership'), findsNothing);
    });

    testWidgets('Delete asks first; cancel keeps it', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Netflix');
      await _edit(tester);
      await tester.tap(find.text('Delete recurrence'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this recurring transaction?'), findsOneWidget);
      expect(
        find.text(
          'Netflix will not repeat any more. The transactions already '
          'recorded are kept.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(find.byType(RecurringDetailScreen), findsOneWidget);
      expect(
        h.repo.recurringTransactions().any((r) => r.id == 'rec_netflix'),
        isTrue,
      );
    });

    testWidgets('Delete removes it from the calendar and the list', (
      tester,
    ) async {
      final h = await _pump(tester);
      final before = _rows(tester).length;
      final transactions = h.repo.transactions.length;
      await _openDetail(tester, 'Netflix');
      await _edit(tester);
      await tester.tap(find.text('Delete recurrence'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.byType(RecurringDetailScreen), findsNothing);
      expect(_item('Netflix'), findsNothing);
      expect(_rows(tester).length, lessThan(before));
      expect(h.repo.transactions.length, transactions);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(_item('Netflix'), findsNothing);
    });

    testWidgets('Back while editing leaves edit mode first', (tester) async {
      await _pump(tester);
      await _openDetail(tester, 'Spotify');
      await _edit(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(RecurringDetailScreen), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(RecurringDetailScreen), findsNothing);
    });

    testWidgets('hidden amounts and Italian dark mode', (tester) async {
      final h = await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      h.state.toggleHideAmounts();
      await tester.pump();
      await _openDetail(tester, 'Salary');
      expect(find.text('Dettagli'), findsNothing);
      expect(find.text('Mensile'), findsOneWidget);
      expect(find.text('Transazioni passate'), findsOneWidget);
      expect(find.text('Ultimi 6 mesi'), findsOneWidget);
      expect(find.textContaining('2.150'), findsNothing);
      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();
      expect(find.text('Elimina ricorrenza'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
