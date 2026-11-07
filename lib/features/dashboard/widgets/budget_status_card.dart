// Budget status widget, sizes S, M and L. No Figma node: it follows the
// budget card of the Finance Overview carousel (name, period chip, "50% ·
// 120 € left", bar) in the style of the other Dashboard widgets.
// Presentation only: BudgetStatusWidget wires it to the repository.
//
// S shows the first budget, large; M and L have a header (title and the
// budget-type selector) and a list, as many rows as fit (3 in M, at most 6).
// In M the rows are compact: the period chip beside the name, a thin bar.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../model/dashboard_layout.dart';
import 'budget_status_row.dart';
import 'dashboard_widget_header.dart';

class BudgetStatusCard extends StatelessWidget {
  const BudgetStatusCard({
    super.key,
    required this.size,
    required this.rows,
    required this.title,
    required this.emptyText,
    required this.selector,
  });

  final DashboardWidgetSize size;

  /// Most relevant first.
  final List<BudgetStatusRow> rows;

  /// "Budget" (M and L).
  final String title;
  final String emptyText;

  /// The type chip, on the right of the header (M and L).
  final Widget selector;

  static const int maxRows = 6;

  /// Least height of the container of one budget (the row plus 4 above and
  /// below): the rows are centered in containers that share the height left.
  static const double _minContainer = 36;

  @override
  Widget build(BuildContext context) {
    if (size == DashboardWidgetSize.s) {
      return SossoldiWidgetCard(
        child: rows.isEmpty
            ? _Empty(text: emptyText)
            : _Single(row: rows.first),
      );
    }
    final compact = size == DashboardWidgetSize.m;
    return SossoldiWidgetCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SossoldiSpacing.m,
          vertical: SossoldiSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardWidgetHeader(title: title, selector: selector),
            Expanded(
              child: rows.isEmpty
                  ? _Empty(text: emptyText)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Each budget has a container of the same height with
                        // the row centered in it.
                        final fit = (constraints.maxHeight / _minContainer)
                            .floor();
                        final slots = fit.clamp(1, maxRows);
                        // Containers keep the height of a full list, so a
                        // few budgets stay at the top.
                        final slotHeight = constraints.maxHeight / slots;
                        return Column(
                          children: [
                            for (final row in rows.take(slots))
                              SizedBox(
                                height: slotHeight,
                                child: Center(
                                  child: _Row(row: row, compact: compact),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.typography.labelLarge.copyWith(
          color: context.colors.textMed,
        ),
      ),
    ),
  );
}

Color _figureColor(BuildContext context, SossoldiBudgetTone tone) =>
    switch (tone) {
      SossoldiBudgetTone.ok => context.colors.textHigh,
      SossoldiBudgetTone.warning => context.colors.warning.text,
      SossoldiBudgetTone.exceeded => context.colors.error.text,
    };

/// "50% 120 € left" as in the budget list of Finance (also used by the
/// Insight widget): the percentage bold
/// in the tone color, then what is left; over the limit the percentage is an
/// error chip.
Widget budgetStatusFigures(BuildContext context, BudgetStatusRow row) {
  final typography = context.typography;
  if (row.tone == SossoldiBudgetTone.exceeded) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiChip(label: row.percent, type: SossoldiChipType.error),
        Flexible(
          child: Text(
            row.remaining,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.labelMedium.copyWith(
              color: context.colors.error.text,
            ),
          ),
        ),
      ],
    );
  }
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: row.percent,
          style: typography.labelBoldLarge.copyWith(
            color: _figureColor(context, row.tone),
          ),
        ),
        TextSpan(
          text: ' ${row.remaining}',
          style: typography.labelMedium.copyWith(color: context.colors.textMed),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.compact});

  final BudgetStatusRow row;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: compact ? SossoldiSpacing.xs : SossoldiSpacing.s,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            spacing: SossoldiSpacing.m,
            children: [
              // The name stays whole until the chip is a step away from
              // the figures.
              Expanded(
                child: Row(
                  spacing: SossoldiSpacing.xs,
                  children: [
                    Flexible(
                      child: Text(
                        row.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.labelLarge.copyWith(
                          color: context.colors.textHigh,
                        ),
                      ),
                    ),
                    // The chip gives way too when the figures take the room.
                    Flexible(
                      child: SossoldiChip(
                        label: row.periodLabel,
                        type: SossoldiChipType.subtle,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.6,
                ),
                child: budgetStatusFigures(context, row),
              ),
            ],
          ),
        ),
        SossoldiBudgetBar(
          value: row.usage,
          color: row.color,
          trackColor: row.trackColor,
          thickness: compact ? 4 : SossoldiBudgetBar.height,
        ),
      ],
    );
    return row.onTap == null
        ? content
        : SossoldiTappable(onTap: row.onTap, child: content);
  }
}

/// The big percentage of the S widget (also used by the Insight widget): text only, and with a chip-style
/// error background when the budget is exceeded.
class BudgetPercentBadge extends StatelessWidget {
  const BudgetPercentBadge({
    super.key,
    required this.text,
    required this.tone,
    required this.style,
  });

  final String text;
  final SossoldiBudgetTone tone;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final exceeded = tone == SossoldiBudgetTone.exceeded;
    final label = Text(
      text,
      style: style.copyWith(color: _figureColor(context, tone)),
    );
    if (!exceeded) return label;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.error.surface,
        borderRadius: BorderRadius.circular(SossoldiChip.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SossoldiSpacing.xs + 2,
          vertical: 2,
        ),
        child: label,
      ),
    );
  }
}

class _Single extends StatelessWidget {
  const _Single({required this.row});

  final BudgetStatusRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final exceeded = row.tone == SossoldiBudgetTone.exceeded;
    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SossoldiChip(
              label: row.periodLabel,
              type: SossoldiChipType.subtle,
            ),
          ),
          Text(
            row.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.bodyBoldXLarge.copyWith(color: colors.textHigh),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BudgetPercentBadge(
              text: row.percent,
              tone: row.tone,
              style: typography.titleLarge,
            ),
          ),
          Text(
            row.remaining,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.labelLarge.copyWith(
              color: exceeded ? colors.error.text : colors.textMed,
            ),
          ),
          SossoldiBudgetBar(
            value: row.usage,
            color: row.color,
            trackColor: row.trackColor,
          ),
        ],
      ),
    );
    return row.onTap == null
        ? body
        : SossoldiTappable(onTap: row.onTap, child: body);
  }
}
