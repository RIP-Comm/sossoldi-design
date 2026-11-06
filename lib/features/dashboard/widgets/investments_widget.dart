import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_shell_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/investments_snapshot.dart';
import '../../../mock/models/portfolio.dart';
import '../../investments/investments_texts.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'dashboard_type_selector.dart';
import 'investments_card.dart';

/// The portfolio at a glance: value (positions + liquidity), daily and
/// year-to-date change (market performance, net of buys and sells) and, in L,
/// the Overview's market value chart over a period chosen with the chip. The
/// period is a setting of the placement, so it survives reordering and
/// resizing. A tap opens Investments > Overview.
class InvestmentsWidget extends StatelessWidget {
  const InvestmentsWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// Key of the period in the placement's settings.
  static const periodSetting = 'period';
  static const defaultPeriod = ValuePeriod.yearToDate;

  static ValuePeriod periodOf(Map<String, String> settings) {
    for (final p in ValuePeriod.values) {
      if (p.name == settings[periodSetting]) return p;
    }
    return defaultPeriod;
  }

  static InvestmentsChangeFigures? _figures(InvestmentChange? c) =>
      c == null ? null : (amount: c.amount, percent: c.percent);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final isL = size == DashboardWidgetSize.l;
    // S has no chip: it always shows the year to date.
    final period = size == DashboardWidgetSize.s
        ? ValuePeriod.yearToDate
        : periodOf(instance.settings);
    final snapshot = repo.investmentsSnapshot(period);
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    final points = snapshot.series.points;
    final texts = ValueChartTexts(context, snapshot.series);
    final scope = AppShellScope.maybeOf(context);
    final colors = context.colors;
    String money(double v) =>
        SossoldiAmountFormat.money(context, v, currencyCode: snapshot.currency);
    return InvestmentsCard(
      size: size,
      title: l10n.widgetInvestmentsName,
      value: snapshot.totalValue,
      currency: snapshot.currency,
      masked: context.hideAmounts,
      hasPositions: snapshot.hasPositions,
      emptyText: l10n.investmentsEmptyTitle,
      change: _figures(snapshot.periodChange),
      smallLabel: periodLabel(context, ValuePeriod.yearToDate),
      values: [for (final p in points) p.value],
      pointTitles: [for (final p in points) texts.title(p.time)],
      formatValue: size == DashboardWidgetSize.s ? null : money,
      onTap: instance.editing ? null : scope?.openInvestmentsOverview,
      selector: DashboardTypeSelector(
        label: periodLabel(context, period),
        options: [
          for (final p in ValuePeriod.values)
            (key: p.name, label: periodLabel(context, p)),
        ],
        selected: period.name,
        semanticLabel: l10n.widgetInvestmentsPeriodSemantic,
        enabled: !instance.editing && instance.onSettingChanged != null,
        onSelected: (key) =>
            instance.onSettingChanged?.call(periodSetting, key),
      ),
      legend: SossoldiChartLegend(
        items: [
          SossoldiLegendItem(
            color: points.isEmpty || points.last.difference >= 0
                ? colors.income.onSurface
                : colors.expense.onSurface,
            label: l10n.legendMarketValue,
          ),
          SossoldiLegendItem(
            color: colors.shapeMed,
            label: l10n.legendInvested,
          ),
        ],
      ),
      chart: (plotHeight) => !isL || points.length < 2
          ? const SizedBox.shrink()
          : SossoldiValueChart(
              // A new period starts a new chart (no leftover indicator).
              key: ValueKey(period),
              height: plotHeight,
              values: [for (final p in points) p.value],
              invested: [for (final p in points) p.invested],
              pointLabels: [for (final p in points) texts.label(p.time)],
              pointTitles: [for (final p in points) texts.title(p.time)],
              formatAxis: compact.format,
              formatValue: money,
              valueLabel: l10n.legendMarketValue,
              investedLabel: l10n.legendInvested,
              masked: context.hideAmounts,
              semanticLabel: l10n.marketValueSemantics,
            ),
    );
  }
}
