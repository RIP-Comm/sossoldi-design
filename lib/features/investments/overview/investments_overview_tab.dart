// Investments > Overview, from Figma (node 13:4855): the digest, the
// portfolio value card, the market value chart and the asset allocation.
// Every number comes from the repository; nothing is computed here.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/portfolio.dart';
import '../investments_controller.dart';
import '../portfolio_value_card.dart';
import '../investments_texts.dart';

class InvestmentsOverviewTab extends StatelessWidget {
  const InvestmentsOverviewTab({super.key, required this.controller});

  final InvestmentsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final empty = repo.holdings.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiAlertCarousel(
          alerts: [
            for (final m in repo.investmentDigest())
              SossoldiAlert(
                tone: investmentDigestTone(m.rule),
                title: investmentDigestText(context, m).title,
                message: investmentDigestText(context, m).message,
              ),
          ],
        ),
        const PortfolioValueCard(),
        if (empty)
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.chartLineUp,
              title: l10n.investmentsEmptyTitle,
              message: l10n.investmentsEmptyHint,
            ),
          )
        else ...[
          _Section(
            title: l10n.investmentsMarketValue,
            child: _MarketValue(controller: controller),
          ),
          _Section(
            title: l10n.investmentsAllocations,
            child: _Allocation(controller: controller),
          ),
        ],
      ],
    );
  }
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
      child,
    ],
  );
}

Widget _card(BuildContext context, {required Widget child}) => Container(
  padding: const EdgeInsets.all(SossoldiSpacing.m),
  decoration: ShapeDecoration(
    color: context.colors.surfaceHigh,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(SossoldiRadius.m),
    ),
  ),
  child: child,
);

class _MarketValue extends StatelessWidget {
  const _MarketValue({required this.controller});

  final InvestmentsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final series = repo.marketValueSeries(controller.period);
    final texts = ValueChartTexts(context, series);
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    final points = series.points;
    String money(double v) =>
        SossoldiAmountFormat.money(context, v, currencyCode: series.currency);
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          SossoldiTabNavigation(
            tabs: [
              for (final p in ValuePeriod.values)
                SossoldiTabData.text(periodLabel(context, p)),
            ],
            selectedIndex: controller.period.index,
            onChanged: (i) => controller.selectPeriod(ValuePeriod.values[i]),
          ),
          SossoldiValueChart(
            // A new period starts a new chart (no leftover indicator).
            key: ValueKey(controller.period),
            values: [for (final p in points) p.value],
            invested: [for (final p in points) p.invested],
            pointLabels: [for (final p in points) texts.label(p.time)],
            pointTitles: [for (final p in points) texts.title(p.time)],
            formatAxis: (v) => compact.format(v),
            formatValue: money,
            valueLabel: l10n.legendMarketValue,
            investedLabel: l10n.legendInvested,
            masked: context.hideAmounts,
            semanticLabel: l10n.marketValueSemantics,
          ),
          SossoldiChartLegend(
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
        ],
      ),
    );
  }
}

class _Allocation extends StatelessWidget {
  const _Allocation({required this.controller});

  final InvestmentsController controller;

  /// Colors of the slices, from the category palette; the liquidity is grey.
  static const _palette = [25, 12, 28, 5, 0, 17];
  static const _classColors = {
    AssetClass.etf: 25,
    AssetClass.stock: 28,
    AssetClass.bond: 5,
    AssetClass.other: 12,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final slices = repo.assetAllocation(controller.allocation);
    // An asset class keeps its color; single assets take them in turn.
    Color colorOf(int i, AllocationSlice s) => switch (s.kind) {
      AllocationKind.liquidity => colors.shapeLow,
      AllocationKind.other => colors.shapeMed,
      AllocationKind.assetClass =>
        CategoryColors.all[_classColors[s.assetClass]!].main,
      AllocationKind.asset =>
        CategoryColors.all[_palette[i % _palette.length]].main,
    };
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.l,
        children: [
          SossoldiTabNavigation(
            tabs: [
              SossoldiTabData.text(l10n.allocationAssetClass),
              SossoldiTabData.text(l10n.allocationSingleAsset),
            ],
            selectedIndex: controller.allocation.index,
            onChanged: (i) =>
                controller.selectAllocation(AllocationMode.values[i]),
          ),
          Center(
            child: SossoldiDonutChart(
              semanticLabel: l10n.allocationSemantics,
              segments: [
                for (final (i, s) in slices.indexed)
                  SossoldiChartSegment(value: s.value, color: colorOf(i, s)),
              ],
            ),
          ),
          SossoldiChartLegend(
            items: [
              for (final (i, s) in slices.indexed)
                SossoldiLegendItem(
                  color: colorOf(i, s),
                  label: '${allocationLabel(context, s)}:',
                  value: SossoldiAmountFormat.percent(
                    context,
                    s.share,
                    showPlusSign: false,
                    decimalDigits: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
