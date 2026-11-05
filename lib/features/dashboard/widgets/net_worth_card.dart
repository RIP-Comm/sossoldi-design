// Net worth widget, sizes S, M and L. No Figma node: it follows Monthly
// balance (same card, title and amount, trend chart) with one series and no
// comparison. Presentation only: NetWorthWidget wires it to the repository.
//
// S: title, value and the chart. M and L: the headline has the period chip
// at the top right (as in the other widgets), then the value, the change in money and in percent; L has the taller
// chart, which takes the room the legend takes in Monthly balance.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../model/dashboard_layout.dart';
import 'dashboard_widget_header.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    super.key,
    required this.size,
    required this.title,
    required this.value,
    required this.currency,
    required this.values,
    required this.masked,
    required this.noDataText,
    required this.selector,
    required this.pointTitles,
    this.formatValue,
    this.change,
    this.changePercent,
  });

  final DashboardWidgetSize size;
  final String title;
  final double value;
  final String currency;

  /// Net worth in the period, oldest first; fewer than two: no chart.
  final List<double> values;
  final bool masked;
  final String noDataText;

  /// The period chip, at the top right (M and L).
  final Widget selector;

  /// Heading of the tooltip for each point of [values], and how it writes
  /// the amounts.
  final List<String> pointTitles;
  final String Function(double)? formatValue;

  /// In the period; null without history. The percentage is hidden when null.
  final double? change;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isS = size == DashboardWidgetSize.s;
    final tone = (change ?? 0) < 0
        ? SossoldiTrendTone.negative
        : SossoldiTrendTone.positive;

    final amount = Expanded(
      // Very large amounts shrink instead of wrapping or clipping.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SossoldiAmount(
          value: value,
          currencyCode: currency,
          masked: masked,
          style: typography.headlineSmall,
        ),
      ),
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
                if (isS)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelMedium.copyWith(
                      color: colors.textMed,
                    ),
                  )
                else
                  DashboardWidgetHeader(title: title, selector: selector),
                Row(children: [amount]),
                if (!isS && change != null)
                  Row(
                    spacing: SossoldiSpacing.xs,
                    children: [
                      SossoldiChangeTag.money(
                        value: change!,
                        currencyCode: currency,
                        masked: masked,
                      ),
                      if (changePercent != null)
                        SossoldiChangeTag.percent(
                          value: changePercent!,
                          masked: masked,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: isS ? SossoldiSpacing.l : SossoldiSpacing.m),
          Expanded(
            child: values.length < 2
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SossoldiSpacing.m,
                      ),
                      child: Text(
                        noDataText,
                        textAlign: TextAlign.center,
                        style: typography.labelMedium.copyWith(
                          color: colors.textMed,
                        ),
                      ),
                    ),
                  )
                : SossoldiTrendChart(
                    current: values,
                    length: values.length,
                    tone: tone,
                    pointTitles: pointTitles,
                    currentLabel: title,
                    // The S has no tooltip.
                    formatValue: isS ? null : formatValue,
                    masked: masked,
                  ),
          ),
        ],
      ),
    );
  }
}
