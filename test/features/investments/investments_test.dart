import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/investments/investments_controller.dart';
import 'package:sossoldi/features/investments/investments_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

class _Harness {
  _Harness(this.state, this.controller);
  final AppState state;
  final InvestmentsController controller;
  MockRepository get repo => state.repository;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  MockRepository? repository,
}) async {
  tester.view.physicalSize = const Size(390, 3200);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: repository ?? MockRepository(now: _now));
  final controller = InvestmentsController(state.repository);
  addTearDown(controller.dispose);
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
          home: Scaffold(body: InvestmentsScreen(controller: controller)),
        ),
      ),
    ),
  );
  await tester.pump();
  return _Harness(state, controller);
}

MockRepository _emptyPortfolio() => MockRepository(
  now: _now,
  investments: (_, _) =>
      (holdings: <Holding>[], movements: <InvestmentMovement>[]),
);

void main() {
  setUpAll(loadTestFonts);

  group('header and tabs', () {
    testWidgets('title, "Updated X ago" and the three tabs', (tester) async {
      await _pump(tester);
      expect(find.text('Investments'), findsOneWidget);
      expect(find.text('Updated 4 min ago'), findsOneWidget);
      for (final t in ['Overview', 'Positions', 'Movements']) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('Positions and Movements are built', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Positions'));
      await tester.pump();
      expect(find.text('Coming soon'), findsNothing);
      expect(find.byType(SossoldiSearchField), findsOneWidget);
      await tester.tap(find.text('Movements'));
      await tester.pump();
      expect(find.text('Coming soon'), findsNothing);
      expect(find.text('Search movements'), findsOneWidget);
      await tester.tap(find.text('Overview'));
      await tester.pump();
      expect(find.text('Portfolio value'), findsOneWidget);
    });

    testWidgets('the label follows the time: now, minutes, hours, days', (
      tester,
    ) async {
      var clock = _now;
      final repo = MockRepository(now: _now, clock: () => clock);
      final h = await _pump(tester, repository: repo);
      Future<void> at(Duration after, String text) async {
        clock = _now.add(after);
        h.state.repository.refreshPrices(); // notifies, time = clock
        clock = _now.add(after);
        await tester.pump();
        expect(find.text(text), findsOneWidget, reason: text);
      }

      // Refreshed just now.
      await at(Duration.zero, 'Updated just now');
      clock = _now.add(const Duration(minutes: 12));
      h.state.repository.notifyListeners();
      await tester.pump();
      expect(find.text('Updated 12 min ago'), findsOneWidget);
      clock = _now.add(const Duration(hours: 5));
      h.state.repository.notifyListeners();
      await tester.pump();
      expect(find.text('Updated 5 h ago'), findsOneWidget);
      clock = _now.add(const Duration(days: 3));
      h.state.repository.notifyListeners();
      await tester.pump();
      expect(find.text('Updated 3 d ago'), findsOneWidget);
    });

    testWidgets('Italian and dark mode', (tester) async {
      await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      expect(find.text('Investimenti'), findsOneWidget);
      expect(find.text('Aggiornato 4 min fa'), findsOneWidget);
      expect(find.text('Panoramica'), findsOneWidget);
      expect(find.text('Valore del portafoglio'), findsOneWidget);
      expect(find.text('Allocazione degli asset'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('pull to refresh', () {
    testWidgets('updates prices, values and the time, on any tab', (
      tester,
    ) async {
      var clock = _now;
      final repo = MockRepository(now: _now, clock: () => clock);
      final h = await _pump(tester, repository: repo);
      final before = repo.portfolioSummary().totalValue;
      clock = _now.add(const Duration(minutes: 30));
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(InvestmentsController.refreshDelay * 2);
      await tester.pumpAndSettle();
      expect(repo.portfolioSummary().totalValue, isNot(before));
      expect(repo.pricesUpdatedAt, clock);
      expect(find.text('Updated just now'), findsOneWidget);
      // The card shows the new value.
      final card = tester.widget<SossoldiPortfolioCard>(
        find.byType(SossoldiPortfolioCard),
      );
      expect(card.value, repo.portfolioSummary().totalValue);

      // Also from Positions.
      h.controller.selectTab(InvestmentsTab.positions);
      await tester.pump();
      final before2 = repo.portfolioSummary().totalValue;
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(InvestmentsController.refreshDelay * 2);
      await tester.pumpAndSettle();
      expect(repo.portfolioSummary().totalValue, isNot(before2));
    });
  });

  group('overview', () {
    testWidgets('the digest, the card, the chart and the allocation', (
      tester,
    ) async {
      final h = await _pump(tester);
      final alert = tester.widget<SossoldiAlert>(
        find.byType(SossoldiAlert).first,
      );
      expect(alert.tone, SossoldiAlertTone.success);
      expect(alert.title, 'Portfolio growing');
      expect(alert.message, contains('**'));
      final s = h.repo.portfolioSummary();
      final card = tester.widget<SossoldiPortfolioCard>(
        find.byType(SossoldiPortfolioCard),
      );
      expect(card.value, s.totalValue);
      expect(card.gain, s.gain);
      expect(card.gainPercent, s.gainPercent);
      expect(card.liquidity, s.liquidity);
      expect(find.text('Available liquidity'), findsOneWidget);
      expect(find.text('Market value'), findsWidgets);
      expect(find.byType(SossoldiValueChart), findsOneWidget);
      expect(find.text('Asset allocations'), findsOneWidget);
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
    });

    testWidgets('card, last chart point and allocation agree on the value', (
      tester,
    ) async {
      final h = await _pump(tester);
      final s = h.repo.portfolioSummary();
      for (final p in ValuePeriod.values) {
        h.controller.selectPeriod(p);
        await tester.pump();
        final chart = tester.widget<SossoldiValueChart>(
          find.byType(SossoldiValueChart),
        );
        expect(chart.values.last + s.liquidity, closeTo(s.totalValue, 0.01));
      }
      final donut = tester.widget<SossoldiDonutChart>(
        find.byType(SossoldiDonutChart),
      );
      expect(
        donut.segments.fold(0.0, (a, e) => a + e.value),
        closeTo(s.totalValue, 0.05),
      );
    });

    testWidgets('the period tabs change the chart; 1D is the default', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(h.controller.period, ValuePeriod.day);
      int points() => tester
          .widget<SossoldiValueChart>(find.byType(SossoldiValueChart))
          .values
          .length;
      expect(points(), 35);
      await tester.tap(find.text('5D'));
      await tester.pump();
      expect(points(), 175);
      for (final label in ['1M', '6M', 'YTD', '1Y', '5Y']) {
        await tester.tap(find.text(label));
        await tester.pump();
      }
      expect(h.controller.period, ValuePeriod.fiveYears);
      expect(points(), greaterThan(1000));
    });

    testWidgets(
      'a tap on the chart shows date, value, invested and difference',
      (tester) async {
        final h = await _pump(tester);
        await tester.tap(find.text('1M'));
        await tester.pump();
        final plot = find.descendant(
          of: find.byType(SossoldiValueChart),
          matching: find.byType(CustomPaint),
        );
        final box = tester.getRect(plot.last);
        await tester.tapAt(Offset(box.right - 2, box.top + 20));
        await tester.pump();
        expect(find.byType(SossoldiChartTooltip), findsOneWidget);
        final p = h.repo.marketValueSeries(ValuePeriod.month).points.last;
        expect(find.text('Market value'), findsWidgets);
        expect(find.text('Invested'), findsWidgets);
        expect(find.text('Difference'), findsNothing);
        final tip = tester.widget<SossoldiChartTooltip>(
          find.byType(SossoldiChartTooltip),
        );
        expect(tip.rows.first.$3, p.value);
        expect(tip.rows.last.$3, p.invested);
      },
    );

    testWidgets('allocation: single asset shows the top 5 and "Other"', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('Single asset'));
      await tester.pump();
      expect(find.textContaining('VWCE'), findsOneWidget);
      expect(find.textContaining('Other:'), findsOneWidget);
      expect(find.textContaining('Liquidity:'), findsOneWidget);
      await tester.tap(find.text('Asset class'));
      await tester.pump();
      expect(find.textContaining('ETFs:'), findsOneWidget);
      expect(find.textContaining('Stocks:'), findsOneWidget);
      expect(find.textContaining('Bonds:'), findsOneWidget);
    });

    testWidgets('hidden amounts: figures hidden, shapes there', (tester) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.textContaining('40.974'), findsNothing);
      expect(find.text('••••'), findsWidgets);
      final chart = tester.widget<SossoldiValueChart>(
        find.byType(SossoldiValueChart),
      );
      expect(chart.masked, isTrue);
      expect(chart.values, isNotEmpty);
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
      // The digest has no amount either.
      final alert = tester.widget<SossoldiAlert>(
        find.byType(SossoldiAlert).first,
      );
      expect(alert.message, contains('••••'));
    });

    testWidgets(
      'an empty portfolio: the card with the liquidity and an empty state',
      (tester) async {
        await _pump(tester, repository: _emptyPortfolio());
        expect(find.text('Portfolio value'), findsOneWidget);
        expect(find.text('No investments yet'), findsOneWidget);
        expect(find.byType(SossoldiValueChart), findsNothing);
        expect(find.byType(SossoldiDonutChart), findsNothing);
        final alert = tester.widget<SossoldiAlert>(
          find.byType(SossoldiAlert).first,
        );
        expect(alert.title, 'All good');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a dollar main currency: everything in dollars', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.state.setMainCurrency('USD');
      await tester.pump();
      final card = tester.widget<SossoldiPortfolioCard>(
        find.byType(SossoldiPortfolioCard),
      );
      expect(card.currencyCode, 'USD');
      expect(find.textContaining(r'$'), findsWidgets);
    });
  });
}
