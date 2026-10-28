// Monthly balance widget, sizes S, M and L, from Figma "Saldo complessivo -
// Widget content" (nodes 13:3943, 13:3952, 13:3969). Presentation only:
// data and texts come in by parameters; MonthlyBalanceWidget wires it to
// the repository and l10n.
//
// The figure is income minus expenses of the current month. The chart
// shows it day by day (solid, green or red by sign) against the previous
// month (dashed). M adds the comparison with the same day of last month;
// L adds income, expenses and the chart legend.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../mock/models/balance_trend.dart';
import '../model/dashboard_layout.dart';

class MonthlyBalanceCard extends StatelessWidget {
  const MonthlyBalanceCard({
    super.key,
    required this.size,
    required this.title,
    required this.trend,
    required this.masked,
    this.comparisonLabel = '',
    this.incomeLabel = '',
    this.expenseLabel = '',
    this.thisMonthLabel = '',
    this.lastMonthLabel = '',
  });

  final DashboardWidgetSize size;
  final String title;
  final BalanceTrend trend;

  /// Hides the amounts (Hidden Mode). The chart stays visible: it has no
  /// figures.
  final bool masked;

  /// M and L: caption next to the change tag.
  final String comparisonLabel;

  /// L only.
  final String incomeLabel;
  final String expenseLabel;
  final String thisMonthLabel;
  final String lastMonthLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tone = trend.net < 0
        ? SossoldiTrendTone.negative
        : SossoldiTrendTone.positive;
    final isS = size == DashboardWidgetSize.s;
    final isL = size == DashboardWidgetSize.l;

    final titleAndAmount = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.labelMedium.copyWith(color: colors.textMed),
        ),
        // Very large amounts shrink instead of wrapping or clipping.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SossoldiAmount(
            value: trend.net,
            currencyCode: trend.currency,
            masked: masked,
            style: typography.headlineSmall,
          ),
        ),
      ],
    );

    Widget figure(String label, double value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SossoldiSpacing.xs,
      children: [
        Text(
          label,
          style: typography.labelSmall.copyWith(color: colors.textMed),
        ),
        SossoldiAmount(
          value: value,
          currencyCode: trend.currency,
          tone: SossoldiAmountTone.signed,
          showPlusSign: true,
          masked: masked,
        ),
      ],
    );

    return SossoldiWidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SossoldiSpacing.m,
              SossoldiSpacing.s,
              SossoldiSpacing.m,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.xs,
              children: [
                if (isL)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: SossoldiSpacing.m,
                    children: [
                      Expanded(child: titleAndAmount),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          spacing: SossoldiSpacing.m,
                          children: [
                            figure(incomeLabel, trend.income),
                            figure(expenseLabel, -trend.expenses),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  titleAndAmount,
                if (!isS)
                  Row(
                    spacing: SossoldiSpacing.xs,
                    children: [
                      SossoldiChangeTag.money(
                        value: trend.vsPreviousSameDay,
                        currencyCode: trend.currency,
                        masked: masked,
                      ),
                      Expanded(
                        child: Text(
                          comparisonLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.captionSmall.copyWith(
                            color: colors.textMed,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: isS ? SossoldiSpacing.l : SossoldiSpacing.m),
          Expanded(
            child: SossoldiTrendChart(
              current: trend.current,
              length: trend.daysInPeriod,
              reference: trend.previous,
              tone: tone,
            ),
          ),
          if (isL)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SossoldiSpacing.m,
                SossoldiSpacing.s,
                SossoldiSpacing.m,
                SossoldiSpacing.m,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SossoldiTrendLegend(
                  currentLabel: thisMonthLabel,
                  referenceLabel: lastMonthLabel,
                  tone: tone,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
