import 'package:flutter/foundation.dart';

/// Kinds of assets entered by hand, outside the catalog.
enum ManualAssetType { pensionFund, collectible, art, realEstate, other }

/// A user position: either an asset from the catalog ([assetId]) or a
/// manual asset ([manualName], [manualType], [manualValue]).
@immutable
class Holding {
  const Holding({
    required this.id,
    required this.quantity,
    required this.averageCost,
    required this.currency,
    this.accountId,
    this.assetId,
    this.manualName,
    this.manualType,
    this.manualValue,
    this.manualValuedAt,
    this.countsForNetWorth = true,
  }) : assert(
         (assetId != null) != (manualName != null),
         'Either a catalog asset or a manual asset',
       );

  final String id;

  /// Broker account holding a catalog asset; null for manual assets.
  final String? accountId;
  final String? assetId;
  final double quantity;

  /// Average purchase price per unit (PMC), in [currency].
  final double averageCost;

  /// Asset currency for catalog assets, the user currency for manual ones.
  final String currency;

  final String? manualName;
  final ManualAssetType? manualType;

  /// Current value entered by the user (whole position).
  final double? manualValue;
  final DateTime? manualValuedAt;

  /// Whether the user wants this position in the net worth. Only stored for
  /// now: no screen or total uses it yet.
  final bool countsForNetWorth;

  bool get isManual => assetId == null;

  /// Sold out: it stays only because its movements do.
  bool get isClosed => quantity <= 1e-9;

  Holding copyWith({
    double? quantity,
    double? averageCost,
    double? manualValue,
    DateTime? manualValuedAt,
    bool? countsForNetWorth,
  }) => Holding(
    id: id,
    accountId: accountId,
    assetId: assetId,
    quantity: quantity ?? this.quantity,
    averageCost: averageCost ?? this.averageCost,
    currency: currency,
    manualName: manualName,
    manualType: manualType,
    manualValue: manualValue ?? this.manualValue,
    manualValuedAt: manualValuedAt ?? this.manualValuedAt,
    countsForNetWorth: countsForNetWorth ?? this.countsForNetWorth,
  );
}
