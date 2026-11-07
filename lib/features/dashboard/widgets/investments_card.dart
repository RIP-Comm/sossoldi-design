// Investments widget, sizes S, M and L. No Figma node: it follows Net worth
// (same card, title, amount and change). Presentation only: InvestmentsWidget
// wires it to the repository.
//
// S: title with a "YTD" label, value, the year-to-date change under it and the
// trend chart edge to edge (no axes, no legend, no tooltip). M: the period chip
// at the top right (default YTD), the change of the period at the right of the
// value and the chart of the period (tooltip). L: the same with the market
// value chart of the Investments Overview (axes, legend).

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../model/dashboard_layout.dart';
import 'dashboard_widget_header.dart';

typedef InvestmentsChangeFigures = ({double amount, double? percent});

class InvestmentsCard extends StatelessWidget {
  const InvestmentsCard({
    super.key,
    required this.size,
    required this.title,
    required this.value,
    required this.currency,
    required this.masked,
    required this.hasPositions,
    required this.emptyText,
    required this.change,
    required this.smallLabel,
    required this.selector,
    required this.values,
    required this.pointTitles,
    required this.formatValue,
    required this.chart,
    required this.legend,
    this.onTap,
  });

  final DashboardWidgetSize size;
  final String title;
  final double value;
  final String currency;
  final bool masked;

  /// Without positions only the title and [emptyText] are shown.
  final bool hasPositions;
  final String emptyText;

  /// The change the size shows (S year to date, M and L of the chosen period);
  /// null when there is no history: nothing is drawn.
  final InvestmentsChangeFigures? change;

  /// S only: what the change refers to (no chip in S).
  final String smallLabel;

  /// The period chip (M and L), at the top right.
  final Widget selector;

  /// S and M: the trend chart (oldest first), its tooltip headings and how it
  /// writes amounts (M only; S has no tooltip).
  final List<double> values;
  final List<String> pointTitles;
  final String Function(double)? formatValue;

  /// L: the chart, which receives the plot height it gets.
  final Widget Function(double plotHeight) chart;

  /// L: the legend under the chart.
  final Widget legend;

  /// Tap on the figures (not on the chart).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isS = size == DashboardWidgetSize.s;
    final isL = size == DashboardWidgetSize.l;

    final titleText = isS
        ? Row(
            spacing: SossoldiSpacing.xs,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.labelMedium.copyWith(color: colors.textMed),
                ),
              ),
              Text(
                smallLabel,
                style: typography.labelSmall.copyWith(color: colors.textMed),
              ),
            ],
          )
        : DashboardWidgetHeader(title: title, selector: selector);

    final amount = Flexible(
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

    Widget changeIndicator(InvestmentsChangeFigures f) =>
        SossoldiChangeIndicator(
          amount: f.amount,
          currencyCode: currency,
          percent: f.percent,
          masked: masked,
        );

    final top = Padding(
      padding: const EdgeInsets.fromLTRB(
        SossoldiSpacing.m,
        SossoldiSpacing.m,
        SossoldiSpacing.m,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          titleText,
          if (hasPositions) ...[
            Row(
              spacing: SossoldiSpacing.s,
              children: [
                amount,
                if (!isS && change != null) changeIndicator(change!),
              ],
            ),
            if (isS && change != null)
              Align(
                alignment: Alignment.centerLeft,
                child: changeIndicator(change!),
              ),
          ],
        ],
      ),
    );

    if (!hasPositions) {
      return SossoldiWidgetCard(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              top,
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SossoldiSpacing.m,
                    ),
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: typography.labelMedium.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isL) {
      return SossoldiWidgetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: top,
            ),
            const SizedBox(height: SossoldiSpacing.s),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SossoldiSpacing.m,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => chart(
                    (constraints.maxHeight - SossoldiValueChart.xAxisHeight)
                        .clamp(40.0, double.infinity),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SossoldiSpacing.m,
                SossoldiSpacing.xs,
                SossoldiSpacing.m,
                SossoldiSpacing.m,
              ),
              child: legend,
            ),
          ],
        ),
      );
    }

    final tone = (change?.amount ?? 0) < 0
        ? SossoldiTrendTone.negative
        : SossoldiTrendTone.positive;
    return SossoldiWidgetCard(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            top,
            SizedBox(height: isS ? SossoldiSpacing.s : SossoldiSpacing.m),
            Expanded(
              child: values.length < 2
                  ? const SizedBox.shrink()
                  : SossoldiTrendChart(
                      current: values,
                      length: values.length,
                      tone: tone,
                      pointTitles: pointTitles,
                      currentLabel: title,
                      formatValue: formatValue,
                      masked: masked,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
