import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/movement_edit.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

final _now = DateTime(2026, 10, 22, 10);

/// A repository with no positions: only what the test adds.
MockRepository _empty() => MockRepository(
  now: _now,
  investments: (_, _) =>
      (holdings: <Holding>[], movements: <InvestmentMovement>[]),
);

MovementDraft _buy({
  String asset = 'ast_vwce',
  required double qty,
  required double price,
  double fee = 0,
  DateTime? date,
}) => MovementDraft(
  type: MovementType.buy,
  assetId: asset,
  date: date ?? DateTime(2026, 3, 2),
  quantity: qty,
  price: price,
  fee: fee,
);

MovementDraft _sell(
  String holding, {
  required double qty,
  required double price,
  double fee = 0,
  DateTime? date,
}) => MovementDraft(
  type: MovementType.sell,
  holdingId: holding,
  date: date ?? DateTime(2026, 6, 1),
  quantity: qty,
  price: price,
  fee: fee,
);

void main() {
  group('buy', () {
    test(
      'a new asset creates the position, with the commission in the cost',
      () {
        final r = _empty();
        final liquidity = r.liquidity;
        var heard = 0;
        r.addListener(() => heard++);
        final res = r.addMovement(_buy(qty: 10, price: 100, fee: 5));
        expect(res.ok, isTrue);
        expect(heard, 1);
        final h = r.holdings.single;
        expect(h.assetId, 'ast_vwce');
        expect(h.quantity, 10);
        expect(h.averageCost, 100.5);
        expect(r.holdingCost(h.id), 1005);
        expect(r.liquidity, closeTo(liquidity - 1005, 0.001));
        expect(r.movement(res.movementId!).accountId, brokerAccountId);
      },
    );

    test('a second buy: weighted average, commissions included', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100, fee: 5));
      r.addMovement(
        _buy(qty: 30, price: 120, fee: 5, date: DateTime(2026, 4, 1)),
      );
      final h = r.holdings.single;
      expect(h.quantity, 40);
      expect(h.averageCost, closeTo((1005 + 3605) / 40, 1e-3));
    });

    test('a manual asset: a new position valued at what it cost', () {
      final r = _empty();
      final res = r.addMovement(
        MovementDraft(
          type: MovementType.buy,
          manualName: 'Gold coins',
          manualType: ManualAssetType.collectible,
          date: DateTime(2026, 5, 5),
          quantity: 1,
          price: 2500,
        ),
      );
      expect(res.ok, isTrue);
      final h = r.holdings.single;
      expect(h.isManual, isTrue);
      expect(h.manualName, 'Gold coins');
      expect(r.holdingValue(h.id), 2500);
      expect(r.holdingCost(h.id), 2500);
      // A second manual asset is a position of its own.
      r.addMovement(
        MovementDraft(
          type: MovementType.buy,
          manualName: 'Gold coins',
          manualType: ManualAssetType.collectible,
          date: DateTime(2026, 5, 6),
          quantity: 1,
          price: 100,
        ),
      );
      expect(r.holdings.length, 2);
    });

    test('a dollar asset: price in dollars, liquidity and cost converted', () {
      final r = _empty();
      final liquidity = r.liquidity;
      r.addMovement(_buy(asset: 'ast_aapl', qty: 2, price: 100, fee: 1));
      final h = r.holdings.single;
      expect(h.currency, 'USD');
      expect(h.averageCost, 100.5);
      expect(r.holdingCost(h.id), closeTo(201 * 0.9234, 0.01));
      expect(r.liquidity, closeTo(liquidity - 201 * 0.9234, 0.01));
    });

    test('a buy bigger than the liquidity is allowed: it goes below zero', () {
      final r = _empty();
      final res = r.addMovement(_buy(qty: 1000, price: 100));
      expect(res.ok, isTrue);
      expect(r.liquidity, lessThan(0));
      // The form can warn beforehand.
      final r2 = _empty();
      expect(r2.liquidityAfter(_buy(qty: 1000, price: 100))!, lessThan(0));
    });

    test('checks first: not valid, in the future, nothing changes', () {
      final r = _empty();
      for (final bad in [
        _buy(qty: 0, price: 10),
        _buy(qty: 1, price: 0),
        _buy(qty: -1, price: 5),
        _buy(qty: 1, price: 5, fee: -1),
        _buy(qty: 1, price: 5, date: DateTime(2026, 12, 1)),
      ]) {
        final res = r.addMovement(bad);
        expect(res.failure, MovementFailure.invalid);
      }
      expect(
        r.addMovement(MovementDraft(type: MovementType.buy, date: _d)).failure,
        MovementFailure.invalid,
      );
      expect(r.holdings, isEmpty);
      expect(r.movements(), isEmpty);
    });

    test('dryRun checks without changing anything', () {
      final r = _empty();
      var heard = 0;
      r.addListener(() => heard++);
      expect(r.addMovement(_buy(qty: 1, price: 1), dryRun: true).ok, isTrue);
      expect(heard, 0);
      expect(r.holdings, isEmpty);
    });
  });

  group('sell', () {
    MockRepository held() {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100, fee: 5));
      return r;
    }

    test('partial: quantity down, average cost the same, liquidity up', () {
      final r = held();
      final liquidity = r.liquidity;
      final id = r.holdings.single.id;
      final res = r.addMovement(_sell(id, qty: 4, price: 150, fee: 2));
      expect(res.ok, isTrue);
      expect(r.holdings.single.quantity, 6);
      expect(r.holdings.single.averageCost, 100.5);
      expect(r.liquidity, closeTo(liquidity + 4 * 150 - 2, 0.001));
    });

    test('everything: the position closes and goes from the lists', () {
      final r = held();
      final id = r.holdings.single.id;
      final res = r.addMovement(_sell(id, qty: 10, price: 150));
      expect(res.ok, isTrue);
      expect(r.holdings, isEmpty);
      expect(r.searchPositions(), isEmpty);
      expect(r.portfolioValue, 0);
      // Its movements are still there, and so is the position for them.
      expect(r.holding(id).isClosed, isTrue);
      expect(r.movementList(const MovementFilter()).days, isNotEmpty);
    });

    test('more than held is refused, and nothing changes', () {
      final r = held();
      final id = r.holdings.single.id;
      final liquidity = r.liquidity;
      final res = r.addMovement(_sell(id, qty: 11, price: 150));
      expect(res.failure, MovementFailure.negativeQuantity);
      expect(res.failedOn, DateTime(2026, 6, 1));
      expect(r.holdings.single.quantity, 10);
      expect(r.liquidity, liquidity);
    });

    test('before the buy is refused; the same day as the buy is fine', () {
      final r = held();
      final id = r.holdings.single.id;
      expect(
        r
            .addMovement(
              _sell(id, qty: 1, price: 1, date: DateTime(2026, 2, 1)),
            )
            .failure,
        MovementFailure.negativeQuantity,
      );
      expect(
        r
            .addMovement(
              _sell(id, qty: 1, price: 1, date: DateTime(2026, 3, 2)),
            )
            .ok,
        isTrue,
      );
    });

    test('an asset not held cannot be sold; a sold out one neither', () {
      final r = held();
      expect(
        r
            .addMovement(
              MovementDraft(
                type: MovementType.sell,
                holdingId: 'hld_nothing',
                date: _d,
                quantity: 1,
                price: 1,
              ),
            )
            .ok,
        isFalse,
      );
      final id = r.holdings.single.id;
      r.addMovement(_sell(id, qty: 10, price: 150));
      expect(
        r.addMovement(_sell(id, qty: 1, price: 150)).failure,
        MovementFailure.negativeQuantity,
      );
    });

    test('buying it again after selling out reopens the same position', () {
      final r = held();
      final id = r.holdings.single.id;
      r.addMovement(_sell(id, qty: 10, price: 150));
      r.addMovement(_buy(qty: 3, price: 200, date: DateTime(2026, 7, 1)));
      expect(r.holdings.single.id, id);
      expect(r.holdings.single.quantity, 3);
      expect(r.holdings.single.averageCost, 200);
    });
  });

  group('dividend and cost', () {
    test('a dividend adds to the liquidity; in the future it is "up next"', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      final liquidity = r.liquidity;
      r.addMovement(
        MovementDraft(
          type: MovementType.dividend,
          holdingId: id,
          date: DateTime(2026, 9, 1),
          amount: 12.5,
        ),
      );
      expect(r.liquidity, closeTo(liquidity + 12.5, 0.001));
      final future = r.addMovement(
        MovementDraft(
          type: MovementType.dividend,
          holdingId: id,
          date: DateTime(2026, 11, 20),
          amount: 7,
        ),
      );
      expect(future.ok, isTrue);
      expect(
        r.liquidity,
        closeTo(liquidity + 12.5, 0.001),
        reason: 'not paid yet',
      );
      final list = r.movementList(const MovementFilter());
      expect(list.upNext.single.movement.amount, 7);
      expect(r.expectedDividends.single.amount, 7);
    });

    test('a cost, with or without an asset, takes from the liquidity', () {
      final r = _empty();
      final liquidity = r.liquidity;
      final res = r.addMovement(
        MovementDraft(
          type: MovementType.cost,
          date: DateTime(2026, 9, 1),
          amount: 12,
          description: 'Custody',
        ),
      );
      expect(res.ok, isTrue);
      expect(r.liquidity, closeTo(liquidity - 12, 0.001));
      expect(r.movement(res.movementId!).holdingId, isNull);
      expect(r.movement(res.movementId!).description, 'Custody');
    });

    test('amounts have to be positive; a cost in the future is refused', () {
      final r = _empty();
      expect(
        r
            .addMovement(
              MovementDraft(
                type: MovementType.cost,
                date: DateTime(2026, 9, 1),
                amount: 0,
              ),
            )
            .ok,
        isFalse,
      );
      expect(
        r
            .addMovement(
              MovementDraft(
                type: MovementType.cost,
                date: DateTime(2026, 12, 1),
                amount: 5,
              ),
            )
            .ok,
        isFalse,
      );
      expect(
        r
            .addMovement(
              MovementDraft(
                type: MovementType.dividend,
                date: DateTime(2026, 9, 1),
                amount: 5,
              ),
            )
            .ok,
        isFalse,
        reason: 'no asset',
      );
    });
  });

  group('change and delete', () {
    test('a new price and quantity: the history is played again', () {
      final r = _empty();
      final a = r.addMovement(_buy(qty: 10, price: 100, fee: 5));
      r.addMovement(_buy(qty: 10, price: 200, date: DateTime(2026, 4, 1)));
      final liquidity = r.liquidity;
      final res = r.updateMovement(
        a.movementId!,
        changes: MovementDraft(
          type: MovementType.buy,
          date: DateTime(2026, 3, 2),
          quantity: 20,
          price: 110,
          fee: 0,
        ),
      );
      expect(res.ok, isTrue);
      final h = r.holdings.single;
      expect(h.quantity, 30);
      expect(h.averageCost, closeTo((20 * 110 + 10 * 200) / 30, 1e-3));
      // The old effect is cancelled and the new one applied.
      expect(r.liquidity, closeTo(liquidity + 1005 - 2200, 0.001));
    });

    test('moving a buy after a sell that needs it is refused', () {
      final r = _empty();
      final a = r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      r.addMovement(_sell(id, qty: 5, price: 120));
      final res = r.updateMovement(
        a.movementId!,
        changes: MovementDraft(
          type: MovementType.buy,
          date: DateTime(2026, 8, 1),
        ),
      );
      expect(res.failure, MovementFailure.negativeQuantity);
      expect(r.movement(a.movementId!).date, DateTime(2026, 3, 2));
      expect(r.holdings.single.quantity, 5);
    });

    test('moving a sell before its buy is refused; after is fine', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      final s = r.addMovement(_sell(id, qty: 5, price: 120));
      expect(
        r
            .updateMovement(
              s.movementId!,
              changes: MovementDraft(
                type: MovementType.sell,
                date: DateTime(2026, 1, 1),
              ),
            )
            .failure,
        MovementFailure.negativeQuantity,
      );
      expect(
        r
            .updateMovement(
              s.movementId!,
              changes: MovementDraft(
                type: MovementType.sell,
                date: DateTime(2026, 8, 1),
              ),
            )
            .ok,
        isTrue,
      );
    });

    test('a sell cannot be raised over what is held', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      final s = r.addMovement(_sell(id, qty: 5, price: 120));
      expect(
        r
            .updateMovement(
              s.movementId!,
              changes: MovementDraft(
                type: MovementType.sell,
                date: DateTime(2026, 6, 1),
                quantity: 11,
              ),
            )
            .failure,
        MovementFailure.negativeQuantity,
      );
      expect(
        r
            .updateMovement(
              s.movementId!,
              changes: MovementDraft(
                type: MovementType.sell,
                date: DateTime(2026, 6, 1),
                quantity: 10,
              ),
            )
            .ok,
        isTrue,
      );
      expect(r.holdings, isEmpty, reason: 'sold out');
    });

    test('invalid new values change nothing', () {
      final r = _empty();
      final a = r.addMovement(_buy(qty: 10, price: 100));
      for (final bad in [
        MovementDraft(
          type: MovementType.buy,
          date: DateTime(2026, 3, 2),
          quantity: 0,
        ),
        MovementDraft(
          type: MovementType.buy,
          date: DateTime(2026, 3, 2),
          price: -1,
        ),
        MovementDraft(type: MovementType.buy, date: DateTime(2027, 3, 2)),
      ]) {
        expect(
          r.updateMovement(a.movementId!, changes: bad).failure,
          MovementFailure.invalid,
        );
      }
      expect(
        r
            .updateMovement(
              'nope',
              changes: MovementDraft(type: MovementType.buy, date: _d),
            )
            .failure,
        MovementFailure.notFound,
      );
      expect(r.holdings.single.quantity, 10);
    });

    test(
      'delete: back as if it never happened; refused if a sell needs it',
      () {
        final r = _empty();
        final liquidity = r.liquidity;
        final a = r.addMovement(_buy(qty: 10, price: 100, fee: 5));
        final b = r.addMovement(
          _buy(qty: 10, price: 200, date: DateTime(2026, 4, 1)),
        );
        final id = r.holdings.single.id;
        expect(r.deleteMovement(b.movementId!).ok, isTrue);
        expect(r.holdings.single.quantity, 10);
        expect(r.holdings.single.averageCost, 100.5);
        r.addMovement(_sell(id, qty: 10, price: 120));
        expect(
          r.deleteMovement(a.movementId!).failure,
          MovementFailure.negativeQuantity,
        );
        expect(r.movements().any((m) => m.id == a.movementId), isTrue);
        expect(r.liquidity, isNot(liquidity));
      },
    );

    test('deleting the only movement of an asset removes the position', () {
      final r = _empty();
      final liquidity = r.liquidity;
      final a = r.addMovement(_buy(qty: 10, price: 100, fee: 5));
      final id = r.holdings.single.id;
      expect(r.deleteMovement(a.movementId!).ok, isTrue);
      expect(r.holdings, isEmpty);
      expect(() => r.holding(id), throwsStateError);
      expect(r.liquidity, closeTo(liquidity, 0.001));
    });

    test('deleting a sell reopens what it sold', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      final s = r.addMovement(_sell(id, qty: 10, price: 120));
      expect(r.holdings, isEmpty);
      expect(r.deleteMovement(s.movementId!).ok, isTrue);
      expect(r.holdings.single.quantity, 10);
    });

    test('dry runs say the same without changing anything', () {
      final r = _empty();
      final a = r.addMovement(_buy(qty: 10, price: 100));
      final id = r.holdings.single.id;
      r.addMovement(_sell(id, qty: 5, price: 120));
      var heard = 0;
      r.addListener(() => heard++);
      expect(
        r.deleteMovement(a.movementId!, dryRun: true).failure,
        MovementFailure.negativeQuantity,
      );
      expect(
        r
            .updateMovement(
              a.movementId!,
              dryRun: true,
              changes: MovementDraft(
                type: MovementType.buy,
                date: DateTime(2026, 3, 2),
                quantity: 20,
              ),
            )
            .ok,
        isTrue,
      );
      expect(heard, 0);
      expect(r.holdings.single.quantity, 5);
    });
  });

  group('everything follows', () {
    test('value, invested, allocation and positions after a buy', () {
      final r = _empty();
      r.addMovement(
        _buy(qty: 10, price: 100, fee: 5, date: DateTime(2026, 3, 2)),
      );
      final s = r.portfolioSummary();
      expect(s.cost, 1005);
      expect(s.marketValue, closeTo(10 * r.latestPrice('ast_vwce'), 0.01));
      expect(r.searchPositions().single.cost, 1005);
      final series = r.marketValueSeries(ValuePeriod.year);
      expect(series.points.last.invested, 1005);
      expect(series.points.last.value, s.marketValue);
      expect(
        r
            .assetAllocation(AllocationMode.singleAsset)
            .fold(0.0, (a, e) => a + e.share),
        closeTo(1, 1e-9),
      );
    });

    test('the invested series goes down after a sell, at the average cost', () {
      final r = _empty();
      r.addMovement(_buy(qty: 10, price: 100, fee: 10));
      final id = r.holdings.single.id;
      r.addMovement(_sell(id, qty: 5, price: 150));
      final last = r.marketValueSeries(ValuePeriod.year).points.last;
      expect(last.invested, closeTo(505, 0.01));
    });

    test('the generated data keeps its liquidity and its numbers', () {
      final r = MockRepository(now: _now);
      expect(r.liquidity, 2700);
      final before = r.portfolioSummary().totalValue;
      final res = r.addMovement(_buy(qty: 1, price: 100));
      expect(res.ok, isTrue);
      expect(r.liquidity, closeTo(2600, 0.001));
      expect(
        r.portfolioSummary().totalValue,
        closeTo(before - 100 + r.latestPrice('ast_vwce'), 0.01),
      );
    });

    test('editing a generated movement works the same way', () {
      final r = MockRepository(now: _now);
      final buys = r
          .movements(holdingId: 'hld_vwce')
          .where((m) => m.type == MovementType.buy)
          .toList();
      final first = buys.last; // oldest
      final liquidity = r.liquidity;
      final qtyBefore = r.holding('hld_vwce').quantity;
      expect(r.deleteMovement(first.id).ok, isTrue);
      expect(r.holding('hld_vwce').quantity, qtyBefore - first.quantity!);
      expect(r.liquidity, closeTo(liquidity + first.cashEffect.abs(), 0.01));
    });
  });

  group('the list', () {
    final r = MockRepository(now: _now);

    test('up next: expected dividends; the rest by day, newest first', () {
      final l = r.movementList(
        const MovementFilter(period: MovementPeriod.all),
      );
      expect(l.upNext.every((e) => e.movement.date.isAfter(r.today)), isTrue);
      expect(
        l.upNext.every((e) => e.movement.type == MovementType.dividend),
        isTrue,
      );
      final days = l.days.map((d) => d.day).toList();
      for (var i = 1; i < days.length; i++) {
        expect(days[i].isBefore(days[i - 1]), isTrue);
      }
      expect(
        l.days
            .expand((d) => d.entries)
            .every((e) => !e.movement.date.isAfter(r.today)),
        isTrue,
      );
    });

    test('the periods', () {
      int count(MovementPeriod p) => r
          .movementList(MovementFilter(period: p))
          .days
          .fold(0, (s, d) => s + d.entries.length);
      expect(
        count(MovementPeriod.currentMonth),
        lessThanOrEqualTo(count(MovementPeriod.last3Months)),
      );
      expect(
        count(MovementPeriod.last3Months),
        lessThanOrEqualTo(count(MovementPeriod.last12Months)),
      );
      expect(
        count(MovementPeriod.currentYear),
        lessThanOrEqualTo(count(MovementPeriod.all)),
      );
      expect(
        count(MovementPeriod.last12Months),
        lessThanOrEqualTo(count(MovementPeriod.all)),
      );
      final all = r.movementList(
        const MovementFilter(period: MovementPeriod.all),
      );
      expect(
        all.days.fold(0, (s, d) => s + d.entries.length),
        r.movements().where((m) => !m.date.isAfter(r.today)).length,
      );
      for (final d in r.movementList(const MovementFilter()).days) {
        expect(d.day.year, 2026, reason: 'the current year is the default');
      }
    });

    test('search: asset name, ticker, ISIN and description', () {
      List<MovementEntry> find(String q) => r
          .movementList(MovementFilter(query: q, period: MovementPeriod.all))
          .days
          .expand((d) => d.entries)
          .toList();
      expect(find('vwce'), isNotEmpty);
      expect(find('vwce').every((e) => e.ticker == 'VWCE'), isTrue);
      expect(
        find('IE00BK5BQT80').every((e) => e.isin == 'IE00BK5BQT80'),
        isTrue,
      );
      expect(find('apple').every((e) => e.name == 'Apple Inc.'), isTrue);
      final custody = find('custody');
      expect(custody, isNotEmpty);
      expect(
        custody.every((e) => e.movement.type == MovementType.cost),
        isTrue,
      );
      expect(find('zzzz'), isEmpty);
    });

    test(
      'filters: type, kind, one asset; they leave out costs without asset',
      () {
        final byType = r.movementList(
          MovementFilter(
            period: MovementPeriod.all,
            types: {MovementType.sell},
          ),
        );
        expect(
          byType.days
              .expand((d) => d.entries)
              .every((e) => e.movement.type == MovementType.sell),
          isTrue,
        );
        expect(byType.upNext, isEmpty);
        final bonds = r.movementList(
          MovementFilter(
            period: MovementPeriod.all,
            kinds: {PositionKind.bond},
          ),
        );
        expect(
          bonds.days
              .expand((d) => d.entries)
              .every((e) => e.kind == PositionKind.bond),
          isTrue,
        );
        final one = r.movementList(
          MovementFilter(period: MovementPeriod.all, holdingId: 'hld_aapl'),
        );
        final entries = one.days.expand((d) => d.entries);
        expect(
          entries.every((e) => e.movement.holdingId == 'hld_aapl'),
          isTrue,
        );
        expect(
          one.upNext.every((e) => e.movement.holdingId == 'hld_aapl'),
          isTrue,
        );
        expect(
          r
              .movementList(
                MovementFilter(
                  period: MovementPeriod.all,
                  kinds: {PositionKind.etf, PositionKind.stock},
                ),
              )
              .days
              .expand((d) => d.entries)
              .any((e) => e.kind == null),
          isFalse,
        );
      },
    );

    test('an entry carries the name, ticker and ISIN of its position', () {
      final e = r
          .movementList(
            MovementFilter(period: MovementPeriod.all, holdingId: 'hld_vwce'),
          )
          .days
          .first
          .entries
          .first;
      expect(e.name, 'Vanguard FTSE All-World UCITS ETF Acc');
      expect(e.ticker, 'VWCE');
      expect(e.holdingOpen, isTrue);
      expect(e.kind, PositionKind.etf);
      final cost = r
          .movementList(
            MovementFilter(
              period: MovementPeriod.all,
              types: {MovementType.cost},
            ),
          )
          .days
          .expand((d) => d.entries)
          .firstWhere((e) => e.movement.holdingId == null);
      expect(cost.name, isNull);
      expect(cost.movement.description, isNotNull);
    });

    test(
      'the total of an entry: the buy with the commission, the sell without',
      () {
        final l = r.movementList(
          MovementFilter(period: MovementPeriod.all, holdingId: 'hld_vwce'),
        );
        for (final e in l.days.expand((d) => d.entries)) {
          final m = e.movement;
          if (m.type == MovementType.buy) {
            expect(e.total, closeTo(m.amount + m.fee, 1e-9));
          }
          if (m.type == MovementType.sell) {
            expect(e.total, closeTo(m.amount - m.fee, 1e-9));
          }
        }
      },
    );

    test('a filter says how many it changes from the default', () {
      expect(const MovementFilter().activeCount, 0);
      expect(const MovementFilter(period: MovementPeriod.all).activeCount, 1);
      expect(
        MovementFilter(types: {MovementType.buy}, holdingId: 'x').activeCount,
        2,
      );
      expect(const MovementFilter(query: 'a').isRefined, isTrue);
      expect(const MovementFilter(), const MovementFilter());
    });

    test('assets to filter by: those with movements, sold out ones too', () {
      final repo = _empty();
      repo.addMovement(_buy(qty: 1, price: 1));
      final id = repo.holdings.single.id;
      repo.addMovement(_sell(id, qty: 1, price: 1));
      expect(repo.movementAssets().map((a) => a.holdingId), [id]);
      expect(repo.holdings, isEmpty);
    });
  });
}

final _d = DateTime(2026, 6, 1);
