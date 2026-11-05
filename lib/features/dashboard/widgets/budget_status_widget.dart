import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/budget.dart';
import '../../finance/budget/budget_detail_screen.dart';
import '../../finance/budget/budget_texts.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'budget_status_card.dart';
import 'budget_status_row.dart';
import 'dashboard_type_selector.dart';

/// Budget status: the budgets valid today, most relevant first (exceeded,
/// at risk, the rest; see `MockRepository.budgetsByRelevance`), optionally
/// only one budget type. The type is a setting of the placement, so it
/// survives reordering and resizing.
class BudgetStatusWidget extends StatelessWidget {
  const BudgetStatusWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// Key of the budget type in the placement's settings.
  static const periodSetting = 'period';

  static BudgetPeriod? periodOf(Map<String, String> settings) {
    final name = settings[periodSetting];
    for (final p in BudgetPeriod.values) {
      if (p.name == name) return p;
    }
    return null;
  }

  /// How many budgets each size draws at most.
  static int maxFor(DashboardWidgetSize size) => switch (size) {
    DashboardWidgetSize.s => 1,
    DashboardWidgetSize.m => 3,
    DashboardWidgetSize.l => BudgetStatusCard.maxRows,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final brightness = Theme.of(context).brightness;
    final period = periodOf(instance.settings);
    final budgets = repo.budgetsByRelevance(
      period: period,
      limit: maxFor(size),
    );
    final rows = [
      for (final s in budgets)
        () {
          final category = repo.category(s.budget.categoryId);
          return BudgetStatusRow(
            title: category.name,
            periodLabel: budgetPeriodLabel(context, s.budget.period),
            percent: budgetPercent(context, s.usage),
            remaining: budgetRemainingText(
              context,
              remaining: s.remaining,
              overBy: s.overBy,
              currency: s.currency,
              masked: context.hideAmounts,
            ),
            tone: budgetTone(s.state),
            usage: s.usage,
            color: category.color.main,
            trackColor: category.color.tintFor(brightness),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BudgetDetailScreen(budgetId: s.budget.id),
              ),
            ),
          );
        }(),
    ];
    final options = <({String? key, String label})>[
      (key: null, label: l10n.budgetTypeAll),
      for (final p in BudgetPeriod.values)
        (key: p.name, label: budgetPeriodLabel(context, p)),
    ];
    return BudgetStatusCard(
      size: size,
      rows: rows,
      title: l10n.widgetBudgetTitle,
      emptyText: period == null
          ? l10n.widgetNoBudgets
          : l10n.widgetNoBudgetsOfPeriod(
              budgetPeriodLabel(context, period).toLowerCase(),
            ),
      selector: DashboardTypeSelector(
        label: period == null
            ? l10n.budgetTypeAll
            : budgetPeriodLabel(context, period),
        options: options,
        selected: period?.name,
        semanticLabel: l10n.budgetTypeSemantic,
        enabled: !instance.editing && instance.onSettingChanged != null,
        onSelected: (key) =>
            instance.onSettingChanged?.call(periodSetting, key),
      ),
    );
  }
}
