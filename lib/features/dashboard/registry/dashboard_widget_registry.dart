import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../model/dashboard_layout.dart';
import '../widgets/latest_transactions_widget.dart';
import '../widgets/monthly_balance_widget.dart';
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

/// Only the widgets designed in Figma are registered: Monthly balance and
/// Latest transactions, each in S, M and L. The others in the Figma list
/// are added when they are designed.
final dashboardWidgetRegistry = DashboardWidgetRegistry([
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.monthlyBalance,
    name: (l10n) => l10n.widgetMonthlyBalanceName,
    icon: PhosphorIconsRegular.scales,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context) => MonthlyBalanceWidget(size: size),
    },
  ),
  DashboardWidgetDefinition(
    id: DashboardWidgetIds.latestTransactions,
    name: (l10n) => l10n.widgetLatestTransactionsName,
    icon: PhosphorIconsRegular.receipt,
    builders: {
      for (final size in DashboardWidgetSize.values)
        size: (context) => LatestTransactionsWidget(size: size),
    },
  ),
]);
