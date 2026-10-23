import 'package:flutter/foundation.dart';

enum AssetType { etf, stock, bond }

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
}
