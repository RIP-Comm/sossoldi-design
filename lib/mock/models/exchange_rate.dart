import 'package:flutter/foundation.dart';

/// Fixed rate to the main currency (EUR).
@immutable
class ExchangeRate {
  const ExchangeRate({
    required this.currency,
    required this.toEur,
    required this.updatedAt,
  });

  final String currency;

  /// Value of 1 unit of [currency] in EUR.
  final double toEur;

  /// When rates were last refreshed (simulated), for "updated X ago".
  final DateTime updatedAt;
}
