import 'package:flutter/foundation.dart';

import 'asset.dart';
import 'holding.dart';
import 'investment_movement.dart';

/// The periods of the Investments market value chart.
enum ValuePeriod {
  day,
  fiveDays,
  month,
  sixMonths,
  yearToDate,
  year,
  fiveYears,
}

/// Value of the portfolio at one moment: the market value of the positions
/// and the capital invested (net contributions at cost), in the main currency.
@immutable
class ValuePoint {
  const ValuePoint({
    required this.time,
    required this.value,
    required this.invested,
  });

  final DateTime time;
  final double value;
  final double invested;

  double get difference => value - invested;

  /// Difference over the invested capital; 0 when nothing is invested.
  double get differencePercent => invested == 0 ? 0 : difference / invested;
}

/// The chart series of a [ValuePeriod]: one point per 15 minutes for the
/// intraday periods, one per trading day for the others. It starts at the
/// first purchase when the period is longer than the history of the
/// portfolio; empty when there is nothing in it.
@immutable
class ValueSeries {
  const ValueSeries({
    required this.period,
    required this.currency,
    required this.points,
  });

  final ValuePeriod period;
  final String currency;
  final List<ValuePoint> points;

  bool get isIntraday =>
      period == ValuePeriod.day || period == ValuePeriod.fiveDays;
}

/// What the portfolio is worth now, in the main currency. [gain] is the
/// total unrealized profit or loss of the positions against their cost
/// (quantity x average cost); the liquidity is not part of it.
@immutable
class PortfolioSummary {
  const PortfolioSummary({
    required this.currency,
    required this.marketValue,
    required this.liquidity,
    required this.cost,
  });

  final String currency;

  /// Market value of all the positions.
  final double marketValue;

  /// Cash available in the broker accounts.
  final double liquidity;

  /// Purchase cost of the units still held.
  final double cost;

  /// Positions plus liquidity.
  double get totalValue => marketValue + liquidity;
  double get gain => marketValue - cost;

  /// Gain over the cost (0.12 = +12%); 0 with no cost.
  double get gainPercent => cost == 0 ? 0 : gain / cost;
}

/// How the allocation is split.
enum AllocationMode { assetClass, singleAsset }

/// What a slice of the allocation is.
enum AllocationKind { assetClass, asset, other, liquidity }

/// Asset classes of the allocation. [other] are the manual assets.
enum AssetClass { etf, stock, bond, other }

@immutable
class AllocationSlice {
  const AllocationSlice({
    required this.kind,
    required this.value,
    required this.share,
    this.assetClass,
    this.holdingId,
  });

  final AllocationKind kind;

  /// In the main currency.
  final double value;

  /// Of the total value (1 = all).
  final double share;

  /// For [AllocationKind.assetClass].
  final AssetClass? assetClass;

  /// For [AllocationKind.asset].
  final String? holdingId;
}

/// Which rule produced a message of the Investments digest.
enum InvestmentDigestRule {
  concentration,
  monthDrop,
  monthGrowth,
  expectedDividend,
  allGood,
}

/// A message of the Investments digest, as data (the screen writes the
/// text). Tone: concentration and dividends info, drop warning, growth
/// success. Fields by rule:
/// - concentration: [holdingId], [percent] (share of the total value)
/// - monthDrop / monthGrowth: [amount] (change over the last month, net of
///   what was invested in the month), [percent] (over the value a month ago)
/// - expectedDividend: [amount] (total), [count], [holdingId] when only one,
///   [days] (the window)
@immutable
class InvestmentDigestMessage {
  const InvestmentDigestMessage({
    required this.rule,
    this.holdingId,
    this.amount,
    this.percent,
    this.count,
    this.days,
  });

  final InvestmentDigestRule rule;
  final String? holdingId;
  final double? amount;
  final double? percent;
  final int? count;
  final int? days;
}

/// The kinds of position the Positions list can be filtered by.
enum PositionKind { etf, stock, bond, manual }

/// One position of the portfolio as the Positions list shows it. Amounts in
/// the main currency.
@immutable
class Position {
  const Position({
    required this.holdingId,
    required this.kind,
    required this.name,
    required this.value,
    required this.cost,
    required this.weight,
    required this.monthPrices,
    this.manualType,
    this.ticker,
    this.isin,
    this.exchange,
    this.monthChange,
  });

  final String holdingId;
  final PositionKind kind;

  /// For a manual asset, what kind of asset it is.
  final ManualAssetType? manualType;
  final String name;

  /// Null for manual assets: they have no ticker or ISIN.
  final String? ticker;
  final String? isin;
  final String? exchange;

  /// Market value (manual assets: the value entered).
  final double value;

  /// Quantity x average cost.
  final double cost;

  /// Share of the portfolio value (positions plus liquidity).
  final double weight;

  /// Prices of the last month, oldest first, converted to the main
  /// currency; empty for manual assets.
  final List<double> monthPrices;

  /// Change of the price over the last month; null without a chart.
  final double? monthChange;

  bool get isManual => kind == PositionKind.manual;

  /// Total unrealized profit or loss against the cost.
  double get gain => value - cost;

  /// Over the cost (0.12 = +12%); 0 with no cost.
  double get gainPercent => cost == 0 ? 0 : gain / cost;
}

/// How the breakdown of the positions is split.
enum BreakdownBy { region, sector }

/// One row of the portfolio breakdown. [name] is null for what has no
/// region or sector (bonds, manual assets): "Other".
@immutable
class BreakdownRow {
  const BreakdownRow({
    required this.name,
    required this.value,
    required this.share,
  });

  final String? name;

  /// Main currency.
  final double value;

  /// Of the value of the positions (liquidity excluded).
  final double share;
}

/// A buy, sell or dividend of one position.
@immutable
class Operation {
  const Operation({
    required this.type,
    required this.date,
    required this.amount,
    required this.currency,
    this.quantity,
    this.price,
  });

  final MovementType type;
  final DateTime date;

  /// Total, positive, in [currency] (the asset's).
  final double amount;
  final String currency;
  final double? quantity;
  final double? price;
}

/// The operations of one day.
@immutable
class OperationDay {
  const OperationDay({required this.day, required this.operations});

  final DateTime day;
  final List<Operation> operations;
}

/// The page of one position. Amounts in the main currency unless the name
/// says otherwise.
@immutable
class PositionDetail {
  const PositionDetail({
    required this.position,
    required this.assetCurrency,
    required this.quantity,
    required this.averageCost,
    required this.averageCostMain,
    required this.operations,
    this.price,
    this.priceMain,
    this.todayChange,
    this.type,
    this.sector,
    this.region,
    this.asset,
    this.paysIncome = false,
  });

  final Position position;

  /// Currency of the asset (the user's for a manual one).
  final String assetCurrency;
  final double quantity;

  /// Average cost per unit, in the asset currency and in the main currency.
  final double averageCost;
  final double averageCostMain;

  /// Current price in the asset currency and in the main currency; null for
  /// manual assets.
  final double? price;
  final double? priceMain;

  /// Change of the price against the previous close (0.01 = +1%).
  final double? todayChange;

  /// Asset info; null for manual assets.
  final AssetType? type;
  final String? sector;
  final String? region;

  /// The catalog asset with its details (distribution, TER, coupon, ...);
  /// null for manual assets.
  final Asset? asset;

  /// Dividends or coupons can be recorded for it: not an accumulating ETF,
  /// a stock with no dividend or a manual asset.
  final bool paysIncome;

  /// Newest day first.
  final List<OperationDay> operations;

  /// The asset is quoted in another currency than the main one.
  bool hasOtherCurrency(String mainCurrency) => assetCurrency != mainCurrency;
}
