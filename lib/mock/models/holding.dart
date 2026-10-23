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

  bool get isManual => assetId == null;
}
