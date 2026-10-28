// User positions and their investment movements. Movements are generated
// from a plan per position, then quantity and average cost (PMC) are
// derived from them, so the two always agree.

import '../date_utils.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/investment_movement.dart';
import '../models/price_point.dart';
import 'account_data.dart';

/// Broker fee per trade, in EUR.
const tradeFee = 2.95;

class _Trade {
  const _Trade(this.daysAgo, this.quantity, {this.sell = false});

  final int daysAgo;
  final double quantity;
  final bool sell;
}

class _Dividend {
  /// Negative [daysAgo] means an expected future payment.
  const _Dividend(this.daysAgo, this.perUnit);

  final int daysAgo;
  final double perUnit;
}

class _CatalogPlan {
  const _CatalogPlan(
    this.holdingId,
    this.assetId,
    this.trades, {
    this.dividends = const [],
  });

  final String holdingId;
  final String assetId;
  final List<_Trade> trades;
  final List<_Dividend> dividends;
}

class _ManualPlan {
  const _ManualPlan(
    this.holdingId,
    this.name,
    this.type, {
    required this.boughtDaysAgo,
    required this.purchaseValue,
    required this.currentValue,
    required this.valuedDaysAgo,
  });

  final String holdingId;
  final String name;
  final ManualAssetType type;
  final int boughtDaysAgo;
  final double purchaseValue;
  final double currentValue;
  final int valuedDaysAgo;
}

// Purchases cover about four years, so that the 5Y chart has something to
// show: a quarterly plan on the global ETF, a few older buys on the others.
final _catalogPlans = [
  _CatalogPlan('hld_vwce', 'ast_vwce', [
    for (var days = 1100; days > 330; days -= 90) _Trade(days, 3),
    const _Trade(330, 4),
    const _Trade(270, 4),
    const _Trade(210, 4),
    const _Trade(150, 4),
    const _Trade(120, 3, sell: true),
    const _Trade(90, 4),
    const _Trade(30, 4),
  ]),
  _CatalogPlan('hld_eimi', 'ast_eimi', [
    const _Trade(1450, 40),
    const _Trade(780, 30),
    const _Trade(300, 60),
    const _Trade(120, 50),
  ]),
  _CatalogPlan(
    'hld_aapl',
    'ast_aapl',
    [
      const _Trade(1000, 4),
      const _Trade(640, 3),
      const _Trade(420, 2, sell: true),
      const _Trade(280, 6),
      const _Trade(160, 4),
    ],
    dividends: [
      const _Dividend(790, 0.22),
      const _Dividend(560, 0.23),
      const _Dividend(380, 0.24),
      const _Dividend(200, 0.25),
      const _Dividend(110, 0.25),
      const _Dividend(20, 0.26),
      const _Dividend(-25, 0.26),
    ],
  ),
  _CatalogPlan(
    'hld_eni',
    'ast_eni',
    [
      const _Trade(700, 100),
      const _Trade(400, 30, sell: true),
      const _Trade(250, 150),
    ],
    dividends: [
      const _Dividend(600, 0.2),
      const _Dividend(420, 0.22),
      const _Dividend(150, 0.25),
      const _Dividend(-40, 0.25),
    ],
  ),
  _CatalogPlan('hld_btp', 'ast_btp_valore_27', [const _Trade(200, 30)]),
  _CatalogPlan('hld_nvda', 'ast_nvda', [
    const _Trade(760, 10),
    const _Trade(340, 20),
    const _Trade(60, 8, sell: true),
  ]),
];

const _manualPlans = [
  _ManualPlan(
    'hld_pension',
    'Supplementary pension fund',
    ManualAssetType.pensionFund,
    boughtDaysAgo: 1500,
    purchaseValue: 7200,
    currentValue: 8150,
    valuedDaysAgo: 20,
  ),
  _ManualPlan(
    'hld_watch',
    'Vintage diver watch',
    ManualAssetType.collectible,
    boughtDaysAgo: 500,
    purchaseValue: 2800,
    currentValue: 3400,
    valuedDaysAgo: 45,
  ),
  _ManualPlan(
    'hld_painting',
    'Contemporary painting',
    ManualAssetType.art,
    boughtDaysAgo: 400,
    purchaseValue: 1500,
    currentValue: 1300,
    valuedDaysAgo: 90,
  ),
];

/// Last price on or before [date] (the first one if [date] is earlier).
double priceOn(List<PricePoint> history, DateTime date) {
  var price = history.first.price;
  for (final p in history) {
    if (p.date.isAfter(date)) break;
    price = p.price;
  }
  return price;
}

({List<Holding> holdings, List<InvestmentMovement> movements})
buildHoldingsAndMovements({
  required DateTime today,
  required List<Asset> catalog,
  required Map<String, List<PricePoint>> priceHistories,
}) {
  final holdings = <Holding>[];
  final movements = <InvestmentMovement>[];
  var counter = 0;
  String nextId() => 'mov_${(++counter).toString().padLeft(3, '0')}';
  DateTime daysAgo(int days) => addDays(today, -days);

  for (final plan in _catalogPlans) {
    final asset = catalog.firstWhere((a) => a.id == plan.assetId);
    final history = priceHistories[asset.id]!;
    final trades = [...plan.trades]
      ..sort((a, b) => b.daysAgo.compareTo(a.daysAgo));
    final holdingMoves = <InvestmentMovement>[];

    for (final trade in trades) {
      final date = daysAgo(trade.daysAgo);
      final price = priceOn(history, date);
      final move = InvestmentMovement(
        id: nextId(),
        holdingId: plan.holdingId,
        accountId: brokerAccountId,
        type: trade.sell ? MovementType.sell : MovementType.buy,
        date: date,
        quantity: trade.quantity,
        price: price,
        fee: tradeFee,
        amount: round2(trade.quantity * price),
        currency: asset.currency,
      );
      movements.add(move);
      holdingMoves.add(move);
    }

    for (final dividend in plan.dividends) {
      final date = daysAgo(dividend.daysAgo);
      // Units held on the payment date (all units for future payments).
      final held = trades
          .where((t) => !daysAgo(t.daysAgo).isAfter(date))
          .fold(0.0, (sum, t) => sum + (t.sell ? -t.quantity : t.quantity));
      movements.add(
        InvestmentMovement(
          id: nextId(),
          holdingId: plan.holdingId,
          accountId: brokerAccountId,
          type: MovementType.dividend,
          date: date,
          quantity: held,
          price: dividend.perUnit,
          amount: round2(held * dividend.perUnit),
          currency: asset.currency,
        ),
      );
    }

    final state = replayHolding(holdingMoves).state!;
    holdings.add(
      Holding(
        id: plan.holdingId,
        accountId: brokerAccountId,
        assetId: asset.id,
        quantity: state.quantity,
        averageCost: (state.averageCost * 10000).round() / 10000,
        currency: asset.currency,
      ),
    );
  }

  for (final plan in _manualPlans) {
    movements.add(
      InvestmentMovement(
        id: nextId(),
        holdingId: plan.holdingId,
        accountId: brokerAccountId,
        type: MovementType.buy,
        date: daysAgo(plan.boughtDaysAgo),
        quantity: 1,
        price: plan.purchaseValue,
        amount: plan.purchaseValue,
        currency: 'EUR',
      ),
    );
    holdings.add(
      Holding(
        id: plan.holdingId,
        manualName: plan.name,
        manualType: plan.type,
        manualValue: plan.currentValue,
        manualValuedAt: daysAgo(plan.valuedDaysAgo),
        quantity: 1,
        averageCost: plan.purchaseValue,
        currency: 'EUR',
      ),
    );
  }

  // Costs that are not part of a trade: custody and stamp duty.
  for (final (days, amount, text) in [
    (95, 12.0, 'Broker custody fee'),
    (270, 12.0, 'Broker custody fee'),
    (410, 36.5, 'Stamp duty on the portfolio'),
  ]) {
    movements.add(
      InvestmentMovement(
        id: nextId(),
        accountId: brokerAccountId,
        type: MovementType.cost,
        date: daysAgo(days),
        amount: amount,
        currency: 'EUR',
        description: text,
      ),
    );
  }

  movements.sort((a, b) => a.date.compareTo(b.date));
  return (holdings: holdings, movements: movements);
}
