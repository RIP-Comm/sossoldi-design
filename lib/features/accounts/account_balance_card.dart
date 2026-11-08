// The balance of an account over a period: current balance with its change,
// the period chip and the trend chart. Same look as the Dashboard Net worth
// widget (M/L), in the account's own currency. Presentation only:
// AccountDetailScreen wires it to the controller.

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.values,
    required this.pointTitles,
    required this.formatValue,
    required this.selector,
    required this.masked,
    required this.noDataText,
    this.change,
    this.changePercent,
  });

  final double balance;
  final String currency;

  /// Balance in the period, oldest first; fewer than two: no chart.
  final List<double> values;
  final List<String> pointTitles;
  final String Function(double) formatValue;

  /// The period chip, at the top right.
  final Widget selector;
  final bool masked;
  final String noDataText;

  /// In the period; null without history. The percentage is hidden when null.
  final double? change;
  final double? changePercent;

  static const _chartHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tone = (change ?? 0) < 0
        ? SossoldiTrendTone.negative
        : SossoldiTrendTone.positive;
    return SossoldiWidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SossoldiSpacing.m,
              SossoldiSpacing.m,
              SossoldiSpacing.m,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SossoldiSpacing.s,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: SossoldiSpacing.xs,
                    children: [
                      // Very large amounts shrink instead of wrapping.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SossoldiAmount(
                          value: balance,
                          currencyCode: currency,
                          masked: masked,
                          style: typography.headlineSmall,
                        ),
                      ),
                      if (change != null)
                        SossoldiChangeIndicator(
                          amount: change!,
                          currencyCode: currency,
                          percent: changePercent,
                          masked: masked,
                        ),
                    ],
                  ),
                ),
                selector,
              ],
            ),
          ),
          const SizedBox(height: SossoldiSpacing.m),
          SizedBox(
            height: _chartHeight,
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
                    formatValue: formatValue,
                    masked: masked,
                  ),
          ),
        ],
      ),
    );
  }
}
