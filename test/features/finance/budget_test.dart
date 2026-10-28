import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/budget/budget_detail_screen.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';
import 'package:sossoldi/features/finance/transactions/transaction_filters_sheet.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/budget_status.dart';
import 'package:sossoldi/mock/models/category_edit.dart';

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
  // Tall, so that the whole page is on screen without scrolling.
  Size size = const Size(390, 2400),
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
    ..selectTab(FinanceTab.budget);
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

Finder _row(String category) =>
    find.widgetWithText(SossoldiBudgetItem, category);

Future<void> _openDetail(WidgetTester tester, String category) async {
  await tester.tap(_row(category));
  await tester.pumpAndSettle();
}

/// The amount field of the edit mode (the search bar is another TextField).
Finder get _amountInput => find.descendant(
  of: find.byType(SossoldiTextInput),
  matching: find.byType(TextField),
);

Future<void> _pickPeriod(
  WidgetTester tester,
  String current,
  String next,
) async {
  await tester.tap(find.text(current));
  await tester.pumpAndSettle();
  await tester.tap(find.text(next).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  group('the Budget tab', () {
    testWidgets('Monthly is selected, with the overall budget and the list', (
      tester,
    ) async {
      final h = await _pump(tester);
      final o = h.repo.budgetOverview(BudgetPeriod.monthly);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Overall budget'), findsOneWidget);
      expect(find.text('Categories breakdown'), findsOneWidget);
      // The overall card plus one row per budget.
      expect(
        find.byType(SossoldiBudgetItem),
        findsNWidgets(1 + o.items.length),
      );
      // The segmented bar of the total is hidden (its code is commented).
      expect(find.byType(SossoldiSegmentedBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the overall budget counts only the budgets that count, and '
        'goes away when none does', (tester) async {
      final h = await _pump(tester);
      final monthly = h.repo.budgets
          .where((b) => b.period == BudgetPeriod.monthly)
          .toList();
      void count(Budget b, bool value) => h.repo.updateBudget(
        b.id,
        BudgetDraft(
          period: b.period,
          amount: h.repo.toMain(b.amount, b.currency),
          countForOverall: value,
        ),
      );

      count(monthly.first, false);
      await tester.pump();
      var o = h.repo.budgetOverview(BudgetPeriod.monthly);
      expect(o.overallCount, monthly.length - 1);
      var overall = tester.widget<SossoldiBudgetItem>(
        find.widgetWithText(SossoldiBudgetItem, 'Overall budget'),
      );
      expect(overall.percent, '${(o.overallUsage * 100).round()}%');
      // The list still has every budget of the period.
      expect(
        find.byType(SossoldiBudgetItem),
        findsNWidgets(1 + monthly.length),
      );

      for (final b in monthly.skip(1)) {
        count(b, false);
      }
      await tester.pump();
      expect(find.text('Overall budget'), findsNothing);
      expect(find.byType(SossoldiBudgetItem), findsNWidgets(monthly.length));
      expect(find.text('Categories breakdown'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('overall figures come from the repository', (tester) async {
      final h = await _pump(tester);
      final o = h.repo.budgetOverview(BudgetPeriod.monthly);
      final overall = tester.widget<SossoldiBudgetItem>(
        find.widgetWithText(SossoldiBudgetItem, 'Overall budget'),
      );
      expect(overall.prominent, isTrue);
      expect(overall.percent, '${(o.usage * 100).round()}%');
      expect(overall.tone, switch (o.state) {
        BudgetState.ok => SossoldiBudgetTone.ok,
        BudgetState.warning => SossoldiBudgetTone.warning,
        BudgetState.exceeded => SossoldiBudgetTone.exceeded,
      });
      expect(overall.remaining, contains(o.overBy > 0 ? 'over' : 'left'));
    });

    testWidgets('rows are the category names, largest budget first', (
      tester,
    ) async {
      final h = await _pump(tester);
      final o = h.repo.budgetOverview(BudgetPeriod.monthly);
      final rows = tester
          .widgetList<SossoldiBudgetItem>(find.byType(SossoldiBudgetItem))
          .skip(1)
          .map((r) => r.title)
          .toList();
      expect(rows, [
        for (final s in o.items) h.repo.category(s.budget.categoryId).name,
      ]);
    });

    testWidgets('each row shows its own percentage, tone and bar', (
      tester,
    ) async {
      final h = await _pump(tester);
      final o = h.repo.budgetOverview(BudgetPeriod.monthly);
      final items = tester
          .widgetList<SossoldiBudgetItem>(find.byType(SossoldiBudgetItem))
          .skip(1)
          .toList();
      for (final (i, s) in o.items.indexed) {
        expect(items[i].percent, '${(s.usage * 100).round()}%');
        expect(
          items[i].tone,
          SossoldiBudgetTone.values[s.state.index],
          reason: s.budget.id,
        );
        final bar = items[i].bar as SossoldiBudgetBar;
        expect(bar.value, closeTo(s.usage, 1e-9));
        // No outline on the bars of the categories, even when exceeded.
        expect(bar.exceeded, isFalse);
        expect(bar.color, h.repo.category(s.budget.categoryId).color.main);
      }
    });

    testWidgets('other periods show their own budgets', (tester) async {
      final h = await _pump(tester);
      await _pickPeriod(tester, 'Monthly', 'Weekly');
      expect(h.finance.budgetPeriod, BudgetPeriod.weekly);
      final o = h.repo.budgetOverview(BudgetPeriod.weekly);
      expect(
        find.byType(SossoldiBudgetItem),
        findsNWidgets(1 + o.items.length),
      );

      await _pickPeriod(tester, 'Weekly', 'Quarterly');
      expect(find.byType(SossoldiBudgetItem), findsNWidgets(1 + 1));
      expect(_row('Health'), findsOneWidget);

      await _pickPeriod(tester, 'Quarterly', 'Yearly');
      expect(_row('Education'), findsOneWidget);
    });

    testWidgets('a period without budgets shows the empty state', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _pickPeriod(tester, 'Monthly', 'Semiannual');
      expect(h.finance.budgetPeriod, BudgetPeriod.semiannual);
      expect(find.text('No budgets for this period'), findsOneWidget);
      expect(
        find.text('You will be able to add budgets from Settings.'),
        findsOneWidget,
      );
      expect(find.byType(SossoldiBudgetItem), findsNothing);
      expect(find.byType(SossoldiSegmentedBar), findsNothing);
      // The select is still there: there is always a period selected.
      expect(find.text('Semiannual'), findsOneWidget);
    });

    testWidgets('an exceeded category shows its percentage in an error chip', (
      tester,
    ) async {
      final h = await _pump(tester);
      final o = h.repo.budgetOverview(BudgetPeriod.monthly);
      for (final s in o.items) {
        final name = h.repo.category(s.budget.categoryId).name;
        final chips = find.descendant(
          of: _row(name),
          matching: find.byType(SossoldiChip),
        );
        if (s.state == BudgetState.exceeded) {
          final chip = tester.widget<SossoldiChip>(chips);
          expect(chip.type, SossoldiChipType.error, reason: name);
          expect(chip.label, '${(s.usage * 100).round()}%');
        } else {
          expect(chips, findsNothing, reason: name);
        }
      }
      // The overall card keeps its plain figure.
      expect(
        find.descendant(
          of: find.widgetWithText(SossoldiBudgetItem, 'Overall budget'),
          matching: find.byType(SossoldiChip),
        ),
        findsNothing,
      );
    });

    testWidgets('the period is kept while moving between tabs', (tester) async {
      final h = await _pump(tester);
      await _pickPeriod(tester, 'Monthly', 'Yearly');
      await tester.tap(find.text('Overview'));
      await tester.pump();
      await tester.tap(find.text('Budget'));
      await tester.pump();
      expect(h.finance.budgetPeriod, BudgetPeriod.yearly);
      expect(find.text('Yearly'), findsOneWidget);
    });

    testWidgets('hidden amounts: figures masked, percentages stay', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      final items = tester.widgetList<SossoldiBudgetItem>(
        find.byType(SossoldiBudgetItem),
      );
      for (final item in items) {
        expect(item.remaining, contains('••••'));
        expect(item.remaining, isNot(matches(RegExp(r'\d'))));
        expect(item.percent, matches(RegExp(r'^\d+%$')));
      }
    });

    testWidgets('amounts follow the main currency', (tester) async {
      final h = await _pump(tester);
      h.state.setMainCurrency('USD');
      await tester.pump();
      final overall = tester.widget<SossoldiBudgetItem>(
        find.widgetWithText(SossoldiBudgetItem, 'Overall budget'),
      );
      expect(overall.remaining, contains(r'$'));
      expect(overall.remaining, isNot(contains('€')));
    });

    testWidgets('Italian: texts are translated', (tester) async {
      final h = await _pump(tester, locale: const Locale('it'));
      expect(find.text('Mensile'), findsOneWidget);
      expect(find.text('Budget totale'), findsOneWidget);
      expect(find.text('Ripartizione per categoria'), findsOneWidget);
      final items = tester.widgetList<SossoldiBudgetItem>(
        find.byType(SossoldiBudgetItem),
      );
      expect(items.any((i) => i.remaining.contains('rimasti')), isTrue);
      expect(h.finance.tab, FinanceTab.budget);
    });

    testWidgets('dark mode and a small phone', (tester) async {
      await _pump(
        tester,
        brightness: Brightness.dark,
        size: const Size(320, 2400),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('the budget page', () {
    testWidgets('opens the budget that was tapped', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Transport');
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
      // The toolbar: Back, the category, Edit.
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Transport'), findsWidgets);
      // The budget card is titled with its period.
      expect(find.text('Budget'), findsWidgets);
      expect(find.text('Expenses'), findsOneWidget);
      expect(h.repo.budgetsForCategory('cat_transport'), hasLength(1));
    });

    testWidgets('shows only that budget: no other budgets, no "Add budget"', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Leisure');
      expect(find.byType(SossoldiBudgetItem), findsOneWidget);
      expect(find.text('Add budget'), findsNothing);
      expect(find.textContaining('Add budget'), findsNothing);
    });

    testWidgets('the card matches the repository status', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Transport');
      final budget = h.repo.budgetsForCategory('cat_transport').single;
      final status = h.repo.budgetStatus(budget);
      final item = tester.widget<SossoldiBudgetItem>(
        find.byType(SossoldiBudgetItem),
      );
      expect(item.title, 'Monthly');
      expect(item.percent, '${(status.usage * 100).round()}%');
      expect(item.tone, SossoldiBudgetTone.exceeded);
      expect(item.remaining, contains('over'));
    });

    testWidgets('its expenses add up to what is spent, grouped by day', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Transport');
      final budget = h.repo.budgetsForCategory('cat_transport').single;
      final status = h.repo.budgetStatus(budget);
      final filter = h.repo.budgetTransactionFilter(budget.id);
      final page = h.repo.searchTransactions(filter);
      expect(find.byType(SossoldiDayHeader), findsWidgets);
      expect(
        -page.netByDay.values.fold(0.0, (a, b) => a + b),
        closeTo(status.spent, 0.02),
      );
      // Only expenses of that category.
      expect(page.items.every((t) => t.categoryId == 'cat_transport'), isTrue);
      expect(page.items, isNotEmpty);
    });

    testWidgets('search narrows the expenses; no result gives an empty state', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Transport');
      final before = tester
          .widgetList(find.byType(SossoldiTransactionItem))
          .length;
      await tester.enterText(find.byType(TextField), 'zzzzqq');
      await tester.pump();
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.byType(SossoldiTransactionItem), findsNothing);
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(
        tester.widgetList(find.byType(SossoldiTransactionItem)).length,
        before,
      );
    });

    testWidgets('the filters are only account and amount', (tester) async {
      await _pump(tester);
      await _openDetail(tester, 'Transport');
      await tester.tap(find.byType(SossoldiFilterButton));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Date'), findsNothing);
      expect(find.text('Type'), findsNothing);
      expect(find.text('Category'), findsNothing);
    });

    testWidgets('an amount filter applies, shows a chip, and the dot', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Transport');
      await tester.tap(find.byType(SossoldiFilterButton));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(TransactionFiltersSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(1), '1000');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Amount:', findRichText: true),
        findsOneWidget,
      );
      expect(find.byType(SossoldiFilterChip), findsOneWidget);
      expect(
        tester
            .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
            .active,
        isTrue,
      );
      // Only expenses of 1000 or less are listed.
      final page = h.repo.searchTransactions(
        h.repo
            .budgetTransactionFilter(
              h.repo.budgetsForCategory('cat_transport').single.id,
            )
            .withAmountRange(null, 1000),
      );
      expect(
        tester.widgetList(find.byType(SossoldiTransactionItem)).length,
        page.items.length,
      );
    });
  });

  group('editing', () {
    Future<void> startEditing(WidgetTester tester, String category) async {
      await _openDetail(tester, category);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
    }

    testWidgets('Edit makes the amount editable and Done/Cancel appear', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Transport');
      expect(find.byType(SossoldiTextInput), findsNothing);
      expect(find.text('Delete budget'), findsNothing);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(SossoldiTextInput), findsOneWidget);
      expect(find.text('Budget amount'), findsOneWidget);
      expect(find.text('€'), findsOneWidget);
      expect(find.text('Amounts in EUR'), findsNothing);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete budget'), findsOneWidget);
    });

    testWidgets('the field starts with the current amount', (tester) async {
      final h = await _pump(tester);
      await startEditing(tester, 'Transport');
      final b = h.repo.budgetsForCategory('cat_transport').single;
      final field = tester.widget<TextField>(_amountInput);
      expect(
        double.parse(field.controller!.text.replaceAll(',', '.')),
        b.amount,
      );
    });

    testWidgets('typing a new amount previews the percentage', (tester) async {
      final h = await _pump(tester);
      await startEditing(tester, 'Transport');
      final b = h.repo.budgetsForCategory('cat_transport').single;
      final spent = h.repo.budgetStatus(b).spent;
      await tester.enterText(_amountInput, '${spent * 4}');
      await tester.pump();
      final item = tester.widget<SossoldiBudgetItem>(
        find.byType(SossoldiBudgetItem),
      );
      expect(item.percent, '25%');
      expect(item.tone, SossoldiBudgetTone.ok);
      // Nothing is saved yet.
      expect(h.repo.budget(b.id).amount, b.amount);
    });

    testWidgets('Done saves and goes back to read-only', (tester) async {
      final h = await _pump(tester);
      await startEditing(tester, 'Transport');
      await tester.enterText(_amountInput, '900');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(SossoldiTextInput), findsNothing);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete budget'), findsNothing);
      expect(h.repo.budgetsForCategory('cat_transport').single.amount, 900);
    });

    testWidgets('a comma works as the decimal separator', (tester) async {
      final h = await _pump(tester);
      await startEditing(tester, 'Transport');
      await tester.enterText(_amountInput, '250,5');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.budgetsForCategory('cat_transport').single.amount, 250.5);
    });

    testWidgets('Cancel throws the changes away', (tester) async {
      final h = await _pump(tester);
      final before = h.repo.budgetsForCategory('cat_transport').single.amount;
      await startEditing(tester, 'Transport');
      await tester.enterText(_amountInput, '12345');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(SossoldiTextInput), findsNothing);
      expect(h.repo.budgetsForCategory('cat_transport').single.amount, before);
      // Editing again starts from the saved amount, not from the discarded one.
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(_amountInput);
      expect(field.controller!.text, isNot(contains('12345')));
    });

    testWidgets('the system back leaves edit mode, not the page', (
      tester,
    ) async {
      await _pump(tester);
      await startEditing(tester, 'Transport');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
      expect(find.byType(SossoldiTextInput), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsNothing);
    });

    for (final (text, message) in [
      ('', 'Enter an amount.'),
      ('   ', 'Enter an amount.'),
      ('abc', 'Enter an amount.'),
      ('0', 'The amount must be greater than zero.'),
      ('0,00', 'The amount must be greater than zero.'),
      ('-50', 'The amount must be greater than zero.'),
    ]) {
      testWidgets('"$text" is refused: "$message"', (tester) async {
        final h = await _pump(tester);
        final before = h.repo.budgetsForCategory('cat_transport').single.amount;
        await startEditing(tester, 'Transport');
        await tester.enterText(_amountInput, text);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
        // Still editing, nothing saved.
        expect(find.byType(SossoldiTextInput), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(
          h.repo.budgetsForCategory('cat_transport').single.amount,
          before,
        );
        // Typing again clears the error.
        await tester.enterText(_amountInput, '10');
        await tester.pump();
        expect(find.text(message), findsNothing);
      });
    }

    testWidgets('a saved amount shows on the Budget tab right away', (
      tester,
    ) async {
      final h = await _pump(tester);
      final before = h.repo.budgetOverview(BudgetPeriod.monthly);
      await startEditing(tester, 'Transport');
      await tester.enterText(_amountInput, '5000');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      final after = h.repo.budgetOverview(BudgetPeriod.monthly);
      expect(after.total, isNot(before.total));
      final overall = tester.widget<SossoldiBudgetItem>(
        find.widgetWithText(SossoldiBudgetItem, 'Overall budget'),
      );
      expect(overall.percent, '${(after.usage * 100).round()}%');
      // Transport is no longer exceeded and is now the largest budget.
      final transport = tester.widget<SossoldiBudgetItem>(_row('Transport'));
      expect(transport.tone, SossoldiBudgetTone.ok);
      final first = tester
          .widgetList<SossoldiBudgetItem>(find.byType(SossoldiBudgetItem))
          .skip(1)
          .first;
      expect(first.title, 'Transport');
    });

    testWidgets('the amount is edited in the main currency', (tester) async {
      final h = await _pump(tester);
      h.state.setMainCurrency('USD');
      await tester.pump();
      await startEditing(tester, 'Transport');
      expect(find.text('\$'), findsOneWidget);
      expect(find.text('Amounts in USD'), findsNothing);
      await tester.enterText(_amountInput, '100');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      final b = h.repo.budgetsForCategory('cat_transport').single;
      expect(b.currency, 'EUR');
      expect(b.amount, closeTo(100 * h.repo.toEur(1, 'USD'), 0.01));
      expect(h.repo.budgetStatus(b).amount, closeTo(100, 0.02));
    });
  });

  group('deleting', () {
    Future<void> toEdit(WidgetTester tester, String category) async {
      await _openDetail(tester, category);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks first; Cancel keeps the budget', (tester) async {
      final h = await _pump(tester);
      final count = h.repo.budgets.length;
      await toEdit(tester, 'Transport');
      await tester.tap(find.text('Delete budget'));
      await tester.pumpAndSettle();
      expect(find.byType(SossoldiModal), findsOneWidget);
      expect(find.text('Delete this budget?'), findsOneWidget);
      expect(
        find.textContaining(
          'The monthly budget of Transport',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiModal),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SossoldiModal), findsNothing);
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
      expect(h.repo.budgets, hasLength(count));
    });

    testWidgets('Delete removes it and returns to the Budget tab', (
      tester,
    ) async {
      final h = await _pump(tester);
      final before = h.repo.budgetOverview(BudgetPeriod.monthly);
      await toEdit(tester, 'Transport');
      await tester.tap(find.text('Delete budget'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiModal),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsNothing);
      expect(h.repo.budgetsForCategory('cat_transport'), isEmpty);
      // The tab already shows it gone, with the totals and the bar updated.
      expect(_row('Transport'), findsNothing);
      final after = h.repo.budgetOverview(BudgetPeriod.monthly);
      expect(after.items.length, before.items.length - 1);
      expect(
        find.byType(SossoldiBudgetItem),
        findsNWidgets(1 + after.items.length),
      );
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('deleting the only budget of a period shows the empty state', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _pickPeriod(tester, 'Monthly', 'Yearly');
      await toEdit(tester, 'Education');
      await tester.tap(find.text('Delete budget'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiModal),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No budgets for this period'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      expect(h.repo.budgetOverview(BudgetPeriod.yearly).isEmpty, isTrue);
    });

    testWidgets('a category keeps its other budget', (tester) async {
      final h = await _pump(tester);
      await _pickPeriod(tester, 'Monthly', 'Weekly');
      await toEdit(tester, 'Groceries');
      await tester.tap(find.text('Delete budget'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiModal),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.repo.budgetsForCategory('cat_groceries'), hasLength(1));
      expect(
        h.repo.budgetsForCategory('cat_groceries').single.period,
        BudgetPeriod.monthly,
      );
      await _pickPeriod(tester, 'Weekly', 'Monthly');
      expect(_row('Groceries'), findsOneWidget);
    });
  });
}
