// The card of a chart's indicator, shared by the charts that show one on
// tap (Transactions > Charts, Finance > Overview cash flow): a title and a
// table of colored rows with their amounts, and optionally a total.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/shadows.dart';

/// Puts the card at the right of the indicator, or at its left when it
/// would not fit.
class SossoldiChartTooltipLayout extends SingleChildLayoutDelegate {
  SossoldiChartTooltipLayout(this.x);

  final double x;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    const gap = 8.0;
    final fitsRight = x + gap + childSize.width <= size.width;
    final left = fitsRight ? x + gap : math.max(0.0, x - gap - childSize.width);
    return Offset(left, 0);
  }

  @override
  bool shouldRelayout(SossoldiChartTooltipLayout old) => old.x != x;
}

class SossoldiChartTooltip extends StatelessWidget {
  const SossoldiChartTooltip({
    super.key,
    required this.title,
    required this.rows,
    required this.totalLabel,
    required this.masked,
    required this.formatValue,
    this.textRows = const [],
  });

  /// What the numbers are hidden with in Hidden Mode.
  static const String maskText = '••••';

  final String title;
  final List<(Color, String, double)> rows;
  final String? totalLabel;
  final bool masked;
  final String Function(double) formatValue;

  /// Rows that come with their text already written (a difference in money
  /// and percent): colored mark, name, text. Not part of the total.
  final List<(Color, String, String)> textRows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    String value(double v) => masked ? maskText : formatValue(v);
    // Name and amount share one size; the amounts sit right after the
    // longest name, in a column.
    final nameStyle = typography.labelSmall.copyWith(color: colors.textMed);
    final amountStyle = typography.labelSmall.copyWith(color: colors.textHigh);
    final totalStyle = typography.labelBoldSmall.copyWith(
      color: colors.textHigh,
    );
    TableRow row(
      Widget leading,
      String name,
      String amount, {
      TextStyle? amountText,
    }) => TableRow(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            leading,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(amount, style: amountText ?? amountStyle),
        ),
      ],
    );
    final total = rows.fold(0.0, (sum, r) => sum + r.$3);
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: SossoldiShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.labelBoldSmall.copyWith(color: colors.textHigh),
          ),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final (color, name, amount) in rows)
                row(
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  name,
                  value(amount),
                ),
              if (totalLabel != null && rows.length > 1)
                row(
                  const SizedBox(width: 8),
                  totalLabel!,
                  value(total),
                  amountText: totalStyle,
                ),
              for (final (color, name, text) in textRows)
                row(
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  name,
                  masked ? maskText : text,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
