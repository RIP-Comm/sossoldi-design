// Finance > Transactions > Charts, from Figma "2.1.0 - Finance -
// Transactions" (node 13:4603): time range and filters, Expenses/Income,
// the period total with its change, the donut by category and the
// breakdown over time. The numbers come from the controller, i.e. from
// MockRepository.transactionBreakdown; nothing is computed here.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/transaction_breakdown.dart';
import '../../../mock/models/transaction_time_range.dart';
import 'chart_formatters.dart';
import 'transaction_charts_controller.dart';
import 'transaction_charts_filters_sheet.dart';

class TransactionChartsView extends StatelessWidget {
  const TransactionChartsView({super.key, required this.controller});

  final TransactionChartsController controller;

  Future<void> _openFilters(BuildContext context) async {
    final chosen = await showTransactionChartsFiltersSheet(
      context,
      repository: context.repository,
      kind: controller.kind,
      accountIds: controller.accountIds,
      categoryIds: controller.categoryIds,
    );
    if (chosen == null) return;
    // Categories picked for the other kind stay as they were.
    final others = {
      for (final id in controller.allSelectedCategoryIds)
        if (!controller.categoryIds.contains(id)) id,
    };
    controller.applyFilters(
      accountIds: chosen.accountIds,
      categoryIds: {...others, ...chosen.categoryIds},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final masked = context.hideAmounts;
    final b = controller.breakdown;
    final allowed = controller.allowedGranularities;

    String money(double v) =>
        SossoldiAmountFormat.money(context, v, currencyCode: repo.mainCurrency);
    String amount(double v) => masked ? '••••' : money(v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: SossoldiSpacing.m,
              children: [
                Expanded(
                  child: SossoldiSelect<TransactionTimeRange>(
                    label: l10n.chartsSelectTimeRange,
                    value: controller.range,
                    onChanged: controller.setRange,
                    items: [
                      for (final r in TransactionTimeRange.values)
                        SossoldiSelectItem(
                          value: r,
                          label: timeRangeLabel(context, r),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: SossoldiFilterButton(
                    semanticLabel: l10n.filters,
                    active: controller.activeFilterCount > 0,
                    onPressed: () => _openFilters(context),
                  ),
                ),
              ],
            ),
            SossoldiTabNavigation(
              tabs: [
                SossoldiTabData.text(l10n.kindExpenses),
                SossoldiTabData.text(l10n.kindIncome),
              ],
              selectedIndex: controller.kind.index,
              onChanged: (i) => controller.setKind(TransactionKind.values[i]),
            ),
          ],
        ),
        _TotalCard(breakdown: b, controller: controller),
        if (b.isEmpty)
          _Card(
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.chartPie,
              title: l10n.emptyChartsTitle,
              message: l10n.emptyChartsFiltered,
              actionLabel: controller.activeFilterCount > 0
                  ? l10n.clearFilters
                  : null,
              onAction: controller.activeFilterCount > 0
                  ? controller.clearFilters
                  : null,
            ),
          )
        else ...[
          _Section(
            title: l10n.chartCategoriesBreakdown,
            child: Column(
              spacing: SossoldiSpacing.m,
              children: [
                SossoldiDonutChart(
                  semanticLabel: l10n.chartDonutSemantics,
                  segments: [
                    for (final c in b.categories)
                      SossoldiChartSegment(
                        value: c.amount,
                        color: repo.category(c.categoryId).color.main,
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SossoldiChartLegend(
                    items: [
                      for (final c in b.categories)
                        SossoldiLegendItem(
                          color: repo.category(c.categoryId).color.main,
                          label: repo.category(c.categoryId).name,
                          value: amount(c.amount),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l10n.chartBreakdownOverTime,
            child: _OverTime(
              // A new data set starts without a selected point.
              key: ObjectKey(b),
              breakdown: b,
              allowed: allowed,
              onGranularity: controller.setGranularity,
              masked: masked,
              money: money,
            ),
          ),
        ],
      ],
    );
  }
}

/// A white rounded card, as the Figma "Insight" frames.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(SossoldiSpacing.m),
    decoration: ShapeDecoration(
      color: context.colors.surfaceHigh,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(SossoldiRadius.m),
      ),
    ),
    child: child,
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: SossoldiSpacing.s,
    children: [
      Text(
        title,
        style: context.typography.titleMedium.copyWith(
          color: context.colors.textHigh,
        ),
      ),
      _Card(child: child),
    ],
  );
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.breakdown, required this.controller});

  final TransactionBreakdown breakdown;
  final TransactionChartsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = context.repository;
    final isExpense = breakdown.kind == TransactionKind.expense;
    final change = breakdown.changeVsPrevious;
    // The color is about meaning, not sign: more expenses is bad news,
    // more income is good news.
    final good = change == null
        ? true
        : isExpense
        ? change <= 0
        : change >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: SossoldiSpacing.s,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chartTotal,
                  style: typography.labelMedium.copyWith(color: colors.textMed),
                ),
                SossoldiAmount(
                  value: isExpense && breakdown.total > 0
                      ? -breakdown.total
                      : breakdown.total,
                  currencyCode: repo.mainCurrency,
                  showPlusSign: !isExpense,
                  masked: context.hideAmounts,
                  tone: breakdown.total == 0
                      ? SossoldiAmountTone.neutral
                      : SossoldiAmountTone.signed,
                  style: typography.labelBoldXLarge,
                ),
              ],
            ),
          ),
          if (change != null)
            SossoldiChip(
              label: l10n.changeVsPrevious(
                SossoldiAmountFormat.percent(context, change, decimalDigits: 0),
              ),
              type: good ? SossoldiChipType.income : SossoldiChipType.expense,
            ),
        ],
      ),
    );
  }
}

class _OverTime extends StatelessWidget {
  const _OverTime({
    super.key,
    required this.breakdown,
    required this.allowed,
    required this.onGranularity,
    required this.masked,
    required this.money,
  });

  final TransactionBreakdown breakdown;
  final List<TransactionGranularity> allowed;
  final ValueChanged<TransactionGranularity> onGranularity;
  final bool masked;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final format = ChartFormatters(context, breakdown);
    final categories = breakdown.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        SossoldiSelect<TransactionGranularity>(
          label: l10n.chartSnapshot,
          value: breakdown.granularity,
          onChanged: onGranularity,
          items: [
            SossoldiSelectItem(
              value: TransactionGranularity.weekly,
              label: l10n.granularityWeekly,
              enabled: allowed.contains(TransactionGranularity.weekly),
            ),
            SossoldiSelectItem(
              value: TransactionGranularity.monthly,
              label: l10n.granularityMonthly,
              enabled: allowed.contains(TransactionGranularity.monthly),
            ),
          ],
        ),
        SossoldiStackedAreaChart(
          semanticLabel: l10n.chartAreaSemantics,
          masked: masked,
          totalLabel: l10n.chartTotal,
          formatValue: money,
          formatAxis: format.axisNumber,
          pointLabels: [for (final x in breakdown.buckets) format.axisLabel(x)],
          pointTitles: [for (final x in breakdown.buckets) format.title(x)],
          series: [
            // The largest category at the bottom, like the legend order.
            for (final c in categories)
              SossoldiAreaSeries(
                name: repo.category(c.categoryId).name,
                color: repo.category(c.categoryId).color.main,
                values: [
                  for (final x in breakdown.buckets)
                    x.amounts[c.categoryId] ?? 0,
                ],
              ),
          ],
        ),
        SossoldiChartLegend(
          items: [
            for (final c in categories)
              SossoldiLegendItem(
                color: repo.category(c.categoryId).color.main,
                label: repo.category(c.categoryId).name,
              ),
          ],
        ),
      ],
    );
  }
}
