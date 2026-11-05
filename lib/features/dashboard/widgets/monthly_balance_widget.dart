import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
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
    final repo = context.repository;
    final trend = repo.balanceTrend();
    final today = repo.today;
    final locale = Localizations.localeOf(context).toString();
    return MonthlyBalanceCard(
      size: size,
      title: l10n.widgetMonthlyBalanceName,
      trend: trend,
      pointTitles: [
        for (var d = 0; d < trend.daysInPeriod; d++)
          DateFormat.MMMd(locale)
              .format(DateTime(today.year, today.month, d + 1)),
      ],
      // The S has no tooltip.
      formatValue: size == DashboardWidgetSize.s
          ? null
          : (v) => SossoldiAmountFormat.money(
              context,
              v,
              currencyCode: trend.currency,
            ),
      masked: context.hideAmounts,
      comparisonLabel: l10n.widgetComparedToLastMonth,
      incomeLabel: l10n.widgetIncome,
      expenseLabel: l10n.widgetExpense,
      thisMonthLabel: l10n.chartThisMonth,
      lastMonthLabel: l10n.chartLastMonth,
    );
  }
}
