import 'package:flutter/foundation.dart';

enum MovementType { buy, sell, dividend, fee }

@immutable
class InvestmentMovement {
  const InvestmentMovement({
    required this.id,
    required this.holdingId,
    required this.type,
    required this.date,
    required this.amount,
    required this.currency,
    this.quantity,
    this.price,
  });

  final String id;
  final String holdingId;
  final MovementType type;

  /// Dividends dated after today are expected, not yet paid.
  final DateTime date;

  /// Units bought/sold, or units held for a dividend. Null for fees.
  final double? quantity;

  /// Price per unit, or dividend per unit.
  final double? price;

  /// Total, always positive.
  final double amount;
  final String currency;
}
