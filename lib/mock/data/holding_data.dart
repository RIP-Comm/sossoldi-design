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

const _catalogPlans = [
  _CatalogPlan('hld_vwce', 'ast_vwce', [
    _Trade(330, 4),
    _Trade(270, 4),
    _Trade(210, 4),
    _Trade(150, 4),
    _Trade(90, 4),
    _Trade(30, 4),
  ]),
  _CatalogPlan('hld_eimi', 'ast_eimi', [_Trade(300, 60), _Trade(120, 50)]),
  _CatalogPlan(
    'hld_aapl',
    'ast_aapl',
    [_Trade(280, 6), _Trade(160, 4)],
    dividends: [
      _Dividend(200, 0.25),
      _Dividend(110, 0.25),
      _Dividend(20, 0.26),
      _Dividend(-25, 0.26),
    ],
  ),
  _CatalogPlan(
    'hld_eni',
    'ast_eni',
    [_Trade(250, 150)],
    dividends: [_Dividend(150, 0.25), _Dividend(-40, 0.25)],
  ),
  _CatalogPlan('hld_btp', 'ast_btp_valore_27', [_Trade(200, 30)]),
  _CatalogPlan('hld_nvda', 'ast_nvda', [
    _Trade(340, 20),
    _Trade(60, 8, sell: true),
  ]),
];

const _manualPlans = [
  _ManualPlan(
    'hld_pension',
    'Supplementary pension fund',
    ManualAssetType.pensionFund,
    boughtDaysAgo: 900,
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
  DateTime daysAgo(int days) => today.subtract(Duration(days: days));

  for (final plan in _catalogPlans) {
    final asset = catalog.firstWhere((a) => a.id == plan.assetId);
    final history = priceHistories[asset.id]!;
    var quantity = 0.0;
    var boughtUnits = 0.0;
    var boughtValue = 0.0;
    final trades = [...plan.trades]
      ..sort((a, b) => b.daysAgo.compareTo(a.daysAgo));

    for (final trade in trades) {
      final date = daysAgo(trade.daysAgo);
      final price = priceOn(history, date);
      movements.add(
        InvestmentMovement(
          id: nextId(),
          holdingId: plan.holdingId,
          type: trade.sell ? MovementType.sell : MovementType.buy,
          date: date,
          quantity: trade.quantity,
          price: price,
          amount: round2(trade.quantity * price),
          currency: asset.currency,
        ),
      );
      movements.add(
        InvestmentMovement(
          id: nextId(),
          holdingId: plan.holdingId,
          type: MovementType.fee,
          date: date,
          amount: tradeFee,
          currency: 'EUR',
        ),
      );
      if (trade.sell) {
        quantity -= trade.quantity;
      } else {
        quantity += trade.quantity;
        boughtUnits += trade.quantity;
        boughtValue += trade.quantity * price;
      }
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
          type: MovementType.dividend,
          date: date,
          quantity: held,
          price: dividend.perUnit,
          amount: round2(held * dividend.perUnit),
          currency: asset.currency,
        ),
      );
    }

    holdings.add(
      Holding(
        id: plan.holdingId,
        accountId: brokerAccountId,
        assetId: asset.id,
        quantity: quantity,
        averageCost: (boughtValue / boughtUnits * 10000).round() / 10000,
        currency: asset.currency,
      ),
    );
  }

  for (final plan in _manualPlans) {
    movements.add(
      InvestmentMovement(
        id: nextId(),
        holdingId: plan.holdingId,
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

  movements.sort((a, b) => a.date.compareTo(b.date));
  return (holdings: holdings, movements: movements);
}
