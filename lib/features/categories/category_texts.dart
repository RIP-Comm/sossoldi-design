import 'package:flutter/widgets.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/budget.dart';
import '../finance/budget/budget_texts.dart';

/// A budget amount as the lists of categories show it: no cents when there
/// are none ("130 €").
String budgetAmountText(BuildContext context, double amount, String currency) =>
    SossoldiAmountFormat.money(
      context,
      amount,
      currencyCode: currency,
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );

/// "130 €, Monthly": one budget in the second line of a category.
String budgetEntryText(
  BuildContext context, {
  required BudgetPeriod period,
  required double amount,
  required String currency,
}) => context.l10n.categoryBudgetEntry(
  budgetAmountText(context, amount, currency),
  budgetPeriodLabel(context, period),
);

/// "Budget: 130 €, Monthly · 40 €, Weekly": the second line of a category
/// with budgets, shortest period first.
String budgetsSubtitle(
  BuildContext context,
  Iterable<Budget> budgets,
  String currency,
) {
  final sorted = budgets.toList()
    ..sort((a, b) => a.period.index.compareTo(b.period.index));
  return context.l10n.categoryBudgetSubtitle(
    sorted
        .map(
          (b) => budgetEntryText(
            context,
            period: b.period,
            amount: b.amount,
            currency: currency,
          ),
        )
        .join(' · '),
  );
}
