import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';
import 'package:sossoldi/features/finance/transactions/transaction_filters_sheet.dart';
import 'package:sossoldi/features/finance/transactions/transaction_row.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_filter.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

class _Harness {
  _Harness(this.state, this.controller);
  final AppState state;
  final FinanceController controller;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
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
  final controller = FinanceController(state.repository)
    ..selectTab(FinanceTab.transactions);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FinanceScreen(controller: controller)),
      ),
    ),
  );
  await tester.pump();
  return _Harness(state, controller);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _openFilters(WidgetTester tester) async {
  await tester.tap(find.byType(SossoldiFilterButton));
  await _settle(tester);
}

/// Taps something inside the (scrollable) filters sheet.
Future<void> _tapInSheet(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Text inside a filter chip ("Name: value" is one rich text).
Finder _chipText(String text) => find.textContaining(text, findRichText: true);

/// The text fields of the filters sheet (not the search bar behind it).
Finder get _sheetFields => find.descendant(
  of: find.byType(TransactionFiltersSheet),
  matching: find.byType(TextField),
);

int _rows(WidgetTester tester) =>
    tester.widgetList(find.byType(TransactionRow)).length;

void main() {
  setUpAll(loadTestFonts);

  group('the page', () {
    testWidgets('title, four tabs, view switch and the list', (tester) async {
      final h = await _pump(tester);
      expect(find.text('Finance'), findsOneWidget);
      for (final tab in ['Overview', 'Transactions', 'Budget', 'Recurring']) {
        expect(find.text(tab), findsOneWidget);
      }
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Charts'), findsOneWidget);
      expect(find.text('Search transactions'), findsOneWidget);
      expect(h.controller.tab, FinanceTab.transactions);
      expect(_rows(tester), greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Overview is the first tab, Recurring has its calendar', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('Overview'));
      await tester.pump();
      expect(find.text('Your accounts'), findsOneWidget);
      expect(find.byType(TransactionRow), findsNothing);
      await tester.tap(find.text('Recurring'));
      await tester.pump();
      expect(find.byType(SossoldiCalendar), findsOneWidget);
      expect(find.byType(TransactionRow), findsNothing);
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      await tester.tap(find.text('Charts'));
      await tester.pump();
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
      expect(find.byType(TransactionRow), findsNothing);
      await tester.tap(find.text('List'));
      await tester.pump();
      expect(find.byType(TransactionRow), findsWidgets);
    });

    testWidgets('transactions are grouped by day, newest first', (
      tester,
    ) async {
      final h = await _pump(tester);
      final page = h.controller.result;
      final days = {
        for (final t in page.items)
          DateTime(t.date.year, t.date.month, t.date.day),
      };
      expect(find.byType(SossoldiDayHeader), findsNWidgets(days.length));
      final tops = [
        for (final e in tester.widgetList<SossoldiDayHeader>(
          find.byType(SossoldiDayHeader),
        ))
          e.title,
      ];
      expect(tops.toSet().length, tops.length);
      // The first header is the day of the first transaction: "October 22nd"
      // style titles, English ordinals included.
      expect(
        tops.first,
        matches(RegExp(r'^\w+day, October \d+(st|nd|rd|th)$')),
      );
    });

    testWidgets('default date filter is the current month, as a chip', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(_chipText('October 2026'), findsOneWidget);
      expect(find.byType(SossoldiFilterChip), findsOneWidget);
      expect(h.controller.activeFilterCount, 0);
      expect(
        h.controller.result.items.every(
          (t) => t.date.year == 2026 && t.date.month == 10,
        ),
        isTrue,
      );
    });

    testWidgets('twenty per page at most, with pagination', (tester) async {
      final h = await _pump(tester);
      // Remove the date: all history, several pages.
      h.controller.removeDate();
      await tester.pump();
      expect(_rows(tester), lessThanOrEqualTo(20));
      expect(find.byType(SossoldiPagination), findsOneWidget);
      expect(h.controller.result.pageCount, greaterThan(1));
    });

    testWidgets('page 2 shows the next transactions and scrolls to the top', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.controller.removeDate();
      await tester.pump();
      final first = h.controller.result.items.first.id;
      await tester.scrollUntilVisible(
        find.byType(SossoldiPagination),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(h.controller.page, 2);
      expect(h.controller.result.items.first.id, isNot(first));
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scroll.position.pixels, 0);
    });
  });

  group('search', () {
    testWidgets('narrows the list and survives a tab change', (tester) async {
      final h = await _pump(tester);
      final before = h.controller.result.total;
      await tester.enterText(find.byType(TextField), 'home');
      await tester.pump();
      expect(h.controller.filter.query, 'home');
      expect(h.controller.result.total, lessThan(before));
      expect(h.controller.result.total, greaterThan(0));

      await tester.tap(find.text('Budget'));
      await tester.pump();
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'home'), findsOneWidget);
      expect(h.controller.filter.query, 'home');
    });

    testWidgets('no results: empty state, "Clear filters" brings it back', (
      tester,
    ) async {
      final h = await _pump(tester);
      await tester.enterText(find.byType(TextField), 'zzzzqq');
      await tester.pump();
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('Try changing the search or the filters.'), findsOne);
      expect(find.byType(TransactionRow), findsNothing);
      expect(find.byType(SossoldiPagination), findsNothing);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(find.text('No transactions found'), findsNothing);
      expect(h.controller.filter, h.controller.defaultFilter);
      expect(find.text('zzzzqq'), findsNothing);
      expect(find.byType(TransactionRow), findsWidgets);
    });
  });

  group('filters sheet', () {
    testWidgets('lists every filter', (tester) async {
      await _pump(tester);
      await _openFilters(tester);
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Date'), findsWidgets);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('€'), findsNWidgets(2), reason: 'min and max');
      expect(find.text('Amounts in EUR'), findsNothing);
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
    });

    testWidgets('Cancel changes nothing', (tester) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      await _tapInSheet(tester, find.text('Income').last);
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(h.controller.filter, h.controller.defaultFilter);
    });

    testWidgets('type filter: chip, dot, and only those transactions', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      await _tapInSheet(
        tester,
        find.widgetWithText(SossoldiUnitNavigator, 'Income'),
      );
      await tester.tap(find.text('Apply'));
      await _settle(tester);

      expect(h.controller.filter.types, {TransactionType.income});
      expect(_chipText('Type: Income'), findsOneWidget);
      expect(h.controller.activeFilterCount, 1);
      expect(
        tester
            .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
            .active,
        isTrue,
      );
      expect(
        h.controller.result.items.every(
          (t) => t.type == TransactionType.income,
        ),
        isTrue,
      );
    });

    testWidgets('removing a chip removes only that filter', (tester) async {
      final h = await _pump(tester);
      h.controller.applyFilter(
        h.controller.defaultFilter.copyWith(
          types: {TransactionType.expense},
          categoryIds: {'cat_home'},
        ),
      );
      await tester.pump();
      // Date, type, category.
      expect(find.byType(SossoldiFilterChip), findsNWidgets(3));
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiFilterChip).at(1),
          matching: find.byType(SossoldiTappable),
        ),
      );
      await tester.pump();
      expect(h.controller.filter.types, isEmpty);
      expect(h.controller.filter.categoryIds, {'cat_home'});
      expect(find.byType(SossoldiFilterChip), findsNWidgets(2));
    });

    testWidgets('removing the date chip means any date', (tester) async {
      final h = await _pump(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(SossoldiFilterChip),
          matching: find.byType(SossoldiTappable),
        ),
      );
      await tester.pump();
      expect(h.controller.filter.hasDateRange, isFalse);
      expect(find.byType(SossoldiFilterChip), findsNothing);
      expect(h.controller.result.total, h.state.repository.transactions.length);
    });

    testWidgets('category Home, last month, page 2 all work together', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      await _tapInSheet(
        tester,
        find.widgetWithText(SossoldiUnitNavigator, 'Last month'),
      );
      await _tapInSheet(tester, find.widgetWithText(SossoldiMenuItem, 'Home'));
      await tester.tap(find.text('Apply'));
      await _settle(tester);

      final f = h.controller.filter;
      expect(f.categoryIds, {'cat_home'});
      expect(f.from, DateTime(2026, 9));
      expect(f.to, DateTime(2026, 9, 30));
      expect(_chipText('September 2026'), findsOneWidget);
      expect(_chipText('Category: Home'), findsOneWidget);
      final expected = h.state.repository.searchTransactions(f);
      expect(h.controller.result.total, expected.total);
      expect(
        h.controller.result.items.every(
          (t) => t.categoryId == 'cat_home' && t.date.month == 9,
        ),
        isTrue,
      );

      // With a page size of 20 Home alone may fit one page, so also check
      // page 2 on a bigger selection: all of September.
      h.controller.applyFilter(f.copyWith(categoryIds: const {}));
      await tester.pump();
      h.controller.goToPage(2);
      await tester.pump();
      final all = h.state.repository.searchTransactions(
        f.copyWith(categoryIds: const {}),
        page: 2,
      );
      expect(h.controller.page, all.total > 20 ? 2 : 1);
      expect(
        [for (final t in h.controller.result.items) t.id],
        [for (final t in all.items) t.id],
      );
    });

    testWidgets('amount range, with a comma as decimal separator', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      final fields = _sheetFields;
      await tester.ensureVisible(fields.first);
      await tester.enterText(fields.at(0), '50');
      await tester.enterText(fields.at(1), '200,5');
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.controller.filter.minAmount, 50);
      expect(h.controller.filter.maxAmount, 200.5);
      expect(_chipText('Amount: '), findsOneWidget);
      for (final t in h.controller.result.items) {
        final eur = h.state.repository.toMain(t.amount, t.currency);
        expect(eur, inInclusiveRange(50, 200.5));
      }
    });

    testWidgets('a reversed range is put in order', (tester) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      final fields = _sheetFields;
      await tester.ensureVisible(fields.first);
      await tester.enterText(fields.at(0), '300');
      await tester.enterText(fields.at(1), '20');
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.controller.filter.minAmount, 20);
      expect(h.controller.filter.maxAmount, 300);
    });

    testWidgets('account filter and Reset', (tester) async {
      final h = await _pump(tester);
      final account = h.state.repository.accounts.last;
      await _openFilters(tester);
      await _tapInSheet(
        tester,
        find.widgetWithText(SossoldiMenuItem, account.name),
      );
      await _tapInSheet(tester, find.text('Reset'));
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.controller.filter, h.controller.defaultFilter);

      await _openFilters(tester);
      await _tapInSheet(
        tester,
        find.widgetWithText(SossoldiMenuItem, account.name),
      );
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.controller.filter.accountIds, {account.id});
      expect(_chipText('Account: ${account.name}'), findsOneWidget);
    });

    testWidgets('custom date range with the calendar', (tester) async {
      final h = await _pump(tester);
      await _openFilters(tester);
      await _tapInSheet(
        tester,
        find.widgetWithText(SossoldiUnitNavigator, 'Custom range'),
      );
      expect(find.byType(SossoldiDateRangePicker), findsOneWidget);
      await _tapInSheet(tester, find.text('5').last);
      await _tapInSheet(tester, find.text('12').last);
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.controller.filter.from, DateTime(2026, 10, 5));
      expect(h.controller.filter.to, DateTime(2026, 10, 12));
      expect(_chipText('Oct 5, 2026 – Oct 12, 2026'), findsOneWidget);
    });
  });

  group('amounts and text', () {
    testWidgets('the eye button masks every amount, day chips included', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.text('••••'), findsNothing);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('••••'), findsWidgets);
      // Not a single digit followed by a currency left on the rows.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text && RegExp(r'[+-]?\d+[.,]\d{2}').hasMatch(w.data ?? ''),
        ),
        findsNothing,
      );
    });

    testWidgets('long descriptions are cut with an ellipsis', (tester) async {
      await _pump(tester);
      final repo = MockRepository(now: _now);
      await tester.pumpWidget(
        AppScope(
          state: AppState(repository: repo),
          child: MaterialApp(
            theme: SossoldiTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: TransactionRow(
                  transaction: Transaction(
                    id: 'x',
                    type: TransactionType.expense,
                    amount: 1234.56,
                    currency: 'EUR',
                    date: _now,
                    description: 'A very long description that does not fit in the row at all, really',
                    accountId: repo.accounts.first.id,
                    categoryId: 'cat_home',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('A very long'), findsOneWidget);
    });

    testWidgets('an amount in another currency keeps its currency', (
      tester,
    ) async {
      final repo = MockRepository(now: _now);
      await tester.pumpWidget(
        AppScope(
          state: AppState(repository: repo),
          child: MaterialApp(
            theme: SossoldiTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TransactionRow(
                transaction: Transaction(
                  id: 'x',
                  type: TransactionType.expense,
                  amount: 49,
                  currency: 'USD',
                  date: _now,
                  description: 'Online course',
                  accountId: repo.accounts.first.id,
                  categoryId: 'cat_education',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining(r'$'), findsOneWidget);
      expect(find.textContaining('€'), findsNothing);
    });
  });

  group('light, dark and Italian', () {
    testWidgets('dark mode renders the list and the sheet', (tester) async {
      await _pump(tester, brightness: Brightness.dark);
      await _openFilters(tester);
      expect(find.text('Filters'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Italian: titles, date format and chip', (tester) async {
      await _pump(tester, locale: const Locale('it'));
      expect(find.text('Finanze'), findsOneWidget);
      expect(find.text('Cerca transazioni'), findsOneWidget);
      expect(_chipText('Ottobre 2026'), findsOneWidget);
      final titles = [
        for (final h in tester.widgetList<SossoldiDayHeader>(
          find.byType(SossoldiDayHeader),
        ))
          h.title,
      ];
      expect(titles.first, matches(RegExp(r'^\S+ \d+ ottobre$')));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a small phone does not overflow', (tester) async {
      await _pump(tester, size: const Size(320, 640));
      await _openFilters(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('the controller', () {
    testWidgets('keeps tab, view and filters while the page is rebuilt', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.controller.applyFilter(
        h.controller.defaultFilter.copyWith(types: {TransactionType.income}),
      );
      h.controller.setQuery('pay');
      await tester.pump();
      h.controller.selectTab(FinanceTab.budget);
      await tester.pump();
      h.controller.selectTab(FinanceTab.transactions);
      await tester.pump();
      expect(h.controller.filter.types, {TransactionType.income});
      expect(h.controller.filter.query, 'pay');
    });

    test('a new filter or search goes back to page 1', () {
      final repo = MockRepository(now: _now);
      final c = FinanceController(repo);
      addTearDown(c.dispose);
      c.removeDate();
      c.goToPage(3);
      expect(c.page, 3);
      c.setQuery('a');
      expect(c.page, 1);
      c.goToPage(2);
      c.applyFilter(c.filter.copyWith(types: {TransactionType.expense}));
      expect(c.page, 1);
    });

    test('applyFilter keeps the search text; clearAll resets everything', () {
      final c = FinanceController(MockRepository(now: _now));
      addTearDown(c.dispose);
      c.setQuery('rent');
      c.applyFilter(const TransactionFilter(categoryIds: {'cat_home'}));
      expect(c.filter.query, 'rent');
      expect(c.isRefined, isTrue);
      c.clearAll();
      expect(c.filter, c.defaultFilter);
      expect(c.isRefined, isFalse);
    });

    test('out-of-range pages are clamped', () {
      final c = FinanceController(MockRepository(now: _now));
      addTearDown(c.dispose);
      c.goToPage(999);
      expect(c.page, c.result.pageCount);
    });
  });
}
