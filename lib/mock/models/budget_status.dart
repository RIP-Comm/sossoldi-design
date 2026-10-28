import 'package:flutter/foundation.dart';

import 'budget.dart';

enum BudgetState { ok, warning, exceeded }

/// Spending against a budget in one period. Derived by MockRepository,
/// not stored. [amount] and [spent] are in the main currency.
@immutable
class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.amount,
    required this.spent,
    required this.currency,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Usage from which a budget is "close to the limit".
  static const double warningThreshold = 0.8;

  /// The stored budget (its amount is in its own currency).
  final Budget budget;

  /// The limit, converted to the main currency.
  final double amount;
  final double spent;

  /// The main currency [amount] and [spent] are in.
  final String currency;

  /// Start included, end excluded.
  final DateTime periodStart;
  final DateTime periodEnd;

  /// What is left; negative when the budget is exceeded.
  double get remaining => amount - spent;

  /// How much the spending went over the limit (0 when not exceeded).
  double get overBy => spent > amount ? spent - amount : 0;

  /// Spent / amount (1.0 = limit reached).
  double get usage => amount == 0 ? 0 : spent / amount;

  BudgetState get state => stateForUsage(usage);

  static BudgetState stateForUsage(double usage) => usage > 1
      ? BudgetState.exceeded
      : usage >= warningThreshold
      ? BudgetState.warning
      : BudgetState.ok;
}
