import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/asset.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

final _now = DateTime(2026, 10, 22, 10);
int _n = 0;

InvestmentMovement _move(
  String holding,
  MovementType type,
  DateTime date, {
  double? quantity,
  double? price,
  double? amount,
  String currency = 'EUR',
}) => InvestmentMovement(
  id: 'm${_n++}',
  holdingId: holding,
  type: type,
  date: date,
  quantity: quantity,
  price: price,
  amount: amount ?? quantity! * price!,
  currency: currency,
);

Holding _h(
  String id,
  String asset,
  double q,
  double cost, {
  String cur = 'EUR',
}) => Holding(
  id: id,
  accountId: brokerAccountId,
  assetId: asset,
  quantity: q,
  averageCost: cost,
  currency: cur,
);

MockRepository _repo(List<Holding> h, List<InvestmentMovement> m) =>
    MockRepository(
      now: _now,
      investments: (_, _) => (holdings: h, movements: m),
    );

void main() {
  final repo = MockRepository(now: _now);

  group('positions list', () {
    test('every holding, the heaviest first', () {
      final list = repo.searchPositions();
      expect(list.length, repo.holdings.length);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].value, lessThanOrEqualTo(list[i - 1].value));
      }
      expect(list.first.holdingId, 'hld_pension');
    });

    test('positions + liquidity add up to the portfolio value', () {
      final total = repo.searchPositions().fold(0.0, (s, p) => s + p.value);
      expect(total, closeTo(repo.portfolioSummary().marketValue, 0.05));
      expect(
        total + repo.liquidity,
        closeTo(repo.portfolioSummary().totalValue, 0.05),
      );
      final weights = repo.searchPositions().fold(0.0, (s, p) => s + p.weight);
      final cash = repo.liquidity / repo.portfolioSummary().totalValue;
      expect(weights + cash, closeTo(1, 1e-9));
    });

    test('P&L against the cost (quantity x PMC)', () {
      for (final p in repo.searchPositions()) {
        expect(p.cost, repo.holdingCost(p.holdingId));
        expect(p.gain, closeTo(repo.holdingGain(p.holdingId), 0.02));
        expect(p.gainPercent, closeTo(p.gain / p.cost, 1e-12));
      }
    });

    test('kinds, names, tickers; the manual ones have no ticker or chart', () {
      final byId = {for (final p in repo.searchPositions()) p.holdingId: p};
      expect(byId['hld_vwce']!.kind, PositionKind.etf);
      expect(byId['hld_aapl']!.kind, PositionKind.stock);
      expect(byId['hld_btp']!.kind, PositionKind.bond);
      final watch = byId['hld_watch']!;
      expect(watch.kind, PositionKind.manual);
      expect(watch.manualType, ManualAssetType.collectible);
      expect(watch.name, 'Vintage diver watch');
      expect(watch.ticker, isNull);
      expect(watch.isin, isNull);
      expect(watch.monthPrices, isEmpty);
      expect(watch.monthChange, isNull);
      final vwce = byId['hld_vwce']!;
      expect(vwce.ticker, 'VWCE');
      expect(vwce.isin, 'IE00BK5BQT80');
      expect(vwce.monthPrices.length, greaterThan(15));
      expect(
        vwce.monthChange,
        closeTo(vwce.monthPrices.last / vwce.monthPrices.first - 1, 1e-12),
      );
    });

    test('the last point of the mini chart is the current price', () {
      final vwce = repo.searchPositions().firstWhere(
        (p) => p.holdingId == 'hld_vwce',
      );
      expect(vwce.monthPrices.last, repo.latestPrice('ast_vwce'));
    });
  });

  group('search', () {
    test('by name, ticker and ISIN, case-insensitive', () {
      List<String> ids(String q) => [
        for (final p in repo.searchPositions(query: q)) p.holdingId,
      ];
      expect(ids('vanguard'), ['hld_vwce']);
      expect(ids('VWCE'), ['hld_vwce']);
      expect(ids('ie00bk5bqt80'), ['hld_vwce']);
      expect(ids('  apple '), ['hld_aapl']);
      expect(ids('painting'), ['hld_painting']);
      expect(ids('zzz'), isEmpty);
      expect(ids(''), hasLength(repo.holdings.length));
    });

    test('a partial ISIN or ticker finds it', () {
      expect(repo.searchPositions(query: 'IE00').isNotEmpty, isTrue);
      expect(
        repo.searchPositions(query: 'nv').map((p) => p.ticker),
        contains('NVDA'),
      );
    });
  });

  group('filters', () {
    test('one kind, several kinds, none = all', () {
      Set<String> ids(Set<PositionKind> k) => {
        for (final p in repo.searchPositions(kinds: k)) p.holdingId,
      };
      expect(ids({PositionKind.etf}), {'hld_vwce', 'hld_eimi'});
      expect(ids({PositionKind.bond}), {'hld_btp'});
      expect(ids({PositionKind.manual}), {
        'hld_pension',
        'hld_watch',
        'hld_painting',
      });
      expect(ids({PositionKind.stock, PositionKind.bond}), {
        'hld_aapl',
        'hld_eni',
        'hld_nvda',
        'hld_btp',
      });
      expect(ids({}), hasLength(repo.holdings.length));
    });

    test('search and filters together; weights do not change', () {
      final all = {
        for (final p in repo.searchPositions()) p.holdingId: p.weight,
      };
      final r = repo.searchPositions(query: 'a', kinds: {PositionKind.stock});
      for (final p in r) {
        expect(p.kind, PositionKind.stock);
        expect(p.weight, all[p.holdingId]);
      }
      expect(
        repo.searchPositions(query: 'vwce', kinds: {PositionKind.bond}),
        isEmpty,
      );
    });

    test('no positions: empty', () {
      expect(_repo(const [], const []).searchPositions(), isEmpty);
    });
  });

  group('portfolio breakdown', () {
    test('by region: real regions of the catalog, "other" last', () {
      final rows = repo.portfolioBreakdown(BreakdownBy.region);
      final names = rows.map((r) => r.name).toList();
      expect(names, contains('Global'));
      expect(names.last, isNull); // bonds and manual assets
      expect(names.where((n) => n == null).length, 1);
      final named = rows
          .where((r) => r.name != null)
          .map((r) => r.value)
          .toList();
      expect([...named]..sort((a, b) => b.compareTo(a)), named);
    });

    test('by sector, same rule', () {
      final rows = repo.portfolioBreakdown(BreakdownBy.sector);
      expect(rows.map((r) => r.name), contains('Diversified'));
      expect(rows.last.name, isNull);
    });

    test('liquidity excluded: shares add up to 1 of the positions', () {
      for (final by in BreakdownBy.values) {
        final rows = repo.portfolioBreakdown(by);
        expect(rows.fold(0.0, (s, r) => s + r.share), closeTo(1, 1e-9));
        expect(
          rows.fold(0.0, (s, r) => s + r.value),
          closeTo(repo.portfolioSummary().marketValue, 0.05),
        );
      }
    });

    test(
      'with only a bond everything is "other"; with no positions, nothing',
      () {
        final r = _repo(
          [_h('b', 'ast_btp_valore_27', 10, 100)],
          [
            _move(
              'b',
              MovementType.buy,
              DateTime(2026, 1, 5),
              quantity: 10,
              price: 100,
            ),
          ],
        );
        final rows = r.portfolioBreakdown(BreakdownBy.region);
        expect(rows.single.name, isNull);
        expect(rows.single.share, closeTo(1, 1e-12));
        expect(
          _repo(const [], const []).portfolioBreakdown(BreakdownBy.region),
          isEmpty,
        );
      },
    );
  });

  group('position detail', () {
    test('price, today change, position and asset info', () {
      final d = repo.positionDetail('hld_vwce');
      final history = repo.priceHistory('ast_vwce');
      expect(d.price, history.last.price);
      expect(d.priceMain, history.last.price);
      expect(
        d.todayChange,
        closeTo(
          history.last.price / history[history.length - 2].price - 1,
          1e-12,
        ),
      );
      expect(d.quantity, repo.holding('hld_vwce').quantity);
      expect(d.averageCost, repo.holding('hld_vwce').averageCost);
      expect(d.position.value, repo.holdingValue('hld_vwce'));
      expect(d.type, AssetType.etf);
      expect(d.sector, 'Diversified');
      expect(d.region, 'Global');
      expect(d.assetCurrency, 'EUR');
      expect(d.hasOtherCurrency('EUR'), isFalse);
      expect(d.hasOtherCurrency('USD'), isTrue);
    });

    test('a dollar asset: price in dollars and in the main currency', () {
      final d = repo.positionDetail('hld_aapl');
      expect(d.assetCurrency, 'USD');
      expect(d.priceMain, closeTo(d.price! * 0.9234, 1e-9));
      expect(d.averageCostMain, closeTo(d.averageCost * 0.9234, 0.01));
      expect(d.hasOtherCurrency(repo.mainCurrency), isTrue);
    });

    test('manual asset: no price, no asset info', () {
      final d = repo.positionDetail('hld_watch');
      expect(d.price, isNull);
      expect(d.priceMain, isNull);
      expect(d.todayChange, isNull);
      expect(d.type, isNull);
      expect(d.sector, isNull);
      expect(d.region, isNull);
      expect(d.position.value, 3400);
      expect(d.operations.single.operations.single.type, MovementType.buy);
    });

    test(
      'operations: buys, sells, dividends, by day, newest first, no fees',
      () {
        final d = repo.positionDetail('hld_aapl');
        final days = d.operations.map((o) => o.day).toList();
        expect(days.length, days.toSet().length);
        for (var i = 1; i < days.length; i++) {
          expect(days[i].isBefore(days[i - 1]), isTrue);
        }
        final all = d.operations.expand((o) => o.operations).toList();
        expect(all.every((o) => o.type != MovementType.cost), isTrue);
        expect(all.any((o) => o.type == MovementType.dividend), isTrue);
        expect(all.any((o) => o.type == MovementType.buy), isTrue);
        // The expected dividend is not an operation yet.
        expect(all.every((o) => !o.date.isAfter(repo.today)), isTrue);
        final expected = repo.expectedDividends.where(
          (m) => m.holdingId == 'hld_aapl',
        );
        expect(expected, isNotEmpty);
        // Buys of the holding match its quantity.
        final bought = all
            .where((o) => o.type == MovementType.buy)
            .fold(0.0, (s, o) => s + o.quantity!);
        final sold = all
            .where((o) => o.type == MovementType.sell)
            .fold(0.0, (s, o) => s + o.quantity!);
        expect(bought - sold, closeTo(d.quantity, 1e-9));
      },
    );

    test('a day with two operations groups them; one operation is fine', () {
      final r = _repo(
        [_h('h', 'ast_vwce', 8, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 3, 2),
            quantity: 5,
            price: 100,
          ),
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 3, 2, 15),
            quantity: 3,
            price: 100,
          ),
        ],
      );
      final d = r.positionDetail('h');
      expect(d.operations.single.operations.length, 2);
      final one = _repo(
        [_h('h', 'ast_vwce', 5, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 3, 2),
            quantity: 5,
            price: 100,
          ),
        ],
      );
      expect(
        one.positionDetail('h').operations.single.operations,
        hasLength(1),
      );
    });

    test('weight is the share of the portfolio with the liquidity', () {
      final d = repo.positionDetail('hld_vwce');
      expect(
        d.position.weight,
        closeTo(d.position.value / repo.portfolioSummary().totalValue, 1e-12),
      );
    });
  });

  group('price series', () {
    test('every period: last point is the price, "invested" is the PMC', () {
      for (final p in ValuePeriod.values) {
        final s = repo.priceSeries('hld_vwce', p);
        expect(s.points, isNotEmpty, reason: '$p');
        expect(s.points.last.value, repo.latestPrice('ast_vwce'), reason: '$p');
        expect(
          s.points.every(
            (e) => e.invested == repo.holding('hld_vwce').averageCost,
          ),
          isTrue,
        );
        for (var i = 1; i < s.points.length; i++) {
          expect(s.points[i].time.isAfter(s.points[i - 1].time), isTrue);
        }
      }
      expect(repo.priceSeries('hld_vwce', ValuePeriod.day).points.length, 35);
      expect(
        repo.priceSeries('hld_vwce', ValuePeriod.fiveDays).points.length,
        175,
      );
    });

    test('longer periods start earlier; 5Y has years of prices', () {
      DateTime start(ValuePeriod p) =>
          repo.priceSeries('hld_vwce', p).points.first.time;
      expect(
        start(ValuePeriod.year).isBefore(start(ValuePeriod.sixMonths)),
        isTrue,
      );
      expect(start(ValuePeriod.fiveYears).year, lessThan(_now.year - 3));
    });

    test('a dollar asset is converted; the PMC too', () {
      final s = repo.priceSeries('hld_aapl', ValuePeriod.month);
      expect(
        s.points.last.value,
        closeTo(repo.latestPrice('ast_aapl') * 0.9234, 1e-6),
      );
      expect(
        s.points.first.invested,
        closeTo(repo.holding('hld_aapl').averageCost * 0.9234, 1e-6),
      );
    });

    test('a manual asset has no series', () {
      expect(repo.priceSeries('hld_watch', ValuePeriod.year).points, isEmpty);
    });

    test('a refresh moves the list and the detail together', () {
      final r = MockRepository(now: _now);
      final before = r.positionDetail('hld_vwce');
      r.refreshPrices();
      final after = r.positionDetail('hld_vwce');
      expect(after.price, isNot(before.price));
      expect(
        r
            .searchPositions()
            .firstWhere((p) => p.holdingId == 'hld_vwce')
            .monthPrices
            .last,
        after.price,
      );
      expect(
        r.priceSeries('hld_vwce', ValuePeriod.month).points.last.value,
        after.price,
      );
    });
  });

  group('asset info and income', () {
    test('each kind has its own details', () {
      final etf = repo.positionDetail('hld_vwce').asset!;
      expect(etf.distribution, AssetDistribution.accumulating);
      expect(etf.ter, isNotNull);
      final stock = repo.positionDetail('hld_eni').asset!;
      expect(stock.dividendYield, greaterThan(0));
      final bond = repo.positionDetail('hld_btp').asset!;
      expect(bond.coupon, isNotNull);
      expect(bond.maturity!.isAfter(_now), isTrue);
      expect(bond.duration, greaterThan(0));
      expect(repo.positionDetail('hld_watch').asset, isNull);
    });

    test('only what pays something can record a dividend', () {
      expect(
        repo.positionDetail('hld_vwce').paysIncome,
        isFalse,
      ); // accumulating
      expect(repo.positionDetail('hld_eimi').paysIncome, isFalse);
      expect(repo.positionDetail('hld_aapl').paysIncome, isTrue);
      expect(repo.positionDetail('hld_btp').paysIncome, isTrue);
      expect(repo.positionDetail('hld_watch').paysIncome, isFalse);
    });

    test('the mock has buys and sells to show', () {
      final sells = [
        for (final h in repo.holdings)
          for (final d in repo.positionDetail(h.id).operations)
            for (final o in d.operations)
              if (o.type == MovementType.sell) h.id,
      ];
      expect(
        sells.toSet(),
        containsAll(['hld_vwce', 'hld_aapl', 'hld_eni', 'hld_nvda']),
      );
    });
  });

  test('the mini chart of the list is the 1M chart of the page', () {
    for (final p in repo.searchPositions().where((p) => !p.isManual)) {
      final month = repo.priceSeries(p.holdingId, ValuePeriod.month).points;
      expect(
        month.map((e) => e.value).toList(),
        p.monthPrices,
        reason: p.holdingId,
      );
    }
  });
}
