import 'package:flutter/foundation.dart';

enum BudgetPeriod { weekly, monthly, quarterly, semiannual, yearly }

extension BudgetPeriodRange on BudgetPeriod {
  /// The period containing [day]: start included, end excluded.
  /// Weeks start on Monday; the other periods follow the calendar.
  ({DateTime start, DateTime end}) rangeContaining(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    switch (this) {
      case BudgetPeriod.weekly:
        final start = d.subtract(Duration(days: d.weekday - 1));
        return (start: start, end: start.add(const Duration(days: 7)));
      case BudgetPeriod.monthly:
        return (
          start: DateTime(d.year, d.month),
          end: DateTime(d.year, d.month + 1),
        );
      case BudgetPeriod.quarterly:
        final month = (d.month - 1) ~/ 3 * 3 + 1;
        return (
          start: DateTime(d.year, month),
          end: DateTime(d.year, month + 3),
        );
      case BudgetPeriod.semiannual:
        final month = d.month <= 6 ? 1 : 7;
        return (
          start: DateTime(d.year, month),
          end: DateTime(d.year, month + 6),
        );
      case BudgetPeriod.yearly:
        return (start: DateTime(d.year), end: DateTime(d.year + 1));
    }
  }
}

@immutable
class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.currency,
    required this.period,
  });

  final String id;

  /// Top-level expense category.
  final String categoryId;
  final double amount;
  final String currency;
  final BudgetPeriod period;
}
