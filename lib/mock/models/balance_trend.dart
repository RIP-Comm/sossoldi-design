import 'package:flutter/foundation.dart';

/// Income minus expenses of a calendar month, day by day, next to the
/// previous month for comparison. Derived by MockRepository, not stored.
/// Transfers are not part of it. Amounts are in [currency].
@immutable
class BalanceTrend {
  const BalanceTrend({
    required this.periodStart,
    required this.daysInPeriod,
    required this.currency,
    required this.current,
    required this.previous,
    required this.income,
    required this.expenses,
  });

  /// First day of the month.
  final DateTime periodStart;
  final int daysInPeriod;
  final String currency;

  /// Cumulative net at the end of each day, from day 1 to today (inclusive).
  /// Its length is the number of days elapsed.
  final List<double> current;

  /// Cumulative net of the whole previous month, one value per day.
  final List<double> previous;

  /// Income and expenses of the month so far (both positive).
  final double income;
  final double expenses;

  /// Net of the month so far.
  double get net => current.isEmpty ? 0 : current.last;

  /// Net so far minus the previous month's net on the same day.
  double get vsPreviousSameDay {
    if (current.isEmpty || previous.isEmpty) return net;
    final i = current.length <= previous.length
        ? current.length - 1
        : previous.length - 1;
    return double.parse((net - previous[i]).toStringAsFixed(2));
  }
}
