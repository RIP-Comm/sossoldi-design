import 'package:flutter/foundation.dart';

/// Closing price of an asset on a trading day, in the asset currency.
@immutable
class PricePoint {
  const PricePoint({required this.date, required this.price});

  final DateTime date;
  final double price;
}
