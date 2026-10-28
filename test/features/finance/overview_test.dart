import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/app/placeholder_screen.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/budget/budget_detail_screen.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';
import 'package:sossoldi/features/finance/recurring/recurring_detail_screen.dart';
import 'package:sossoldi/features/finance/recurring/recurring_item.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget_status.dart';

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
  DateTime? now,
}) async {
  tester.view.physicalSize = const Size(390, 3600);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: MockRepository(now: now ?? _now));
  final finance = FinanceController(state.repository);
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

void main() {
  setUpAll(loadTestFonts);

  testWidgets('Finance opens on the Overview', (tester) async {
    final h = await _pump(tester);
    expect(h.finance.tab, FinanceTab.overview);
    expect(find.text('Your accounts'), findsOneWidget);
    expect(find.text('Upcoming recurrences'), findsOneWidget);
    expect(find.text('Cash flow'), findsOneWidget);
    expect(find.text('Budget status'), findsOneWidget);
    expect(find.text('Manage'), findsNWidgets(2));
  });

  group('digest', () {
    testWidgets('alerts in the tone of their message, with the indicator', (
      tester,
    ) async {
      final h = await _pump(tester);
      final digest = h.repo.financeDigest();
      expect(digest.length, inInclusiveRange(1, 3));
      final alert = tester.widget<SossoldiAlert>(
        find.byType(SossoldiAlert).first,
      );
      expect(alert.tone, SossoldiAlertTone.error);
      expect(alert.title, 'Budget exceeded');
      expect(alert.message, startsWith('You went over the '));
      if (digest.length > 1) {
        expect(find.byType(SossoldiPageIndicator), findsOneWidget);
      }
    });

    testWidgets('swiping shows the next message and moves the indicator', (
      tester,
    ) async {
      final h = await _pump(tester);
      if (h.repo.financeDigest().length < 2) return;
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      final indicator = tester.widget<SossoldiPageIndicator>(
        find.byType(SossoldiPageIndicator),
      );
      expect(indicator.index, 1);
    });

    testWidgets('the amounts are hidden in Hidden Mode', (tester) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      final alert = tester.widget<SossoldiAlert>(
        find.byType(SossoldiAlert).first,
      );
      expect(alert.message, contains('••••'));
      expect(alert.message, isNot(contains('€')));
    });

    testWidgets('Italian text', (tester) async {
      await _pump(tester, locale: const Locale('it'));
      expect(find.text('Budget sforato'), findsWidgets);
      expect(find.textContaining('Hai sforato il budget'), findsWidgets);
    });
  });

  group('accounts', () {
    testWidgets('balance and change of each, from the repository', (
      tester,
    ) async {
      final h = await _pump(tester);
      final items = tester
          .widgetList<SossoldiAccountItem>(find.byType(SossoldiAccountItem))
          .toList();
      final data = h.repo.accountsWithChange();
      expect(items.length, data.length);
      for (final (i, a) in data.indexed) {
        expect(items[i].name, a.account.name);
        expect(items[i].balance, a.balance);
        expect(items[i].variation, a.change);
        expect(items[i].currencyCode, a.account.currency);
      }
    });

    testWidgets('Manage opens a placeholder', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Manage').first);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
    });
  });

  group('upcoming recurrences', () {
    testWidgets('the same dates as the Recurring tab, at most five', (
      tester,
    ) async {
      final h = await _pump(tester);
      final rows = tester
          .widgetList<RecurringItem>(find.byType(RecurringItem))
          .toList();
      final expected = h.repo.upcomingRecurrencesThisMonth();
      expect(rows.length, expected.length);
      expect(rows.length, lessThanOrEqualTo(5));
      for (final (i, o) in expected.indexed) {
        expect(rows[i].date, o.date);
        expect(rows[i].planned, isTrue);
      }
    });

    testWidgets('tap opens the recurring page', (tester) async {
      await _pump(tester);
      await tester.tap(find.byType(RecurringItem).first);
      await tester.pumpAndSettle();
      expect(find.byType(RecurringDetailScreen), findsOneWidget);
    });

    testWidgets('none until the end of the month: an empty row', (
      tester,
    ) async {
      await _pump(tester, now: DateTime(2026, 10, 31, 12));
      expect(find.byType(RecurringItem), findsNothing);
      expect(
        find.text('No recurring transactions until the end of the month'),
        findsOneWidget,
      );
    });
  });

  group('cash flow', () {
    testWidgets('the chart and the legend', (tester) async {
      final h = await _pump(tester);
      final chart = tester.widget<SossoldiCashFlowChart>(
        find.byType(SossoldiCashFlowChart),
      );
      final flow = h.repo.cashFlow();
      expect(chart.length, 31);
      expect(chart.income, flow.income);
      expect(chart.expenses, flow.expenses);
      expect(chart.balance, flow.balance);
      expect(chart.income.length, 22);
      for (final label in ['Income', 'Expense', 'Balance']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Oct 1'), findsOneWidget);
      expect(find.text('Oct 31'), findsOneWidget);
    });

    testWidgets('the first day of the month has one point', (tester) async {
      await _pump(tester, now: DateTime(2026, 10, 1, 12));
      final chart = tester.widget<SossoldiCashFlowChart>(
        find.byType(SossoldiCashFlowChart),
      );
      expect(chart.balance.length, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hidden amounts keep the shape and hide the axis numbers', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('••'), findsWidgets);
      expect(find.byType(SossoldiCashFlowChart), findsOneWidget);
    });
  });

  group('budgets', () {
    testWidgets('cards in the order of the repository, 160px wide', (
      tester,
    ) async {
      final h = await _pump(tester);
      final cards = tester
          .widgetList<SossoldiBudgetItem>(find.byType(SossoldiBudgetItem))
          .toList();
      expect(cards, isNotEmpty);
      expect(cards.every((c) => c.card), isTrue);
      expect(tester.getSize(find.byType(SossoldiBudgetItem).first).width, 160);
      final data = h.repo.monthBudgets();
      // The ones on screen come first, in order.
      for (var i = 0; i < cards.length && i < data.length; i++) {
        expect(
          cards[i].tone == SossoldiBudgetTone.exceeded,
          data[i].state == BudgetState.exceeded,
        );
      }
      // The exceeded ones come first.
      expect(cards.first.tone, SossoldiBudgetTone.exceeded);
    });

    testWidgets('the period is a subtle chip above the category name', (
      tester,
    ) async {
      await _pump(tester);
      final card = find.byType(SossoldiBudgetItem).first;
      final chip = find.descendant(
        of: card,
        matching: find.byType(SossoldiChip),
      );
      // The first chip is the period, the second the exceeded percentage.
      expect(
        tester.widget<SossoldiChip>(chip.first).type,
        SossoldiChipType.subtle,
      );
      expect(
        tester.widget<SossoldiChip>(chip.last).type,
        SossoldiChipType.error,
      );
      final period = find.descendant(
        of: card,
        matching: find.widgetWithText(SossoldiChip, 'Monthly'),
      );
      expect(tester.widget<SossoldiChip>(period).type, SossoldiChipType.subtle);
      final name = find.descendant(of: card, matching: find.text('Leisure'));
      expect(name, findsOneWidget);
      // 4px between the chip and the name.
      expect(
        tester.getTopLeft(name).dy - tester.getBottomLeft(period).dy,
        closeTo(4, 0.5),
      );
      expect(
        tester.getTopLeft(name).dy,
        greaterThan(tester.getTopLeft(period).dy),
      );
    });

    testWidgets('tap opens the budget page; Manage a placeholder', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.byType(SossoldiBudgetItem).first);
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage').last);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
    });
  });

  testWidgets('dark mode, Italian', (tester) async {
    await _pump(
      tester,
      brightness: Brightness.dark,
      locale: const Locale('it'),
    );
    expect(find.text('I tuoi conti'), findsOneWidget);
    expect(find.text('Flusso di cassa'), findsOneWidget);
    expect(find.text('Stato dei budget'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
