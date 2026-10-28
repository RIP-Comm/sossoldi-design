import 'package:flutter/foundation.dart';

import 'holding.dart';
import 'investment_movement.dart';
import 'portfolio.dart';

/// What the form of a movement collects. For a buy of an asset that is not in
/// the portfolio, [assetId] (catalog) or [manualName] and [manualType] say
/// which position to create; otherwise [holdingId] is the position.
@immutable
class MovementDraft {
  const MovementDraft({
    required this.type,
    required this.date,
    this.holdingId,
    this.assetId,
    this.manualName,
    this.manualType,
    this.accountId,
    this.quantity,
    this.price,
    this.fee = 0,
    this.amount,
    this.description,
    this.isOpening = false,
    this.countsForNetWorth = true,
  });

  final MovementType type;
  final DateTime date;
  final String? holdingId;
  final String? assetId;
  final String? manualName;
  final ManualAssetType? manualType;

  /// The broker account; null: the first one.
  final String? accountId;
  final double? quantity;
  final double? price;
  final double fee;

  /// Net amount of a dividend or a cost (buy and sell: units x price).
  final double? amount;
  final String? description;

  /// An opening buy (see [InvestmentMovement.isOpening]): no broker account,
  /// no commission, in the currency of the asset (the main one for a manual
  /// asset).
  final bool isOpening;

  /// For the position a buy creates.
  final bool countsForNetWorth;
}

/// Why a change of the movements was not applied.
enum MovementFailure {
  /// A number that is missing or not positive, a date in the future for
  /// something that has to be done already, no asset...
  invalid,

  /// At some date more would be sold than is held.
  negativeQuantity,

  /// The position or the movement does not exist.
  notFound,

  /// The asset (or manual asset of that name) is already in the portfolio.
  duplicate,
}

@immutable
class MovementResult {
  const MovementResult.ok({this.movementId}) : failure = null, failedOn = null;

  const MovementResult.fail(this.failure, {this.failedOn}) : movementId = null;

  final MovementFailure? failure;

  /// For [MovementFailure.negativeQuantity]: the day the quantity goes below
  /// zero.
  final DateTime? failedOn;

  /// The new movement, when one was added.
  final String? movementId;

  bool get ok => failure == null;
}

/// The periods of the movements list.
enum MovementPeriod {
  currentMonth,
  last3Months,
  currentYear,
  last12Months,
  all,
}

@immutable
class MovementFilter {
  const MovementFilter({
    this.query = '',
    this.period = MovementPeriod.currentYear,
    this.types = const {},
    this.kinds = const {},
    this.holdingId,
  });

  /// Matches the name, ticker, ISIN and description.
  final String query;
  final MovementPeriod period;

  /// Empty: all.
  final Set<MovementType> types;
  final Set<PositionKind> kinds;

  /// One position only.
  final String? holdingId;

  /// How many filters differ from the default (search not counted).
  int get activeCount =>
      (period == MovementPeriod.currentYear ? 0 : 1) +
      (types.isEmpty ? 0 : 1) +
      (kinds.isEmpty ? 0 : 1) +
      (holdingId == null ? 0 : 1);

  bool get isRefined => query.trim().isNotEmpty || activeCount > 0;

  MovementFilter copyWith({
    String? query,
    MovementPeriod? period,
    Set<MovementType>? types,
    Set<PositionKind>? kinds,
    String? holdingId,
    bool clearHolding = false,
  }) => MovementFilter(
    query: query ?? this.query,
    period: period ?? this.period,
    types: types ?? this.types,
    kinds: kinds ?? this.kinds,
    holdingId: clearHolding ? null : (holdingId ?? this.holdingId),
  );

  @override
  bool operator ==(Object other) =>
      other is MovementFilter &&
      other.query == query &&
      other.period == period &&
      setEquals(other.types, types) &&
      setEquals(other.kinds, kinds) &&
      other.holdingId == holdingId;

  @override
  int get hashCode => Object.hash(
    query,
    period,
    Object.hashAll(types),
    Object.hashAll(kinds),
    holdingId,
  );
}

/// A movement with what the list shows about its position.
@immutable
class MovementEntry {
  const MovementEntry({
    required this.movement,
    required this.currency,
    this.kind,
    this.name,
    this.ticker,
    this.isin,
    this.holdingOpen = false,
  });

  final InvestmentMovement movement;
  final String currency;

  /// Null for a cost that is not about an asset.
  final PositionKind? kind;
  final String? name;
  final String? ticker;
  final String? isin;

  /// The position still exists (not sold out, not removed).
  final bool holdingOpen;

  /// What goes to or from the account, in [currency]: the amount of a buy
  /// with the commission, of a sell without it.
  double get total => switch (movement.type) {
    MovementType.buy => movement.amount + movement.fee,
    MovementType.sell => movement.amount - movement.fee,
    _ => movement.amount,
  };
}

@immutable
class MovementDay {
  const MovementDay({required this.day, required this.entries});

  final DateTime day;
  final List<MovementEntry> entries;
}

/// The Movements list: what is expected ("Up next", soonest first) and the
/// movements already happened by day, the newest first.
@immutable
class MovementList {
  const MovementList({required this.upNext, required this.days});

  final List<MovementEntry> upNext;
  final List<MovementDay> days;

  bool get isEmpty => upNext.isEmpty && days.isEmpty;
}
