import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/movement_edit.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  late MockRepository repo;
  setUp(() => repo = MockRepository(now: _now));

  String freeAsset([String? currency]) => repo.assetCatalog
      .firstWhere(
        (a) =>
            !repo.assetHeld(a.id) &&
            (currency == null ? true : a.currency == currency),
      )
      .id;

  test('an opening asset is a buy of today with quantity and PMC, no fee, '
      'no account', () {
    final id = freeAsset();
    final result = repo.addOpeningAsset(
      assetId: id,
      quantity: 12.5,
      averageCost: 40,
    );
    expect(result.ok, isTrue);
    final h = repo.holdings.firstWhere((h) => h.assetId == id);
    expect(h.quantity, 12.5);
    expect(h.averageCost, 40);
    expect(h.countsForNetWorth, isTrue);
    final m = repo.openingMovementOf(h.id)!;
    expect(m.type, MovementType.buy);
    expect(m.isOpening, isTrue);
    expect(m.date, repo.today);
    expect(m.fee, 0);
    expect(m.accountId, isNull);
    expect(m.quantity, 12.5);
    expect(m.price, 40);
    expect(m.amount, 500);
    expect(m.holdingId, h.id);
    expect(repo.openingAssets.map((x) => x.id), [h.id]);
    expect(repo.holdingCost(h.id), closeTo(repo.toMain(500, h.currency), 0.01));
  });

  test('it does not touch the liquidity nor any account balance', () {
    final liquidity = repo.liquidity;
    final balances = {
      for (final a in repo.accounts) a.id: repo.accountBalance(a.id),
    };
    final total = repo.totalBalance;
    repo.addOpeningAsset(assetId: freeAsset(), quantity: 100, averageCost: 55);
    repo.addOpeningAsset(manualName: 'Stamps', quantity: 1, averageCost: 3000);
    expect(repo.liquidity, liquidity);
    expect(repo.totalBalance, total);
    for (final a in repo.accounts) {
      expect(repo.accountBalance(a.id), balances[a.id]);
    }
    // liquidityAfter of the form of another buy is unchanged by it too.
    expect(repo.brokerAccounts, isNotEmpty);
  });

  test('it shows in the movements like a normal buy, and can be edited', () {
    final id = freeAsset();
    repo.addOpeningAsset(assetId: id, quantity: 10, averageCost: 20);
    final h = repo.holdings.firstWhere((h) => h.assetId == id);
    final list = repo.movementList(const MovementFilter());
    final entry = list.days.first.entries.firstWhere(
      (e) => e.movement.holdingId == h.id,
    );
    expect(entry.movement.type, MovementType.buy);
    expect(entry.movement.isOpening, isTrue);
    // Edited from its detail: still an opening buy, no account, no fee.
    final result = repo.updateMovement(
      entry.movement.id,
      changes: MovementDraft(
        type: MovementType.buy,
        date: repo.today,
        accountId: repo.brokerAccounts.first.id,
        quantity: 4,
        price: 25,
        fee: 9,
      ),
    );
    expect(result.ok, isTrue);
    final m = repo.movement(entry.movement.id);
    expect(m.isOpening, isTrue);
    expect(m.accountId, isNull);
    expect(m.fee, 0);
    expect(repo.holding(h.id).quantity, 4);
    expect(repo.holding(h.id).averageCost, 25);
  });

  test('quantity and PMC come from the whole history', () {
    final id = freeAsset();
    repo.addOpeningAsset(assetId: id, quantity: 10, averageCost: 20);
    final h = repo.holdings.firstWhere((h) => h.assetId == id);
    // Another buy later: the average is weighted.
    final other = repo.addMovement(
      MovementDraft(
        type: MovementType.buy,
        date: repo.today,
        assetId: id,
        quantity: 10,
        price: 40,
      ),
    );
    expect(other.ok, isTrue);
    expect(repo.holding(h.id).quantity, 20);
    expect(repo.holding(h.id).averageCost, closeTo(30, 0.01));
    // Changing the opening asset works the PMC out again.
    repo.updateOpeningAsset(
      h.id,
      quantity: 20,
      averageCost: 20,
      countsForNetWorth: false,
    );
    expect(repo.holding(h.id).quantity, 30);
    expect(repo.holding(h.id).averageCost, closeTo(26.6667, 0.01));
    expect(repo.holding(h.id).countsForNetWorth, isFalse);
  });

  test('the same asset cannot be added twice', () {
    final id = freeAsset();
    expect(
      repo.addOpeningAsset(assetId: id, quantity: 1, averageCost: 1).ok,
      isTrue,
    );
    expect(
      repo.addOpeningAsset(assetId: id, quantity: 1, averageCost: 1).failure,
      MovementFailure.duplicate,
    );
    // An asset the demo user already holds.
    final held = repo.holdings.firstWhere((h) => h.assetId != null).assetId!;
    expect(
      repo.addOpeningAsset(assetId: held, quantity: 1, averageCost: 1).failure,
      MovementFailure.duplicate,
    );
    // Manual assets: the name, capitals and spaces aside.
    expect(
      repo
          .addOpeningAsset(manualName: 'Stamps', quantity: 1, averageCost: 5)
          .ok,
      isTrue,
    );
    expect(
      repo
          .addOpeningAsset(manualName: '  stamps ', quantity: 1, averageCost: 5)
          .failure,
      MovementFailure.duplicate,
    );
    expect(repo.manualAssetNameTaken('STAMPS'), isTrue);
    expect(
      repo.manualAssetNameTaken('STAMPS', excluding: repo.holdings.last.id),
      isFalse,
    );
  });

  test('numbers must be above zero', () {
    final id = freeAsset();
    for (final (q, p) in [(0.0, 1.0), (1.0, 0.0), (-1.0, 1.0), (1.0, -2.0)]) {
      expect(
        repo.addOpeningAsset(assetId: id, quantity: q, averageCost: p).failure,
        MovementFailure.invalid,
      );
    }
    expect(repo.assetHeld(id), isFalse);
  });

  test('deleting an asset takes its opening buy and the position', () {
    final id = freeAsset();
    repo.addOpeningAsset(assetId: id, quantity: 3, averageCost: 7);
    final h = repo.holdings.firstWhere((h) => h.assetId == id);
    final movements = repo.movements().length;
    expect(repo.deleteOpeningAsset(h.id).ok, isTrue);
    expect(repo.holdings.any((x) => x.id == h.id), isFalse);
    expect(repo.movements().length, movements - 1);
    expect(repo.openingAssets.any((x) => x.id == h.id), isFalse);
    expect(repo.deleteOpeningAsset(h.id).failure, MovementFailure.notFound);
    // It can be added again.
    expect(
      repo.addOpeningAsset(assetId: id, quantity: 1, averageCost: 1).ok,
      isTrue,
    );
  });

  test('a sell that depends on the opening buy refuses the delete', () {
    final id = freeAsset();
    repo.addOpeningAsset(assetId: id, quantity: 10, averageCost: 10);
    final h = repo.holdings.firstWhere((h) => h.assetId == id);
    expect(
      repo
          .addMovement(
            MovementDraft(
              type: MovementType.sell,
              date: repo.today,
              holdingId: h.id,
              quantity: 5,
              price: 12,
            ),
          )
          .ok,
      isTrue,
    );
    expect(
      repo.deleteOpeningAsset(h.id).failure,
      MovementFailure.negativeQuantity,
    );
    expect(repo.holding(h.id).quantity, 5);
  });

  test('currencies: the asset one, the main one for a manual asset', () {
    final usd = freeAsset('USD');
    repo.addOpeningAsset(assetId: usd, quantity: 10, averageCost: 100);
    final h = repo.holdings.firstWhere((h) => h.assetId == usd);
    expect(h.currency, 'USD');
    expect(repo.holdingCost(h.id), closeTo(repo.toMain(1000, 'USD'), 0.01));
    repo.addOpeningAsset(manualName: 'Art', quantity: 2, averageCost: 250);
    final m = repo.holdings.firstWhere((h) => h.manualName == 'Art');
    expect(m.currency, repo.mainCurrency);
    expect(repo.holdingValue(m.id), 500);
    // A manual asset is worth what it cost until it is changed.
    repo.updateOpeningAsset(
      m.id,
      quantity: 3,
      averageCost: 250,
      countsForNetWorth: true,
    );
    expect(repo.holdingValue(m.id), 750);
  });

  test('the positions of the demo data count for the net worth', () {
    expect(repo.holdings.every((h) => h.countsForNetWorth), isTrue);
  });

  test('a tiny quantity keeps the PMC that was typed', () {
    repo.addOpeningAsset(
      manualName: 'Coin',
      quantity: 0.00012345,
      averageCost: 1250,
    );
    final h = repo.holdings.firstWhere((h) => h.manualName == 'Coin');
    expect(h.quantity, 0.00012345);
    expect(h.averageCost, 1250);
  });
}
