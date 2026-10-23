import 'package:flutter/foundation.dart';

import 'budget.dart';

enum BudgetState { ok, warning, exceeded }

/// Spending against a budget in one period. Derived by MockRepository,
/// not stored.
@immutable
class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Usage from which a budget is "close to the limit".
  static const double warningThreshold = 0.8;

  final Budget budget;
  final double spent;

  /// Start included, end excluded.
  final DateTime periodStart;
  final DateTime periodEnd;

  double get remaining => budget.amount - spent;

  /// Spent / amount (1.0 = limit reached).
  double get usage => budget.amount == 0 ? 0 : spent / budget.amount;

  BudgetState get state => usage > 1
      ? BudgetState.exceeded
      : usage >= warningThreshold
      ? BudgetState.warning
      : BudgetState.ok;
}
