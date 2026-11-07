// Asset allocation widget, sizes S, M and L. No Figma node: it follows the
// other widgets and reuses the donut and legend of the Investments Overview.
// Presentation only: AllocationWidget wires it to the repository.
//
// S: title with a small donut at its right and the first rows under it (small
// text, the donut takes the room left). M: donut at the left, legend at the
// right. L: the two-way selector at the top right, a bigger donut and the
// legend. Every legend row has name, percentage and amount.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../model/dashboard_layout.dart';
import 'dashboard_widget_header.dart';

/// One row of the legend; [percentText] already written.
typedef AllocationLegendRow = ({
  Color color,
  String label,
  String percentText,
  double value,
});

class AllocationCard extends StatelessWidget {
  const AllocationCard({
    super.key,
    required this.size,
    required this.title,
    required this.rows,
    required this.currency,
    required this.masked,
    required this.hasPositions,
    required this.emptyText,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
    required this.semanticLabel,
    this.onTap,
  });

  final DashboardWidgetSize size;
  final String title;
  final List<AllocationLegendRow> rows;
  final String currency;
  final bool masked;
  final bool hasPositions;
  final String emptyText;

  /// L: the labels of the selector, the selected one and the callback (null
  /// disables it: edit mode).
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int>? onTabChanged;
  final String semanticLabel;

  /// Tap on the widget (not on the selector).
  final VoidCallback? onTap;

  static const double _rowS = 16;
  static const double _rowM = 16;
  static const double _rowL = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isS = size == DashboardWidgetSize.s;
    final isL = size == DashboardWidgetSize.l;
    // One step up from S in M and L.
    final base = isS ? typography.labelSmall : typography.labelMedium;
    final small = base.copyWith(color: colors.textMed);
    final strong = base.copyWith(color: colors.textHigh);
    final rowHeight = isS
        ? _rowS
        : isL
        ? _rowL
        : _rowM;
    // Space between the rows: the legend of L is tighter when it has many.
    final rowGap = isS
        ? 0.0
        : isL
        ? (rows.length > 6 ? 2.0 : 6.0)
        : 4.0;

    Widget donut(double dimension, double thickness) => SossoldiDonutChart(
      size: dimension,
      thickness: thickness,
      semanticLabel: semanticLabel,
      segments: [
        for (final r in rows)
          SossoldiChartSegment(value: r.value, color: r.color),
      ],
    );

    String money(double v) => masked
        ? '••••'
        : SossoldiAmountFormat.money(
            context,
            v,
            currencyCode: currency,
            decimalDigits: isS ? 0 : null,
          );

    // Name at the left; percentage and amount side by side at the right, each
    // column as wide as its widest figure.
    Widget legend() {
      Widget cell(
        int i,
        Widget child,
        Alignment alignment, {
        double left = 0,
      }) => Padding(
        padding: EdgeInsets.only(
          left: left,
          bottom: i == rows.length - 1 ? 0 : rowGap,
        ),
        child: SizedBox(
          height: rowHeight,
          child: Align(alignment: alignment, child: child),
        ),
      );
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          for (final (i, r) in rows.indexed)
            TableRow(
              children: [
                cell(
                  i,
                  // Dot and name in one line of text: with little room left
                  // by the figures the name is cut, never an overflow.
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              right: SossoldiSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: r.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        TextSpan(text: r.label),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: small,
                  ),
                  Alignment.centerLeft,
                ),
                cell(
                  i,
                  Text(r.percentText, style: strong),
                  Alignment.centerRight,
                  left: SossoldiSpacing.xs,
                ),
                cell(
                  i,
                  Text(money(r.value), maxLines: 1, style: small),
                  Alignment.centerRight,
                  left: SossoldiSpacing.xs,
                ),
              ],
            ),
        ],
      );
    }

    final titleStyle = isS
        ? typography.labelMedium.copyWith(color: colors.textMed)
        : typography.labelBoldLarge.copyWith(color: colors.textHigh);
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: titleStyle,
    );

    final selector = IgnorePointer(
      ignoring: onTabChanged == null,
      child: SizedBox(
        width: 292,
        child: SossoldiTabNavigation(
          tabs: [for (final t in tabs) SossoldiTabData.text(t)],
          selectedIndex: selectedTab,
          onChanged: (i) => onTabChanged?.call(i),
        ),
      ),
    );

    final Widget content;
    if (!hasPositions) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          isL ? Row(children: [Expanded(child: titleText)]) : titleText,
          Expanded(
            child: Column(
              spacing: SossoldiSpacing.s,
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, c) => donut(
                        (c.maxHeight - 4).clamp(40.0, isL ? 160.0 : 96.0),
                        isL ? 16 : 10,
                      ),
                    ),
                  ),
                ),
                Text(emptyText, textAlign: TextAlign.center, style: small),
              ],
            ),
          ),
        ],
      );
    } else if (isS) {
      // The donut sits at the right, beside the title, and takes the room the
      // rows leave.
      content = LayoutBuilder(
        builder: (context, c) {
          final legendHeight = rows.length * rowHeight;
          // The title is always shown whole: the donut gets what is left of
          // the width, and of the height under the rows.
          final titleWidth = (TextPainter(
            text: TextSpan(text: title, style: titleStyle),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout()).width;
          final dimension = [
            c.maxHeight - legendHeight - 4,
            c.maxWidth - titleWidth - SossoldiSpacing.s,
            88.0,
          ].reduce((a, b) => a < b ? a : b).clamp(32.0, 88.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              SizedBox(
                height: dimension,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleText),
                    donut(dimension, 8),
                  ],
                ),
              ),
              legend(),
            ],
          );
        },
      );
    } else if (isL) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.s,
        children: [
          SizedBox(
            height: DashboardWidgetHeader.height,
            child: Align(alignment: Alignment.centerLeft, child: titleText),
          ),
          Center(child: selector),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final legendHeight =
                    rows.length * rowHeight + (rows.length - 1) * rowGap;
                // The donut takes what the legend leaves and pushes it down.
                final dimension = (c.maxHeight - legendHeight - 8).clamp(
                  64.0,
                  168.0,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(child: donut(dimension, 20)),
                    legend(),
                  ],
                );
              },
            ),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          SizedBox(
            height: DashboardWidgetHeader.height,
            child: Align(alignment: Alignment.centerLeft, child: titleText),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Row(
                spacing: SossoldiSpacing.m,
                children: [
                  donut(c.maxHeight.clamp(40.0, 112.0), 14),
                  Expanded(child: Center(child: legend())),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SossoldiWidgetCard(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SossoldiSpacing.m),
          child: content,
        ),
      ),
    );
  }
}
