import 'package:flutter/foundation.dart';

import 'budget.dart';
import 'budget_status.dart';

/// A colored part of the segmented bar of the Budget tab: what one budget
/// has spent.
@immutable
class BudgetSegment {
  const BudgetSegment({
    required this.budgetId,
    required this.categoryId,
    required this.share,
    required this.exceeded,
  });

  final String budgetId;
  final String categoryId;

  /// Width of the part as a fraction of the whole bar: what this budget
  /// spent over the total of the period (the whole bar is the total
  /// budget). The shares add up to the overall usage, at most 1.
  final double share;

  /// This budget is over its own limit: the part gets the error marking.
  final bool exceeded;
}

/// Everything the Budget tab shows for one period, derived by
/// MockRepository.budgetOverview. Amounts are in the main currency.
@immutable
class BudgetOverview {
  const BudgetOverview({
    required this.period,
    required this.currency,
    required this.items,
    required this.total,
    required this.spent,
    required this.segments,
    required this.overallCount,
    required this.overallTotal,
    required this.overallSpent,
  });

  final BudgetPeriod period;
  final String currency;

  /// The budgets of the period, each over its own current period, the
  /// largest first.
  final List<BudgetStatus> items;

  /// Sum of the budgets of the period.
  final double total;

  /// Sum of what was spent against them (overspending included).
  final double spent;

  /// What each budget has spent, in the order of [items]; budgets that
  /// spent nothing have no part.
  final List<BudgetSegment> segments;

  /// How many of the budgets of the period count in the overall budget (the
  /// ones with `countForOverall` on).
  final int overallCount;

  /// Sum of those budgets, and what was spent against them.
  final double overallTotal;
  final double overallSpent;

  /// Whether the "Overall budget" is shown: at least one budget counts.
  bool get hasOverall => overallCount > 0;

  double get overallRemaining => overallTotal - overallSpent;
  double get overallOverBy =>
      overallSpent > overallTotal ? overallSpent - overallTotal : 0;
  double get overallUsage =>
      overallTotal == 0 ? 0 : overallSpent / overallTotal;
  BudgetState get overallState => BudgetStatus.stateForUsage(overallUsage);

  /// The part of the bar not covered by spending (the neutral one): what is
  /// left of the total budget, 0 when the total was reached or exceeded.
  double get emptyShare => (1 - usage).clamp(0.0, 1.0);

  bool get isEmpty => items.isEmpty;

  double get remaining => total - spent;
  double get overBy => spent > total ? spent - total : 0;
  double get usage => total == 0 ? 0 : spent / total;
  BudgetState get state => BudgetStatus.stateForUsage(usage);
}
