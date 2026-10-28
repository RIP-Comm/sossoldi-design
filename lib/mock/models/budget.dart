import 'package:flutter/foundation.dart';

enum BudgetPeriod { weekly, monthly, quarterly, semiannual, yearly }

extension BudgetPeriodRange on BudgetPeriod {
  /// The period containing [day]: start included, end excluded.
  /// Weeks start on Monday; the other periods follow the calendar.
  ({DateTime start, DateTime end}) rangeContaining(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    switch (this) {
      case BudgetPeriod.weekly:
        // Calendar arithmetic: adding a Duration would lose or gain an hour
        // across a daylight saving change.
        final start = DateTime(d.year, d.month, d.day - (d.weekday - 1));
        return (
          start: start,
          end: DateTime(start.year, start.month, start.day + 7),
        );
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
    this.limitAlert = false,
    this.countForOverall = true,
  });

  final String id;

  /// Top-level expense category. A category can have several budgets, one
  /// per period; subcategories have none.
  final String categoryId;

  /// Limit for one period, in [currency].
  final double amount;
  final String currency;
  final BudgetPeriod period;

  /// Whether the user wants to be warned when the limit is reached. Only
  /// stored: the prototype has no notifications.
  final bool limitAlert;

  /// Whether the budget counts in the "Overall budget" of the Budget tab.
  final bool countForOverall;

  Budget withAmount(double amount) => copyWith(amount: amount);

  Budget copyWith({
    String? categoryId,
    double? amount,
    String? currency,
    BudgetPeriod? period,
    bool? limitAlert,
    bool? countForOverall,
  }) => Budget(
    id: id,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    period: period ?? this.period,
    limitAlert: limitAlert ?? this.limitAlert,
    countForOverall: countForOverall ?? this.countForOverall,
  );
}
