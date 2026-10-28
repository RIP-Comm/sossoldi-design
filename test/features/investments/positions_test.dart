import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/investments/investments_controller.dart';
import 'package:sossoldi/features/investments/investments_screen.dart';
import 'package:sossoldi/features/investments/positions/position_detail_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

class _H {
  _H(this.state, this.controller);
  final AppState state;
  final InvestmentsController controller;
  MockRepository get repo => state.repository;
}

Future<_H> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  MockRepository? repository,
}) async {
  tester.view.physicalSize = const Size(390, 4200);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: repository ?? MockRepository(now: _now));
  final controller = InvestmentsController(state.repository)
    ..selectTab(InvestmentsTab.positions);
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
  return _H(state, controller);
}

Finder get _rows => find.byType(SossoldiAssetItem);

/// A text inside the filters sheet (the list has the same words).
Finder _inSheet(String text) => find.descendant(
  of: find.byType(SossoldiBottomSheet),
  matching: find.text(text),
);

Future<void> _openDetail(WidgetTester tester, String name) async {
  await tester.tap(
    find.widgetWithText(SossoldiAssetItem, name.toUpperCase()).first,
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
}

void main() {
  setUpAll(loadTestFonts);

  group('list', () {
    testWidgets('card, title, search under it, the positions by weight', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.byType(SossoldiPortfolioCard), findsOneWidget);
      expect(find.text('Positions'), findsWidgets);
      final sections = tester.getTopLeft(find.byType(SossoldiSearchField)).dy;
      final card = tester.getBottomLeft(find.byType(SossoldiPortfolioCard)).dy;
      expect(sections, greaterThan(card), reason: 'search is under the title');
      final items = tester.widgetList<SossoldiAssetItem>(_rows).toList();
      final data = h.repo.searchPositions();
      expect(items.length, data.length);
      expect(items.map((e) => e.name), data.map((p) => p.name));
    });

    testWidgets('a row: type, name, ticker - ISIN, chart, value, P&L', (
      tester,
    ) async {
      final h = await _pump(tester);
      final vwce = h.repo.searchPositions().firstWhere(
        (p) => p.ticker == 'VWCE',
      );
      final item = tester
          .widgetList<SossoldiAssetItem>(_rows)
          .firstWhere((e) => e.name == vwce.name);
      expect(item.typeLabel, 'ETF');
      expect(item.identifier, 'VWCE - IE00BK5BQT80');
      expect(item.chart!.points, vwce.monthPrices);
      expect(item.chart!.value, vwce.value);
      expect(item.chart!.change, vwce.gainPercent);
    });

    testWidgets('a manual asset: no ticker, no chart, but value and P&L', (
      tester,
    ) async {
      final h = await _pump(tester);
      final watch = h.repo.searchPositions().firstWhere(
        (p) => p.holdingId == 'hld_watch',
      );
      final item = tester
          .widgetList<SossoldiAssetItem>(_rows)
          .firstWhere((e) => e.name == watch.name);
      expect(item.typeLabel, 'Collectible');
      expect(item.identifier, isEmpty);
      expect(item.chart!.points, isEmpty);
      expect(item.chart!.value, watch.value);
    });

    testWidgets('positions + liquidity are the portfolio value', (
      tester,
    ) async {
      final h = await _pump(tester);
      final card = tester.widget<SossoldiPortfolioCard>(
        find.byType(SossoldiPortfolioCard),
      );
      final sum = tester
          .widgetList<SossoldiAssetItem>(_rows)
          .fold(0.0, (s, e) => s + e.chart!.value);
      expect(sum + card.liquidity, closeTo(card.value, 0.05));
      expect(card.value, h.repo.portfolioSummary().totalValue);
    });
  });

  group('search and filters', () {
    testWidgets('by name, ticker and ISIN; only the list changes', (
      tester,
    ) async {
      final h = await _pump(tester);
      final cardBefore = tester
          .widget<SossoldiPortfolioCard>(find.byType(SossoldiPortfolioCard))
          .value;
      await _search(tester, 'vwce');
      expect(_rows, findsOneWidget);
      await _search(tester, 'US0378331005');
      expect(tester.widget<SossoldiAssetItem>(_rows).name, 'Apple Inc.');
      await _search(tester, 'pension');
      expect(_rows, findsOneWidget);
      // The card and the breakdown do not move.
      expect(
        tester
            .widget<SossoldiPortfolioCard>(find.byType(SossoldiPortfolioCard))
            .value,
        cardBefore,
      );
      expect(find.byType(SossoldiBreakdownItem), findsWidgets);
      expect(h.controller.positionsQuery, 'pension');
    });

    testWidgets('no result: empty state, clear brings the list back', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _search(tester, 'zzzzz');
      expect(_rows, findsNothing);
      expect(find.text('No positions found'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(_rows, findsNWidgets(h.repo.holdings.length));
      expect(h.controller.positionsQuery, isEmpty);
    });

    testWidgets(
      'the sheet filters by kind (several), with the dot on the button',
      (tester) async {
        final h = await _pump(tester);
        expect(
          tester
              .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
              .active,
          isFalse,
        );
        await tester.tap(find.byType(SossoldiFilterButton));
        await tester.pumpAndSettle();
        expect(find.text('Asset type'), findsOneWidget);
        for (final k in ['ETF', 'Stock', 'Bond', 'Manual asset']) {
          expect(_inSheet(k), findsOneWidget);
        }
        await tester.tap(_inSheet('Bond'));
        await tester.tap(_inSheet('Manual asset'));
        await tester.pump();
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
              .active,
          isTrue,
        );
        final kinds = tester
            .widgetList<SossoldiAssetItem>(_rows)
            .map((e) => e.typeLabel)
            .toSet();
        expect(kinds.contains('ETF'), isFalse);
        expect(kinds, contains('Bond'));
        expect(h.controller.positionKinds, hasLength(2));
        expect(find.byType(SossoldiFilterChip), findsOneWidget);
        // Search and filter work together.
        await _search(tester, 'btp');
        expect(_rows, findsOneWidget);
        // Remove with the chip: the kinds go away, the search stays.
        await tester.tap(find.bySemanticsLabel(RegExp('Remove filter')));
        await tester.pump();
        expect(h.controller.positionKinds, isEmpty);
        expect(h.controller.positionsQuery, 'btp');
      },
    );

    testWidgets(
      'Cancel in the sheet changes nothing; Reset empties the choice',
      (tester) async {
        final h = await _pump(tester);
        await tester.tap(find.byType(SossoldiFilterButton));
        await tester.pumpAndSettle();
        await tester.tap(_inSheet('ETF'));
        await tester.pump();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(h.controller.positionKinds, isEmpty);
        h.controller.setPositionKinds({});
        await tester.tap(find.byType(SossoldiFilterButton));
        await tester.pumpAndSettle();
        await tester.tap(_inSheet('ETF'));
        await tester.tap(find.text('Reset'));
        await tester.pump();
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(h.controller.positionKinds, isEmpty);
      },
    );
  });

  group('breakdown', () {
    testWidgets('region by default, sector with the switch; "other" last', (
      tester,
    ) async {
      final h = await _pump(tester);
      final regions = h.repo.portfolioBreakdown(BreakdownBy.region);
      expect(find.byType(SossoldiBreakdownItem), findsNWidgets(regions.length));
      expect(find.text('North America'), findsOneWidget);
      await tester.tap(find.text('Sector'));
      await tester.pump();
      final sectors = h.repo.portfolioBreakdown(BreakdownBy.sector);
      expect(find.byType(SossoldiBreakdownItem), findsNWidgets(sectors.length));
      final last = tester
          .widgetList<SossoldiBreakdownItem>(find.byType(SossoldiBreakdownItem))
          .last;
      expect(last.name, 'Other');
      expect(last.share, sectors.last.share);
    });

    testWidgets('the shares add up to 100% and ignore search and filters', (
      tester,
    ) async {
      await _pump(tester);
      await _search(tester, 'zzzz');
      final shares = tester
          .widgetList<SossoldiBreakdownItem>(find.byType(SossoldiBreakdownItem))
          .fold(0.0, (s, e) => s + e.share);
      expect(shares, closeTo(1, 1e-9));
    });
  });

  group('states', () {
    testWidgets('an empty portfolio: the card and an empty state', (
      tester,
    ) async {
      await _pump(
        tester,
        repository: MockRepository(
          now: _now,
          investments: (_, _) =>
              (holdings: <Holding>[], movements: <InvestmentMovement>[]),
        ),
      );
      expect(find.byType(SossoldiPortfolioCard), findsOneWidget);
      expect(find.text('No positions yet'), findsOneWidget);
      expect(find.byType(SossoldiSearchField), findsNothing);
      expect(find.byType(SossoldiBreakdownItem), findsNothing);
    });

    testWidgets('hidden amounts in the list and the breakdown', (tester) async {
      final h = await _pump(tester);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.textContaining('8.150'), findsNothing);
      expect(find.text('••••'), findsWidgets);
      expect(
        tester.widgetList<SossoldiAssetItem>(_rows).first.chart!.masked,
        isTrue,
      );
      expect(
        tester
            .widgetList<SossoldiBreakdownItem>(
              find.byType(SossoldiBreakdownItem),
            )
            .every((e) => e.masked),
        isTrue,
      );
    });

    testWidgets('Italian, dark mode', (tester) async {
      await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      expect(find.text('Posizioni'), findsWidgets);
      expect(find.text('Cerca posizioni'), findsOneWidget);
      expect(find.text('Ripartizione del portafoglio'), findsOneWidget);
      expect(find.text('Fondo pensione'.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pull to refresh updates the list', (tester) async {
      final h = await _pump(tester);
      final before = h.repo.searchPositions().first.value;
      final vwcePrice = h.repo.latestPrice('ast_vwce');
      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(InvestmentsController.refreshDelay * 2);
      await tester.pumpAndSettle();
      expect(h.repo.latestPrice('ast_vwce'), isNot(vwcePrice));
      final item = tester
          .widgetList<SossoldiAssetItem>(_rows)
          .firstWhere((e) => e.identifier.startsWith('VWCE'));
      expect(item.chart!.points.last, h.repo.latestPrice('ast_vwce'));
      expect(before, isNotNull);
    });
  });

  group('position page', () {
    testWidgets('opens from a row; header, chart, position, info, operations', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Vanguard FTSE All-World UCITS ETF Acc');
      expect(find.byType(PositionDetailScreen), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      final d = h.repo.positionDetail('hld_vwce');
      expect(find.text('VWCE – IE00BK5BQT80 – Xetra'), findsOneWidget);
      expect(find.text('Your position'), findsOneWidget);
      expect(find.text('Asset info'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.byType(SossoldiValueChart), findsOneWidget);
      final chart = tester.widget<SossoldiValueChart>(
        find.byType(SossoldiValueChart),
      );
      expect(chart.values.last, d.price);
      expect(
        chart.invested.every((v) => (v - d.averageCostMain).abs() < 0.01),
        isTrue,
      );
      expect(find.text('Average cost'), findsWidgets);
      // An ETF: its distribution and cost, not the sector.
      expect(find.text('Accumulating'), findsOneWidget);
      expect(find.text('0.19%'), findsOneWidget);
      expect(find.text('Sector'), findsNothing);
      // The whole name sits under the type tag.
      expect(find.text('Vanguard FTSE All-World UCITS ETF Acc'), findsWidgets);
      expect(find.text('Global'), findsOneWidget);
    });

    testWidgets('the periods change the chart; a tap shows the card', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Vanguard FTSE All-World UCITS ETF Acc');
      int points() => tester
          .widget<SossoldiValueChart>(find.byType(SossoldiValueChart))
          .values
          .length;
      expect(points(), 35);
      await tester.tap(find.text('5D'));
      await tester.pump();
      expect(points(), 175);
      await tester.tap(find.text('5Y'));
      await tester.pump();
      expect(
        points(),
        h.repo.priceSeries('hld_vwce', ValuePeriod.fiveYears).points.length,
      );
      final plot = tester.getRect(
        find
            .descendant(
              of: find.byType(SossoldiValueChart),
              matching: find.byType(CustomPaint),
            )
            .last,
      );
      await tester.tapAt(Offset(plot.right - 1, plot.top + 10));
      await tester.pump();
      expect(find.byType(SossoldiChartTooltip), findsOneWidget);
      expect(find.text('Price'), findsWidgets);
    });

    testWidgets('a dollar asset shows the price in dollars too', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Apple Inc.');
      expect(find.textContaining('per unit'), findsOneWidget);
      expect(find.textContaining(r'$'), findsWidgets);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets(
      'a manual asset: no chart, no asset info, but the position and operations',
      (tester) async {
        await _pump(tester);
        await _openDetail(tester, 'Vintage diver watch');
        expect(find.byType(SossoldiValueChart), findsNothing);
        expect(find.text('Asset info'), findsNothing);
        expect(find.text('Your position'), findsOneWidget);
        expect(find.text('Quantity'), findsNothing);
        expect(find.text('Invested capital'), findsOneWidget);
        expect(find.byType(SossoldiOperationItem), findsOneWidget);
      },
    );

    testWidgets(
      'operations: grouped by day, newest first, dividends in green',
      (tester) async {
        final h = await _pump(tester);
        await _openDetail(tester, 'Apple Inc.');
        final items = tester
            .widgetList<SossoldiOperationItem>(
              find.byType(SossoldiOperationItem),
            )
            .toList();
        final d = h.repo.positionDetail('hld_aapl');
        expect(
          items.length,
          d.operations.fold(0, (s, o) => s + o.operations.length),
        );
        expect(items.where((i) => i.positive).length, greaterThan(0));
        expect(items.where((i) => i.typeLabel == 'Buy').length, greaterThan(0));
        expect(
          find.byType(SossoldiDayHeader),
          findsNWidgets(d.operations.length),
        );
      },
    );

    testWidgets('the three dots: add dividend for what pays one', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Apple Inc.');
      await tester.ensureVisible(find.byType(SossoldiIconButton).last);
      await tester.tap(find.bySemanticsLabel('More actions'));
      await tester.pumpAndSettle();
      expect(find.text('Add dividend'), findsOneWidget);
      expect(find.text('Update value'), findsNothing);
      await tester.tap(find.text('Add dividend'));
      await tester.pumpAndSettle();
      // The form of a dividend (the placeholder is gone).
      expect(find.text('New movement'), findsOneWidget);
    });

    testWidgets('an accumulating ETF has no dividend and no menu', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Vanguard FTSE All-World UCITS ETF Acc');
      expect(find.bySemanticsLabel('More actions'), findsNothing);
      expect(find.text('Add dividend'), findsNothing);
    });

    testWidgets('a manual asset: update value in the menu, no dividend', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Vintage diver watch');
      await tester.ensureVisible(find.byType(SossoldiIconButton).last);
      await tester.tap(find.bySemanticsLabel('More actions'));
      await tester.pumpAndSettle();
      expect(find.text('Update value'), findsOneWidget);
      expect(find.text('Add dividend'), findsNothing);
    });

    testWidgets('asset info follows the kind: a stock and a bond', (
      tester,
    ) async {
      await _pump(tester);
      await _openDetail(tester, 'Apple Inc.');
      expect(find.text('Dividend yield'), findsOneWidget);
      expect(find.text('Sector'), findsOneWidget);
      expect(find.text('Duration'), findsNothing);
      Navigator.of(tester.element(find.byType(PositionDetailScreen))).pop();
      await tester.pumpAndSettle();
      await _openDetail(tester, 'BTP Valore Giugno 2027');
      expect(find.text('Coupon'), findsOneWidget);
      expect(find.text('Maturity'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('0.6 years'), findsOneWidget);
      expect(find.text('Dividend yield'), findsNothing);
    });

    testWidgets('operations show buys and sells', (tester) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Vanguard FTSE All-World UCITS ETF Acc');
      final labels = tester
          .widgetList<SossoldiOperationItem>(find.byType(SossoldiOperationItem))
          .map((e) => e.typeLabel)
          .toSet();
      expect(labels, containsAll(['Buy', 'Sell']));
      expect(
        h.repo
            .positionDetail('hld_vwce')
            .operations
            .expand((o) => o.operations)
            .any((o) => o.type == MovementType.sell),
        isTrue,
      );
    });

    testWidgets('hidden amounts; pull to refresh changes the price', (
      tester,
    ) async {
      final h = await _pump(tester);
      await _openDetail(tester, 'Vanguard FTSE All-World UCITS ETF Acc');
      final price = h.repo.latestPrice('ast_vwce');
      // The same as pulling the page down.
      // ignore: unawaited_futures
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
      await tester.pump();
      await tester.pump(InvestmentsController.refreshDelay * 2);
      await tester.pumpAndSettle();
      expect(h.repo.latestPrice('ast_vwce'), isNot(price));
      expect(
        tester
            .widget<SossoldiValueChart>(find.byType(SossoldiValueChart))
            .values
            .last,
        h.repo.latestPrice('ast_vwce'),
      );
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('••••'), findsWidgets);
      expect(
        tester
            .widget<SossoldiValueChart>(find.byType(SossoldiValueChart))
            .masked,
        isTrue,
      );
    });

    testWidgets('Italian, dark; long names do not overflow', (tester) async {
      await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      await _openDetail(tester, 'iShares Core MSCI EM IMI UCITS ETF Acc');
      expect(find.text('La tua posizione'), findsOneWidget);
      expect(find.text('Info sull\'asset'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
