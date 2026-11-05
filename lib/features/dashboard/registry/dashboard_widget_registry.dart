import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../model/dashboard_layout.dart';
import '../widgets/budget_status_widget.dart';
import '../widgets/latest_transactions_widget.dart';
import '../widgets/monthly_balance_widget.dart';
import '../widgets/net_worth_widget.dart';
import '../widgets/upcoming_recurring_widget.dart';
import 'dashboard_widget_definition.dart';
import 'dashboard_widget_ids.dart';

/// The widgets available for the Dashboard.
class DashboardWidgetRegistry {
  DashboardWidgetRegistry(List<DashboardWidgetDefinition> definitions)
    : definitions = List.unmodifiable(definitions),
      _byId = {for (final d in definitions) d.id: d};

  final List<DashboardWidgetDefinition> definitions;
  final Map<String, DashboardWidgetDefinition> _byId;

  DashboardWidgetDefinition? byId(String id) => _byId[id];
}

/// The widgets available: Monthly balance, Latest transactions, Upcoming
/// recurring and Budget status, each in S, M and L. The others are added when they are built.
final dashboardWidgetRegistry = DashboardWidgetRegistry([
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.monthlyBalance,
    name: (l10n) => l10n.widgetMonthlyBalanceName,
    icon: PhosphorIconsRegular.scales,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context, _) => MonthlyBalanceWidget(size: size),
    },
  ),
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.latestTransactions,
    name: (l10n) => l10n.widgetLatestTransactionsName,
    icon: PhosphorIconsRegular.receipt,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context, instance) =>
            LatestTransactionsWidget(size: size, instance: instance),
    },
  ),
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.upcomingRecurring,
    name: (l10n) => l10n.widgetUpcomingRecurringName,
    icon: PhosphorIconsRegular.arrowsClockwise,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context, instance) =>
            UpcomingRecurringWidget(size: size, instance: instance),
    },
  ),
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.budgetStatus,
    name: (l10n) => l10n.widgetBudgetStatusName,
    icon: PhosphorIconsRegular.chartDonut,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context, instance) =>
            BudgetStatusWidget(size: size, instance: instance),
    },
  ),
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.netWorth,
    name: (l10n) => l10n.widgetNetWorthName,
    icon: PhosphorIconsRegular.chartLineUp,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context, instance) =>
            NetWorthWidget(size: size, instance: instance),
    },
  ),
]);
