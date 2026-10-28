import 'package:flutter/foundation.dart';

/// A cost is money paid that is not part of a trade (custody, taxes, ...);
/// the commission of a buy or a sell is [InvestmentMovement.fee].
enum MovementType { buy, sell, dividend, cost }

@immutable
class InvestmentMovement {
  const InvestmentMovement({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.currency,
    this.holdingId,
    this.accountId,
    this.quantity,
    this.price,
    this.fee = 0,
    this.description,
    this.isOpening = false,
  });

  final String id;

  /// The position it belongs to; null for a cost that is not about an asset.
  final String? holdingId;
  final MovementType type;

  /// Dividends dated after today are expected, not yet paid.
  final DateTime date;

  /// The broker account whose liquidity it moves.
  final String? accountId;

  /// Units bought/sold, or units held for a dividend. Null for costs.
  final double? quantity;

  /// Price per unit, or dividend per unit.
  final double? price;

  /// Commission of a buy or sell, in [currency]; not in [amount].
  final double fee;

  /// Total without the commission, always positive: units x price for a buy
  /// or a sell, the net amount of a dividend or a cost.
  final double amount;

  /// Currency of the asset (of the account for a cost without an asset).
  final String currency;

  /// Free text: what a cost or a dividend is about.
  final String? description;

  /// A buy of the onboarding that says what the user already holds: dated
  /// when it was entered, quantity and price = the average cost, no
  /// commission and no broker account, so it never touches the liquidity.
  /// It is otherwise a normal buy (it shows in the Movements list).
  final bool isOpening;

  /// What leaves (negative) or reaches (positive) the account, in
  /// [currency]: a buy costs [amount] plus the commission, a sell brings
  /// [amount] minus it.
  double get cashEffect => switch (type) {
    MovementType.buy => -(amount + fee),
    MovementType.sell => amount - fee,
    MovementType.dividend => amount,
    MovementType.cost => -amount,
  };

  InvestmentMovement copyWith({
    DateTime? date,
    String? accountId,
    double? quantity,
    double? price,
    double? fee,
    double? amount,
    String? description,
  }) => InvestmentMovement(
    id: id,
    isOpening: isOpening,
    holdingId: holdingId,
    type: type,
    date: date ?? this.date,
    accountId: accountId ?? this.accountId,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    fee: fee ?? this.fee,
    amount: amount ?? this.amount,
    currency: currency,
    description: description ?? this.description,
  );
}

/// What a position is after playing its movements one by one.
@immutable
class HoldingState {
  const HoldingState({required this.quantity, required this.cost});

  final double quantity;

  /// Cost of the units held: what the buys paid, commissions included; a
  /// sell takes out units at the average cost, which stays the same.
  final double cost;

  double get averageCost => quantity <= 1e-9 ? 0 : cost / quantity;

  bool get isClosed => quantity <= 1e-9;
}

/// Plays the buys and sells of a position in date order (the order they
/// were given on the same day). Returns the result, or, when at some
/// moment more would be sold than is held, the date of the first sell that
/// goes below zero (`failedOn`).
({HoldingState? state, DateTime? failedOn}) replayHolding(
  Iterable<InvestmentMovement> movements,
) {
  final ordered = [
    for (final m in movements)
      if (m.type == MovementType.buy || m.type == MovementType.sell) m,
  ];
  final indexed = ordered.indexed.toList()
    ..sort((a, b) {
      final c = a.$2.date.compareTo(b.$2.date);
      return c != 0 ? c : a.$1.compareTo(b.$1);
    });
  var units = 0.0, cost = 0.0;
  for (final (_, m) in indexed) {
    final q = m.quantity ?? 0;
    if (m.type == MovementType.buy) {
      units += q;
      // The amount is rounded to cents; an opening buy says its price, and a
      // tiny quantity must not drift away from it.
      cost += (m.isOpening ? q * (m.price ?? 0) : m.amount) + m.fee;
    } else {
      if (q > units + 1e-9) return (state: null, failedOn: m.date);
      cost -= units == 0 ? 0 : cost / units * q;
      units -= q;
      if (units <= 1e-9) {
        units = 0;
        cost = 0;
      }
    }
  }
  return (state: HoldingState(quantity: units, cost: cost), failedOn: null);
}
