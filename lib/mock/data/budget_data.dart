import '../models/budget.dart';
import '../models/transaction.dart';

/// Budget setup for every expense category. [targetUsage] is the share of
/// the budget already spent in the current period: amounts are calibrated
/// on the generated transactions, so whatever today is there are budgets
/// in every state (ok < 80%, warning 80-100%, exceeded > 100%).
class BudgetPlan {
  const BudgetPlan(this.categoryId, this.period, this.targetUsage);

  final String categoryId;
  final BudgetPeriod period;
  final double targetUsage;
}

/// A category can have several budgets, each on a different period (never
/// two on the same). There is no budget on subcategories, and none on the
/// semiannual period, so that this period shows its empty state.
const budgetPlans = [
  BudgetPlan('cat_home', BudgetPeriod.monthly, 0.75),
  BudgetPlan('cat_groceries', BudgetPeriod.weekly, 0.9),
  BudgetPlan('cat_groceries', BudgetPeriod.monthly, 0.6),
  BudgetPlan('cat_transport', BudgetPeriod.monthly, 1.25),
  BudgetPlan('cat_leisure', BudgetPeriod.monthly, 1.35),
  BudgetPlan('cat_leisure', BudgetPeriod.weekly, 1.15),
  BudgetPlan('cat_health', BudgetPeriod.quarterly, 0.45),
  BudgetPlan('cat_subscriptions', BudgetPeriod.monthly, 0.7),
  BudgetPlan('cat_shopping', BudgetPeriod.monthly, 0.85),
  BudgetPlan('cat_education', BudgetPeriod.yearly, 0.35),
];

/// Expense total of [categoryId] in the period of [period] containing [today].
double spentInCurrentPeriod(
  List<Transaction> transactions,
  String categoryId,
  BudgetPeriod period,
  DateTime today,
) {
  final range = period.rangeContaining(today);
  return transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            !t.date.isBefore(range.start) &&
            t.date.isBefore(range.end),
      )
      .fold(0.0, (sum, t) => sum + t.amount);
}

List<Budget> buildBudgets({
  required DateTime today,
  required List<Transaction> transactions,
}) {
  return [
    for (final plan in budgetPlans)
      Budget(
        id: 'bud_${plan.categoryId.substring(4)}_${plan.period.name}',
        categoryId: plan.categoryId,
        amount: _roundBudget(
          spentInCurrentPeriod(
                transactions,
                plan.categoryId,
                plan.period,
                today,
              ) /
              plan.targetUsage,
        ),
        currency: 'EUR',
        period: plan.period,
      ),
  ];
}

/// Rounds to a "human" budget figure, fine enough to keep the target usage.
double _roundBudget(double amount) {
  final step = amount < 100
      ? 1
      : amount < 1000
      ? 5
      : 10;
  return ((amount / step).round() * step).toDouble().clamp(1, double.infinity);
}
