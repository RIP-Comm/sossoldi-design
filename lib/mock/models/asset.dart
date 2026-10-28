import 'package:flutter/foundation.dart';

enum AssetType { etf, stock, bond }

/// What an ETF does with the dividends of what it holds.
enum AssetDistribution { accumulating, distributing }

/// An instrument in the selectable asset catalog (the base for searching
/// and adding new assets).
@immutable
class Asset {
  const Asset({
    required this.id,
    required this.type,
    required this.name,
    required this.isin,
    required this.ticker,
    required this.exchange,
    required this.currency,
    this.sector,
    this.region,
    this.distribution,
    this.ter,
    this.dividendYield,
    this.coupon,
    this.maturity,
    this.duration,
  });

  final String id;
  final AssetType type;
  final String name;
  final String isin;
  final String ticker;
  final String exchange;

  /// Quote currency.
  final String currency;

  /// ETFs and stocks only.
  final String? sector;
  final String? region;

  /// ETFs only.
  final AssetDistribution? distribution;

  /// Yearly cost of an ETF (0.0019 = 0,19%).
  final double? ter;

  /// Stocks only: yearly dividend over the price (0.02 = 2%).
  final double? dividendYield;

  /// Bonds only: yearly coupon over the face value, the maturity date and
  /// the duration in years.
  final double? coupon;
  final DateTime? maturity;
  final double? duration;

  /// Whether it pays out money (dividends, coupons) that can be recorded.
  /// An accumulating ETF does not; neither does a stock with no dividend.
  bool get paysIncome => switch (type) {
    AssetType.etf => distribution == AssetDistribution.distributing,
    AssetType.stock => (dividendYield ?? 0) > 0,
    AssetType.bond => true,
  };

  Asset withInfo({
    AssetDistribution? distribution,
    double? ter,
    double? dividendYield,
    double? coupon,
    DateTime? maturity,
    double? duration,
  }) => Asset(
    id: id,
    type: type,
    name: name,
    isin: isin,
    ticker: ticker,
    exchange: exchange,
    currency: currency,
    sector: sector,
    region: region,
    distribution: distribution ?? this.distribution,
    ter: ter ?? this.ter,
    dividendYield: dividendYield ?? this.dividendYield,
    coupon: coupon ?? this.coupon,
    maturity: maturity ?? this.maturity,
    duration: duration ?? this.duration,
  );
}
