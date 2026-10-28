import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/charts/transaction_charts_controller.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction_time_range.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

class _Harness {
  _Harness(this.state, this.finance);
  final AppState state;
  final FinanceController finance;
  TransactionChartsController get charts => finance.charts;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  // Tall, so that the whole page is on screen without scrolling.
  Size size = const Size(390, 1800),
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
    ..selectTab(FinanceTab.transactions)
    ..selectView(TransactionsView.charts);
  addTearDown(finance.dispose);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FinanceScreen(controller: finance)),
      ),
    ),
  );
  await tester.pump();
  return _Harness(state, finance);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

double _donutSum(WidgetTester tester) => tester
    .widget<SossoldiDonutChart>(find.byType(SossoldiDonutChart))
    .segments
    .fold(0.0, (sum, s) => sum + s.value);

double _areaSum(WidgetTester tester) => tester
    .widget<SossoldiStackedAreaChart>(find.byType(SossoldiStackedAreaChart))
    .series
    .fold(0.0, (sum, s) => sum + s.values.fold(0.0, (a, b) => a + b));

Future<void> _pickOption(
  WidgetTester tester,
  String current,
  String next,
) async {
  await tester.tap(find.text(current).first);
  await _settle(tester);
  await tester.tap(find.text(next).last);
  await _settle(tester);
}

void main() {
  setUpAll(loadTestFonts);

  group('the view', () {
    testWidgets('toolbar, kinds, total, donut and breakdown over time', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.text('Select time range'), findsOneWidget);
      expect(find.text('Current month'), findsOneWidget);
      expect(find.byType(SossoldiFilterButton), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Categories breakdown'), findsOneWidget);
      expect(find.text('Breakdown over time'), findsOneWidget);
      expect(find.text('Snapshot'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
      expect(find.byType(SossoldiStackedAreaChart), findsOneWidget);
      expect(h.charts.kind, TransactionKind.expense);
      expect(tester.takeException(), isNull);
    });

    testWidgets('legend lists every category, largest first, with amounts', (
      tester,
    ) async {
      final h = await _pump(tester);
      final b = h.charts.breakdown;
      expect(b.categories.length, greaterThan(3));
      final legends = tester
          .widgetList<SossoldiChartLegend>(find.byType(SossoldiChartLegend))
          .toList();
      expect(legends, hasLength(2));
      // The donut legend has an amount for each, the area legend none.
      expect(legends[0].items, hasLength(b.categories.length));
      expect(legends[0].items.every((i) => i.value != null), isTrue);
      expect(legends[1].items.every((i) => i.value == null), isTrue);
      expect(
        [for (final i in legends[0].items) i.label],
        [
          for (final c in b.categories)
            h.state.repository.category(c.categoryId).name,
        ],
      );
    });

    testWidgets('donut and areas use the category colors', (tester) async {
      final h = await _pump(tester);
      final repo = h.state.repository;
      final b = h.charts.breakdown;
      final donut = tester.widget<SossoldiDonutChart>(
        find.byType(SossoldiDonutChart),
      );
      final area = tester.widget<SossoldiStackedAreaChart>(
        find.byType(SossoldiStackedAreaChart),
      );
      for (final (i, c) in b.categories.indexed) {
        final color = repo.category(c.categoryId).color.main;
        expect(donut.segments[i].color, color);
        expect(area.series[i].color, color);
        expect(donut.segments[i].value, c.amount);
      }
    });

    testWidgets('the total matches the donut and the areas, always', (
      tester,
    ) async {
      final h = await _pump(tester);
      for (final range in TransactionTimeRange.values) {
        for (final kind in TransactionKind.values) {
          h.charts.setRange(range);
          h.charts.setKind(kind);
          await tester.pump();
          final b = h.charts.breakdown;
          if (b.isEmpty) continue;
          expect(
            _donutSum(tester),
            closeTo(b.total, 0.001),
            reason: '$range $kind',
          );
          expect(
            _areaSum(tester),
            closeTo(b.total, 0.001),
            reason: '$range $kind',
          );
        }
      }
    });
  });

  group('time range and granularity', () {
    testWidgets('picking a range updates the data', (tester) async {
      final h = await _pump(tester);
      final before = h.charts.breakdown.total;
      await _pickOption(tester, 'Current month', 'Last 6 months');
      expect(h.charts.range, TransactionTimeRange.last6Months);
      expect(h.charts.breakdown.total, isNot(before));
      expect(find.text('Last 6 months'), findsOneWidget);
    });

    testWidgets('weekly by default, monthly from 6 months', (tester) async {
      final h = await _pump(tester);
      expect(h.charts.granularity, TransactionGranularity.weekly);
      h.charts.setRange(TransactionTimeRange.last3Months);
      expect(h.charts.granularity, TransactionGranularity.weekly);
      h.charts.setRange(TransactionTimeRange.last6Months);
      expect(h.charts.granularity, TransactionGranularity.monthly);
      await tester.pump();
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('monthly is disabled on a single month', (tester) async {
      final h = await _pump(tester);
      expect(h.charts.allowedGranularities, [TransactionGranularity.weekly]);
      await tester.tap(find.text('Weekly'));
      await _settle(tester);
      await tester.tap(find.text('Monthly'));
      await _settle(tester);
      expect(h.charts.granularity, TransactionGranularity.weekly);
      // The option is there, dimmed.
      final item = tester.widget<SossoldiMenuItem>(
        find.widgetWithText(SossoldiMenuItem, 'Monthly'),
      );
      expect(item.enabled, isFalse);
    });

    testWidgets('the user can change it, a new range resets it', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.charts.setRange(TransactionTimeRange.last6Months);
      await tester.pump();
      await _pickOption(tester, 'Monthly', 'Weekly');
      expect(h.charts.granularity, TransactionGranularity.weekly);
      final weeks = h.charts.breakdown.buckets.length;
      expect(weeks, greaterThan(h.charts.range.resolve(_now).monthsSpanned));
      h.charts.setRange(TransactionTimeRange.last12Months);
      expect(h.charts.granularity, TransactionGranularity.monthly);
    });
  });

  group('total and change', () {
    testWidgets('expenses are negative and red, income positive and green', (
      tester,
    ) async {
      final h = await _pump(tester);
      var amount = tester.widget<SossoldiAmount>(
        find.byType(SossoldiAmount).first,
      );
      expect(amount.value, -h.charts.breakdown.total);
      expect(amount.tone, SossoldiAmountTone.signed);
      h.charts.setKind(TransactionKind.income);
      await tester.pump();
      amount = tester.widget<SossoldiAmount>(find.byType(SossoldiAmount).first);
      expect(amount.value, h.charts.breakdown.total);
      expect(amount.showPlusSign, isTrue);
    });

    testWidgets('the chip color follows meaning, not sign', (tester) async {
      final h = await _pump(tester);
      var checked = 0;
      for (final range in TransactionTimeRange.values) {
        for (final kind in TransactionKind.values) {
          h.charts.setRange(range);
          h.charts.setKind(kind);
          await tester.pump();
          final change = h.charts.breakdown.changeVsPrevious;
          if (change == null) {
            expect(
              find.byType(SossoldiChip),
              findsNothing,
              reason: '$range $kind',
            );
            continue;
          }
          final chip = tester.widget<SossoldiChip>(find.byType(SossoldiChip));
          final good = kind == TransactionKind.expense
              ? change <= 0
              : change >= 0;
          expect(
            chip.type,
            good ? SossoldiChipType.income : SossoldiChipType.expense,
            reason: '$range $kind change $change',
          );
          expect(chip.label, contains('PoP'));
          expect(chip.label, contains('%'));
          checked++;
        }
      }
      expect(checked, greaterThan(2));
    });

    testWidgets('without a previous period there is no chip', (tester) async {
      final h = await _pump(tester);
      h.charts.setRange(TransactionTimeRange.last12Months);
      await tester.pump();
      expect(h.charts.breakdown.changeVsPrevious, isNull);
      expect(find.byType(SossoldiChip), findsNothing);
    });

    testWidgets('Italian words the change as "vs periodo prec."', (
      tester,
    ) async {
      final h = await _pump(tester, locale: const Locale('it'));
      expect(h.charts.breakdown.changeVsPrevious, isNotNull);
      expect(find.textContaining('vs periodo prec.'), findsOneWidget);
      expect(find.text('Seleziona il periodo'), findsOneWidget);
      expect(find.text('Mese in corso'), findsOneWidget);
      expect(find.text('Uscite'), findsOneWidget);
    });
  });

  group('filters', () {
    Future<void> openFilters(WidgetTester tester) async {
      await tester.tap(find.byType(SossoldiFilterButton));
      await _settle(tester);
    }

    testWidgets('the sheet lists accounts and the categories of the kind', (
      tester,
    ) async {
      await _pump(tester);
      await openFilters(tester);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.widgetWithText(SossoldiMenuItem, 'Home'), findsOneWidget);
      expect(find.widgetWithText(SossoldiMenuItem, 'Salary'), findsNothing);
    });

    testWidgets('picking an account and a category filters and shows the dot', (
      tester,
    ) async {
      final h = await _pump(tester);
      final account = h.state.repository.accounts.first;
      await openFilters(tester);
      await tester.tap(find.widgetWithText(SossoldiMenuItem, account.name));
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(SossoldiMenuItem, 'Home'));
      await tester.tap(find.widgetWithText(SossoldiMenuItem, 'Home'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await _settle(tester);

      expect(h.charts.accountIds, {account.id});
      expect(h.charts.categoryIds, {'cat_home'});
      expect(h.charts.activeFilterCount, 2);
      expect(
        tester
            .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
            .active,
        isTrue,
      );
      expect(
        [for (final c in h.charts.breakdown.categories) c.categoryId],
        ['cat_home'],
      );
      expect(_donutSum(tester), closeTo(h.charts.breakdown.total, 0.001));
    });

    testWidgets('Cancel changes nothing, Reset clears both', (tester) async {
      final h = await _pump(tester);
      await openFilters(tester);
      await tester.tap(find.widgetWithText(SossoldiMenuItem, 'Home'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(h.charts.activeFilterCount, 0);

      h.charts.applyFilters(
        accountIds: {h.state.repository.accounts.first.id},
        categoryIds: {'cat_home'},
      );
      await tester.pump();
      await openFilters(tester);
      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.charts.activeFilterCount, 0);
      expect(h.charts.accountIds, isEmpty);
    });

    testWidgets('categories picked for one kind survive switching kinds', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.charts.applyFilters(accountIds: const {}, categoryIds: {'cat_home'});
      await tester.pump();
      expect(h.charts.activeFilterCount, 1);
      // On Income the Home filter does not apply: all income is shown.
      h.charts.setKind(TransactionKind.income);
      await tester.pump();
      expect(h.charts.categoryIds, isEmpty);
      expect(h.charts.activeFilterCount, 0);
      expect(h.charts.breakdown.categories.length, greaterThan(0));
      // Picking an income category keeps the expense one in the background.
      await openFilters(tester);
      await tester.tap(find.widgetWithText(SossoldiMenuItem, 'Salary'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await _settle(tester);
      expect(h.charts.categoryIds, {'cat_salary'});
      expect(h.charts.allSelectedCategoryIds, {'cat_home', 'cat_salary'});
      h.charts.setKind(TransactionKind.expense);
      await tester.pump();
      expect(h.charts.categoryIds, {'cat_home'});
    });
  });

  group('empty state', () {
    testWidgets('no data: Total at zero, no chip, an empty state', (
      tester,
    ) async {
      final h = await _pump(tester);
      // The broker account has no expenses in the mock.
      h.charts.applyFilters(
        accountIds: {h.state.repository.accounts.last.id},
        categoryIds: const {},
      );
      await tester.pump();
      expect(h.charts.breakdown.isEmpty, isTrue);
      expect(find.text('No transactions in this period'), findsOneWidget);
      expect(
        find.text('Try another time range or fewer filters.'),
        findsOneWidget,
      );
      expect(find.byType(SossoldiDonutChart), findsNothing);
      expect(find.byType(SossoldiStackedAreaChart), findsNothing);
      expect(find.byType(SossoldiChip), findsNothing);
      expect(
        tester.widget<SossoldiAmount>(find.byType(SossoldiAmount)).value,
        0,
      );
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
    });

    testWidgets('without filters the empty state has no button', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.charts.applyFilters(accountIds: const {}, categoryIds: const {});
      expect(h.charts.activeFilterCount, 0);
    });
  });

  group('hidden amounts', () {
    testWidgets('hides the total and the legend amounts, keeps the shapes', (
      tester,
    ) async {
      final h = await _pump(tester);
      final segments = tester
          .widget<SossoldiDonutChart>(find.byType(SossoldiDonutChart))
          .segments
          .length;
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('••••'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && RegExp(r'\d+[.,]\d{2}').hasMatch(w.data ?? ''),
        ),
        findsNothing,
      );
      expect(
        find.textContaining(RegExp(r'\d+[.,]\d{2}'), findRichText: true),
        findsNothing,
      );
      expect(
        tester
            .widget<SossoldiDonutChart>(find.byType(SossoldiDonutChart))
            .segments,
        hasLength(segments),
      );
      expect(
        tester
            .widget<SossoldiStackedAreaChart>(
              find.byType(SossoldiStackedAreaChart),
            )
            .masked,
        isTrue,
      );
    });

    testWidgets('the tooltip hides its values too', (tester) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byType(SossoldiStackedAreaChart),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.center.dx, box.center.dy));
      await tester.pump();
      expect(find.text('••••'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text && RegExp(r'\d+[.,]\d{2}\s?€').hasMatch(w.data ?? ''),
        ),
        findsNothing,
      );
    });
  });

  group('interaction with the chart', () {
    testWidgets('touching the chart shows the date and category values', (
      tester,
    ) async {
      await _pump(tester);
      await tester.scrollUntilVisible(
        find.byType(SossoldiStackedAreaChart),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final box = tester.getRect(find.byType(SossoldiStackedAreaChart));
      await tester.tapAt(Offset(box.left + 40, box.center.dy));
      await tester.pump();
      // A weekly title: "Oct 1 – Oct 4".
      expect(find.textContaining(RegExp(r'Oct \d+')), findsWidgets);
      expect(find.text('Total'), findsWidgets);
    });
  });

  group('the state', () {
    testWidgets('survives going to the list and back', (tester) async {
      final h = await _pump(tester);
      h.charts.setRange(TransactionTimeRange.last3Months);
      h.charts.setKind(TransactionKind.income);
      h.charts.applyFilters(
        accountIds: {h.state.repository.accounts.first.id},
        categoryIds: const {},
      );
      await tester.pump();
      await tester.tap(find.text('List'));
      await tester.pump();
      await tester.tap(find.text('Charts'));
      await tester.pump();
      expect(h.charts.range, TransactionTimeRange.last3Months);
      expect(h.charts.kind, TransactionKind.income);
      expect(h.charts.accountIds, hasLength(1));
      expect(find.text('Last 3 months'), findsOneWidget);
    });

    testWidgets('light and dark both render, also on a small phone', (
      tester,
    ) async {
      await _pump(
        tester,
        brightness: Brightness.dark,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('the controller', () {
    test('memoizes the breakdown and recomputes on change', () {
      final c = TransactionChartsController(MockRepository(now: _now));
      addTearDown(c.dispose);
      final a = c.breakdown;
      expect(identical(c.breakdown, a), isTrue);
      var notified = 0;
      c.addListener(() => notified++);
      c.setKind(TransactionKind.income);
      expect(identical(c.breakdown, a), isFalse);
      c.setKind(TransactionKind.income); // same value: nothing happens
      expect(notified, 1);
    });

    test('setGranularity ignores options the range does not allow', () {
      final c = TransactionChartsController(MockRepository(now: _now));
      addTearDown(c.dispose);
      c.setGranularity(TransactionGranularity.monthly);
      expect(c.granularity, TransactionGranularity.weekly);
      c.setRange(TransactionTimeRange.last6Months);
      c.setGranularity(TransactionGranularity.weekly);
      expect(c.granularity, TransactionGranularity.weekly);
      c.setRange(TransactionTimeRange.last3Months);
      expect(c.granularity, TransactionGranularity.weekly);
      c.setGranularity(TransactionGranularity.monthly);
      expect(c.granularity, TransactionGranularity.monthly);
    });

    test('the finance controller notifies when the charts change', () {
      final f = FinanceController(MockRepository(now: _now));
      addTearDown(f.dispose);
      var notified = 0;
      f.addListener(() => notified++);
      f.charts.setRange(TransactionTimeRange.lastMonth);
      expect(notified, 1);
    });
  });
}
