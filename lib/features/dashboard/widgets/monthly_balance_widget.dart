import 'package:flutter/widgets.dart';

import '../../../app/app_scope.dart';
import '../../../l10n/l10n.dart';
import '../model/dashboard_layout.dart';
import 'monthly_balance_card.dart';

/// Monthly balance, reading its data from the repository and the global
/// "hide amounts" switch.
class MonthlyBalanceWidget extends StatelessWidget {
  const MonthlyBalanceWidget({super.key, required this.size});

  final DashboardWidgetSize size;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MonthlyBalanceCard(
      size: size,
      title: l10n.widgetMonthlyBalanceName,
      trend: context.repository.balanceTrend(),
      masked: context.hideAmounts,
      comparisonLabel: l10n.widgetComparedToLastMonth,
      incomeLabel: l10n.widgetIncome,
      expenseLabel: l10n.widgetExpense,
      thisMonthLabel: l10n.chartThisMonth,
      lastMonthLabel: l10n.chartLastMonth,
    );
  }
}
