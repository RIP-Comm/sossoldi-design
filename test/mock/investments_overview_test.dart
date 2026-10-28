import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/data/asset_catalog_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/portfolio.dart';
import 'package:sossoldi/mock/models/price_point.dart';

final _now = DateTime(2026, 10, 22, 10); // a Thursday

/// A repository with only these positions and movements.
MockRepository _repo(
  List<Holding> holdings,
  List<InvestmentMovement> movements, {
  DateTime? now,
  DateTime Function()? clock,
}) => MockRepository(
  now: now ?? _now,
  clock: clock,
  investments: (_, _) => (holdings: holdings, movements: movements),
);

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

Holding _holding(
  String id,
  String assetId,
  double quantity,
  double cost, {
  String currency = 'EUR',
}) => Holding(
  id: id,
  accountId: brokerAccountId,
  assetId: assetId,
  quantity: quantity,
  averageCost: cost,
  currency: currency,
);

double _price(MockRepository r, String assetId, DateTime on) =>
    r.priceHistory(assetId).lastWhere((p) => !p.date.isAfter(on)).price;

void main() {
  group('mock prices', () {
    final repo = MockRepository(now: _now);

    test('intraday: 35 points a day for the last 5 trading days', () {
      for (final a in repo.assetCatalog) {
        final history = repo.priceHistory(a.id);
        final intraday = repo.intradayPrices(a.id);
        expect(intraday.length, 5 * intradayPointsPerDay, reason: a.id);
        final lastDays = history
            .skip(history.length - 5)
            .map((p) => p.date)
            .toList();
        for (var d = 0; d < 5; d++) {
          final day = intraday.sublist(
            d * intradayPointsPerDay,
            (d + 1) * intradayPointsPerDay,
          );
          expect(day.first.date.hour, 9);
          expect(day.first.date.minute, 0);
          expect(day.last.date.hour, 17);
          expect(day.last.date.minute, 30);
          for (var i = 1; i < day.length; i++) {
            expect(
              day[i].date.difference(day[i - 1].date),
              const Duration(minutes: 15),
            );
          }
          expect(
            DateTime(
              day.first.date.year,
              day.first.date.month,
              day.first.date.day,
            ),
            lastDays[d],
          );
          // The last point of the day is the official close.
          final close = history[history.length - 5 + d].price;
          expect(day.last.price, close, reason: '${a.id} day $d');
          expect(day.every((p) => p.price > 0), isTrue);
        }
      }
    });

    test('the last year of prices is the same as before', () {
      // The calibrated year ends on its target return.
      final vwce = repo.priceHistory('ast_vwce');
      final yearAgo = vwce.firstWhere(
        (p) => !p.date.isBefore(repo.today.subtract(const Duration(days: 365))),
      );
      expect(yearAgo.price, 112);
      expect(vwce.last.price / yearAgo.price, closeTo(1.18, 0.001));
    });
  });

  group('portfolio summary', () {
    test('value = positions + liquidity; P&L only on the positions', () {
      final repo = MockRepository(now: _now);
      final s = repo.portfolioSummary();
      expect(s.marketValue, repo.portfolioValue);
      expect(s.liquidity, repo.liquidity);
      expect(s.totalValue, closeTo(s.marketValue + s.liquidity, 1e-9));
      expect(s.cost, repo.portfolioCost);
      expect(s.gain, closeTo(s.marketValue - s.cost, 1e-9));
      expect(s.gainPercent, closeTo(s.gain / s.cost, 1e-12));
      // The liquidity is the broker account balance.
      expect(s.liquidity, repo.accountBalance(brokerAccountId));
    });

    test('unrealized P&L against quantity x PMC, in the main currency', () {
      final repo = _repo(
        [_holding('h', 'ast_aapl', 10, 100, currency: 'USD')],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 1, 5),
            quantity: 10,
            price: 100,
            currency: 'USD',
          ),
        ],
      );
      final price = repo.latestPrice('ast_aapl');
      final s = repo.portfolioSummary();
      // Fixed rate: 1 USD = 0.9234 EUR.
      expect(s.cost, closeTo(10 * 100 * 0.9234, 0.01));
      expect(s.marketValue, closeTo(10 * price * 0.9234, 0.01));
      expect(s.gain, closeTo(10 * (price - 100) * 0.9234, 0.02));
      expect(s.gainPercent, closeTo(price / 100 - 1, 1e-3));
      // In dollars the amounts are the same trade, no conversion.
      repo.setMainCurrency('USD');
      final usd = repo.portfolioSummary();
      expect(usd.currency, 'USD');
      expect(usd.cost, closeTo(1000, 0.01));
      expect(usd.marketValue, closeTo(10 * price, 0.01));
    });

    test('a loss is negative', () {
      final repo = _repo(
        [_holding('h', 'ast_vwce', 10, 1000)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 1, 5),
            quantity: 10,
            price: 1000,
          ),
        ],
      );
      expect(repo.portfolioSummary().gain, lessThan(0));
      expect(repo.portfolioSummary().gainPercent, lessThan(0));
    });

    test('no positions: only the liquidity, no P&L', () {
      final s = _repo(const [], const []).portfolioSummary();
      expect(s.marketValue, 0);
      expect(s.cost, 0);
      expect(s.gain, 0);
      expect(s.gainPercent, 0);
      expect(s.totalValue, s.liquidity);
    });
  });

  group('the "invested" series', () {
    test('buys at cost, sells at the average cost, fees left out', () {
      final repo = _repo(
        [_holding('h', 'ast_vwce', 6, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 6, 1),
            quantity: 4,
            price: 90,
          ),
          _move('h', MovementType.cost, DateTime(2026, 6, 1), amount: 2.95),
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 7, 1),
            quantity: 4,
            price: 110,
          ),
          // Sells 2 units at the average cost 100: takes out 200.
          _move(
            'h',
            MovementType.sell,
            DateTime(2026, 8, 3),
            quantity: 2,
            price: 150,
          ),
        ],
      );
      final series = repo.marketValueSeries(ValuePeriod.sixMonths);
      double investedOn(DateTime d) =>
          series.points.lastWhere((p) => !p.time.isAfter(d)).invested;
      expect(investedOn(DateTime(2026, 6, 15)), 360);
      expect(investedOn(DateTime(2026, 7, 15)), 800);
      expect(investedOn(DateTime(2026, 8, 5)), 600);
      expect(series.points.last.invested, 600);
    });

    test('the manual assets count at their purchase value', () {
      final repo = _repo(
        [
          const Holding(
            id: 'm',
            manualName: 'Watch',
            manualType: ManualAssetType.collectible,
            manualValue: 3000,
            manualValuedAt: null,
            quantity: 1,
            averageCost: 2000,
            currency: 'EUR',
          ),
        ],
        [
          _move(
            'm',
            MovementType.buy,
            DateTime(2026, 3, 2),
            quantity: 1,
            price: 2000,
          ),
        ],
      );
      final series = repo.marketValueSeries(ValuePeriod.year);
      expect(series.points.first.invested, 2000);
      // Not valued yet: the value stays at what it cost.
      expect(series.points.first.value, 2000);
      expect(series.points.last.invested, 2000);
    });

    test('a manual asset moves to its entered value from the valuation', () {
      final repo = _repo(
        [
          Holding(
            id: 'm',
            manualName: 'Watch',
            manualType: ManualAssetType.collectible,
            manualValue: 3000,
            manualValuedAt: DateTime(2026, 9, 1),
            quantity: 1,
            averageCost: 2000,
            currency: 'EUR',
          ),
        ],
        [
          _move(
            'm',
            MovementType.buy,
            DateTime(2026, 3, 2),
            quantity: 1,
            price: 2000,
          ),
        ],
      );
      final p = repo.marketValueSeries(ValuePeriod.year).points;
      expect(p.firstWhere((e) => e.time == DateTime(2026, 8, 31)).value, 2000);
      expect(p.firstWhere((e) => e.time == DateTime(2026, 9, 1)).value, 3000);
      expect(p.last.value, repo.portfolioValue);
    });

    test('with the generated data, the last point is the cost', () {
      final repo = MockRepository(now: _now);
      for (final period in ValuePeriod.values) {
        final last = repo.marketValueSeries(period).points.last;
        expect(
          last.invested,
          closeTo(repo.portfolioCost, 1),
          reason: '$period',
        );
      }
    });
  });

  group('the market value series', () {
    final repo = MockRepository(now: _now);

    test(
      'the last point is the value of the positions, whatever the period',
      () {
        for (final period in ValuePeriod.values) {
          final series = repo.marketValueSeries(period);
          expect(series.currency, 'EUR');
          expect(series.points, isNotEmpty, reason: '$period');
          expect(
            series.points.last.value,
            repo.portfolioValue,
            reason: '$period',
          );
          // So the card is the last point plus the liquidity.
          expect(
            series.points.last.value + repo.liquidity,
            closeTo(repo.portfolioSummary().totalValue, 1e-9),
          );
        }
      },
    );

    test('points are in time order, one per 15 minutes or one per day', () {
      for (final period in ValuePeriod.values) {
        final s = repo.marketValueSeries(period);
        for (var i = 1; i < s.points.length; i++) {
          expect(s.points[i].time.isAfter(s.points[i - 1].time), isTrue);
        }
      }
      expect(repo.marketValueSeries(ValuePeriod.day).points.length, 35);
      expect(repo.marketValueSeries(ValuePeriod.fiveDays).points.length, 175);
      expect(repo.marketValueSeries(ValuePeriod.day).isIntraday, isTrue);
      expect(repo.marketValueSeries(ValuePeriod.month).isIntraday, isFalse);
    });

    test('longer periods start earlier', () {
      DateTime start(ValuePeriod p) =>
          repo.marketValueSeries(p).points.first.time;
      expect(
        start(ValuePeriod.fiveDays).isBefore(start(ValuePeriod.day)),
        isTrue,
      );
      expect(
        start(ValuePeriod.month).isBefore(start(ValuePeriod.fiveDays)),
        isTrue,
      );
      expect(
        start(ValuePeriod.sixMonths).isBefore(start(ValuePeriod.month)),
        isTrue,
      );
      expect(
        start(ValuePeriod.year).isBefore(start(ValuePeriod.sixMonths)),
        isTrue,
      );
      expect(
        start(ValuePeriod.fiveYears).isBefore(start(ValuePeriod.year)),
        isTrue,
      );
      expect(start(ValuePeriod.yearToDate), DateTime(2026, 1, 1));
    });

    test('1D is the last trading day: on a weekend, Friday', () {
      final saturday = MockRepository(now: DateTime(2026, 10, 24, 12));
      final day = saturday.marketValueSeries(ValuePeriod.day);
      expect(day.points.first.time, DateTime(2026, 10, 23, 9));
      expect(day.points.last.time, DateTime(2026, 10, 23, 17, 30));
    });

    test('5Y starts at the first purchase when the history is shorter', () {
      // First buy two years ago: 5Y does not go further back.
      final twoYears = DateTime(2024, 10, 22);
      final r = _repo(
        [_holding('h', 'ast_vwce', 5, 100)],
        [_move('h', MovementType.buy, twoYears, quantity: 5, price: 100)],
      );
      final s = r.marketValueSeries(ValuePeriod.fiveYears);
      expect(s.points.first.time, twoYears);
      expect(s.points.first.invested, 500);
      // Before the buy there is nothing; from the buy on it follows the price.
      expect(
        s.points.first.value,
        closeTo(5 * _price(r, 'ast_vwce', twoYears), 0.01),
      );
      // The same for a period shorter than the history.
      final month = r.marketValueSeries(ValuePeriod.month);
      expect(month.points.first.time.isBefore(DateTime(2026, 9, 22)), isFalse);
    });

    test('a first purchase after the period leaves it without points', () {
      final r = _repo(
        [_holding('h', 'ast_vwce', 5, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 10, 22),
            quantity: 5,
            price: 100,
          ),
        ],
      );
      // Bought today: the 1D chart is on the last trading day (Thursday),
      // which has the buy; 5D starts at that day.
      expect(r.marketValueSeries(ValuePeriod.day).points, isNotEmpty);
      final fiveDays = r.marketValueSeries(ValuePeriod.fiveDays).points;
      expect(fiveDays.first.time, DateTime(2026, 10, 22, 9));
      final r2 = _repo(
        [_holding('h', 'ast_vwce', 5, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 10, 24),
            quantity: 5,
            price: 100,
          ),
        ],
        now: DateTime(2026, 10, 24, 12),
      );
      // Bought on Saturday: the last trading day (Friday) is before it, but
      // the last point has the units bought.
      expect(r2.marketValueSeries(ValuePeriod.day).points, isEmpty);
    });

    test('no positions: empty series for every period', () {
      final r = _repo(const [], const []);
      for (final p in ValuePeriod.values) {
        expect(r.marketValueSeries(p).points, isEmpty);
      }
    });

    test('a foreign currency asset is converted at the fixed rate', () {
      final r = _repo(
        [_holding('h', 'ast_aapl', 3, 150, currency: 'USD')],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 1, 5),
            quantity: 3,
            price: 150,
            currency: 'USD',
          ),
        ],
      );
      final p = r.marketValueSeries(ValuePeriod.month).points;
      expect(
        p.last.value,
        closeTo(3 * r.latestPrice('ast_aapl') * 0.9234, 0.01),
      );
      expect(p.last.invested, closeTo(3 * 150 * 0.9234, 0.01));
      r.setMainCurrency('USD');
      expect(
        r.marketValueSeries(ValuePeriod.month).points.last.value,
        closeTo(3 * r.latestPrice('ast_aapl'), 0.01),
      );
    });

    test('difference and percentage of a point', () {
      final p = ValuePoint(time: _now, value: 1100, invested: 1000);
      expect(p.difference, 100);
      expect(p.differencePercent, closeTo(0.1, 1e-12));
      expect(
        ValuePoint(time: _now, value: 5, invested: 0).differencePercent,
        0,
      );
    });
  });

  group('asset allocation', () {
    final repo = MockRepository(now: _now);

    test('by asset class: shares add up to the total, liquidity last', () {
      final slices = repo.assetAllocation(AllocationMode.assetClass);
      final total = repo.portfolioSummary().totalValue;
      expect(slices.fold(0.0, (s, e) => s + e.share), closeTo(1, 1e-9));
      expect(slices.fold(0.0, (s, e) => s + e.value), closeTo(total, 0.05));
      expect(slices.last.kind, AllocationKind.liquidity);
      expect(slices.last.value, repo.liquidity);
      final classes = slices.where((s) => s.kind == AllocationKind.assetClass);
      expect(classes.map((s) => s.assetClass).toSet().length, classes.length);
      // Largest first (liquidity apart).
      final values = classes.map((s) => s.value).toList();
      expect([...values]..sort((a, b) => b.compareTo(a)), values);
      // The manual assets are "other".
      expect(
        classes.firstWhere((s) => s.assetClass == AssetClass.other).value,
        repo.holdingValue('hld_pension') +
            repo.holdingValue('hld_watch') +
            repo.holdingValue('hld_painting'),
      );
    });

    test('by single asset: the top 5, the rest in "other"', () {
      final slices = repo.assetAllocation(AllocationMode.singleAsset);
      final assets = slices.where((s) => s.kind == AllocationKind.asset);
      expect(assets.length, 5);
      expect(slices.where((s) => s.kind == AllocationKind.other).length, 1);
      expect(slices.last.kind, AllocationKind.liquidity);
      expect(slices.fold(0.0, (s, e) => s + e.share), closeTo(1, 1e-9));
      final values = assets.map((s) => s.value).toList();
      expect([...values]..sort((a, b) => b.compareTo(a)), values);
      // Every asset in the top 5 is worth more than anything in "other".
      final other = slices.firstWhere((s) => s.kind == AllocationKind.other);
      final rest = repo.holdings
          .where((h) => !assets.any((s) => s.holdingId == h.id))
          .map((h) => repo.holdingValue(h.id))
          .reduce((a, b) => a > b ? a : b);
      expect(values.last, greaterThanOrEqualTo(rest));
      expect(other.value, greaterThan(0));
    });

    test('five assets or fewer: no "other"', () {
      final r = _repo(
        [
          _holding('a', 'ast_vwce', 1, 100),
          _holding('b', 'ast_aapl', 1, 100, currency: 'USD'),
        ],
        [
          _move(
            'a',
            MovementType.buy,
            DateTime(2026, 5, 1),
            quantity: 1,
            price: 100,
          ),
          _move(
            'b',
            MovementType.buy,
            DateTime(2026, 5, 1),
            quantity: 1,
            price: 100,
            currency: 'USD',
          ),
        ],
      );
      final slices = r.assetAllocation(AllocationMode.singleAsset);
      expect(slices.where((s) => s.kind == AllocationKind.other), isEmpty);
      expect(slices.where((s) => s.kind == AllocationKind.asset).length, 2);
    });

    test('no positions: just the liquidity; nothing at all with no money', () {
      final r = _repo(const [], const []);
      final slices = r.assetAllocation(AllocationMode.assetClass);
      expect(slices.single.kind, AllocationKind.liquidity);
      expect(slices.single.share, 1);
      final broke = MockRepository(
        now: _now,
        accounts: const [],
        investments: (_, _) =>
            (holdings: <Holding>[], movements: <InvestmentMovement>[]),
      );
      expect(broke.assetAllocation(AllocationMode.assetClass), isEmpty);
    });
  });

  group('digest rule a: concentration', () {
    MockRepository one(double qty) => _repo(
      [_holding('h', 'ast_vwce', qty, 100)],
      [
        _move(
          'h',
          MovementType.buy,
          DateTime(2026, 5, 1),
          quantity: qty,
          price: 100,
        ),
      ],
    );

    test('one asset above 40% of the whole portfolio: info message', () {
      final r = one(500);
      final m = r.digestConcentration()!;
      expect(m.rule, InvestmentDigestRule.concentration);
      expect(m.holdingId, 'h');
      final s = r.portfolioSummary();
      expect(m.percent, closeTo(r.holdingValue('h') / s.totalValue, 1e-12));
      expect(m.percent!, greaterThan(0.4));
    });

    test('the threshold: the liquidity counts in the total', () {
      // Worth a bit more than 40% of positions + 2.700 € of liquidity.
      final price = _price(one(1), 'ast_vwce', _now);
      final qty = (2700 * 0.4 / 0.6 / price) * 0.99; // just under
      expect(one(qty).digestConcentration(), isNull);
      final over = (2700 * 0.4 / 0.6 / price) * 1.05; // just over
      expect(one(over).digestConcentration(), isNotNull);
    });

    test('a spread portfolio, or none at all, has nothing to say', () {
      expect(_repo(const [], const []).digestConcentration(), isNull);
    });
  });

  group('digest rules b and c: the last month', () {
    // 10 units bought long ago; the month change is the price change.
    MockRepository with10() => _repo(
      [_holding('h', 'ast_vwce', 10, 100)],
      [
        _move(
          'h',
          MovementType.buy,
          DateTime(2026, 1, 5),
          quantity: 10,
          price: 100,
        ),
      ],
    );

    test('growth: the amount is the change of value, success', () {
      final r = with10();
      final then = _price(r, 'ast_vwce', DateTime(2026, 9, 22));
      final nowPrice = r.latestPrice('ast_vwce');
      expect(nowPrice, greaterThan(then), reason: 'the mock grows');
      final m = r.digestMonthGrowth()!;
      expect(m.rule, InvestmentDigestRule.monthGrowth);
      expect(m.amount, closeTo(10 * (nowPrice - then), 0.02));
      expect(m.percent, closeTo(nowPrice / then - 1, 1e-3));
      expect(r.digestMonthDrop(), isNull);
    });

    test('what was invested in the month is not growth', () {
      // Bought on the 1st at that day's market price.
      final probe = MockRepository(now: _now);
      final onFirst = _price(probe, 'ast_vwce', DateTime(2026, 10, 1));
      final r = _repo(
        [_holding('h', 'ast_vwce', 20, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 1, 5),
            quantity: 10,
            price: 100,
          ),
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 10, 1),
            quantity: 10,
            price: onFirst,
          ),
        ],
      );
      final then = _price(r, 'ast_vwce', DateTime(2026, 9, 22));
      final now = r.latestPrice('ast_vwce');
      // Ten units from the start gain (now - then); the ten bought on the
      // 1st gain only (now - their price): the money put in is not a gain.
      final m = r.digestMonthGrowth()!;
      expect(m.amount, closeTo(10 * (now - then) + 10 * (now - onFirst), 0.05));
    });

    test('a drop of more than 5%: warning with amount and percentage', () {
      final r = with10();
      // Push the last price down by 20% with the refresh-like edit.
      final lastPrice = r.latestPrice('ast_vwce');
      r.debugSetLastPrice('ast_vwce', lastPrice * 0.8);
      final m = r.digestMonthDrop()!;
      expect(m.rule, InvestmentDigestRule.monthDrop);
      expect(m.amount!, greaterThan(0));
      expect(m.percent!, greaterThan(0.05));
      expect(r.digestMonthGrowth(), isNull);
    });

    test('a small drop is not worth a message', () {
      final r = with10();
      final then = _price(r, 'ast_vwce', DateTime(2026, 9, 22));
      r.debugSetLastPrice('ast_vwce', then * 0.97); // -3% on the month
      expect(r.digestMonthDrop(), isNull);
      expect(r.digestMonthGrowth(), isNull);
    });

    test('nothing a month ago: no comparison', () {
      final r = _repo(
        [_holding('h', 'ast_vwce', 10, 100)],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 10, 15),
            quantity: 10,
            price: 100,
          ),
        ],
      );
      expect(r.digestMonthGrowth(), isNull);
      expect(r.digestMonthDrop(), isNull);
    });
  });

  group('digest rule d: expected dividend', () {
    MockRepository dividendsIn(List<int> inDays) => _repo(
      [_holding('h', 'ast_aapl', 10, 100, currency: 'USD')],
      [
        _move(
          'h',
          MovementType.buy,
          DateTime(2026, 1, 5),
          quantity: 10,
          price: 100,
          currency: 'USD',
        ),
        for (final d in inDays)
          _move(
            'h',
            MovementType.dividend,
            DateTime(2026, 10, 22 + d),
            quantity: 10,
            price: 0.5,
            currency: 'USD',
          ),
      ],
    );

    test('one dividend within 7 days: info with its amount', () {
      final m = dividendsIn([5]).digestExpectedDividend()!;
      expect(m.rule, InvestmentDigestRule.expectedDividend);
      expect(m.count, 1);
      expect(m.holdingId, 'h');
      expect(m.days, 7);
      expect(m.amount, closeTo(5 * 0.9234, 0.01)); // in euros
    });

    test('the window: day 7 is in, day 8 is out; today has been paid', () {
      expect(dividendsIn([7]).digestExpectedDividend(), isNotNull);
      expect(dividendsIn([8]).digestExpectedDividend(), isNull);
      expect(dividendsIn([0]).digestExpectedDividend(), isNull);
    });

    test('several are grouped, without a single asset', () {
      final m = dividendsIn([2, 6]).digestExpectedDividend()!;
      expect(m.count, 2);
      expect(m.holdingId, isNull);
      expect(m.amount, closeTo(10 * 0.9234, 0.01));
    });
  });

  group('the whole digest', () {
    test('nothing applies: one neutral message', () {
      final d = _repo(const [], const []).investmentDigest();
      expect(d.single.rule, InvestmentDigestRule.allGood);
    });

    test('by priority, at most three', () {
      final r = _repo(
        [_holding('h', 'ast_aapl', 100, 100, currency: 'USD')],
        [
          _move(
            'h',
            MovementType.buy,
            DateTime(2026, 1, 5),
            quantity: 100,
            price: 100,
            currency: 'USD',
          ),
          _move(
            'h',
            MovementType.dividend,
            DateTime(2026, 10, 25),
            quantity: 100,
            price: 0.5,
            currency: 'USD',
          ),
        ],
      );
      r.debugSetLastPrice('ast_aapl', r.latestPrice('ast_aapl') * 0.8);
      final rules = r.investmentDigest().map((e) => e.rule).toList();
      // Concentration, the drop and the dividend (the growth does not apply).
      expect(rules, [
        InvestmentDigestRule.concentration,
        InvestmentDigestRule.monthDrop,
        InvestmentDigestRule.expectedDividend,
      ]);
    });

    test('with the generated data it is valid every day', () {
      for (var d = 0; d < 40; d++) {
        final r = MockRepository(now: DateTime(2026, 9, 20 + d, 12));
        final digest = r.investmentDigest();
        expect(digest, isNotEmpty);
        expect(digest.length, lessThanOrEqualTo(3));
      }
    });
  });

  group('refresh', () {
    test('prices move a little, the time is the clock', () {
      var clock = DateTime(2026, 10, 22, 10, 0);
      final repo = MockRepository(now: _now, clock: () => clock);
      expect(repo.pricesUpdatedAt, _now.subtract(const Duration(minutes: 4)));
      final before = {
        for (final a in repo.assetCatalog) a.id: repo.latestPrice(a.id),
      };
      final valueBefore = repo.portfolioSummary().totalValue;
      var notified = 0;
      repo.addListener(() => notified++);
      clock = DateTime(2026, 10, 22, 10, 7);
      repo.refreshPrices();
      expect(notified, 1);
      expect(repo.pricesUpdatedAt, DateTime(2026, 10, 22, 10, 7));
      expect(repo.currentTime, DateTime(2026, 10, 22, 10, 7));
      var moved = 0;
      for (final a in repo.assetCatalog) {
        final change = repo.latestPrice(a.id) / before[a.id]! - 1;
        expect(change.abs(), lessThanOrEqualTo(0.0041), reason: a.id);
        if (change != 0) moved++;
      }
      expect(moved, greaterThan(15));
      expect(repo.portfolioSummary().totalValue, isNot(valueBefore));
    });

    test('the charts follow: the last point is the new value', () {
      final repo = MockRepository(now: _now);
      repo.refreshPrices();
      for (final period in ValuePeriod.values) {
        expect(
          repo.marketValueSeries(period).points.last.value,
          repo.portfolioValue,
          reason: '$period',
        );
      }
      // The intraday close and the daily close agree.
      for (final a in repo.assetCatalog) {
        expect(repo.intradayPrices(a.id).last.price, repo.latestPrice(a.id));
      }
    });

    test('it is repeatable, and each refresh is different', () {
      List<double> run(int times) {
        final r = MockRepository(now: _now);
        for (var i = 0; i < times; i++) {
          r.refreshPrices();
        }
        return [for (final a in r.assetCatalog) r.latestPrice(a.id)];
      }

      expect(run(1), run(1));
      expect(run(2), isNot(run(1)));
    });

    test('with a fixed now, the clock is that now', () {
      expect(MockRepository(now: _now).currentTime, _now);
    });
  });

  test('a price point is a date and a price', () {
    expect(PricePoint(date: DateTime.utc(2026), price: 1).price, 1);
  });
}
