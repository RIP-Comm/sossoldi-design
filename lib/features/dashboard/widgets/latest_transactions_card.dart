// Latest transactions widget (also drawn by Upcoming recurring, with a date
// chip per entry), sizes S, M and L, from Figma "Latest
// transactions - Widget content" (nodes 13:3987, 13:3999, 13:4005).
// Presentation only: LatestTransactionsWidget wires it to the repository.
//
// S shows the most recent transaction large; M and L have a headline (title
// and type chip) and a list of rows, as many as fit (the rows of M are the ones of L).

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../model/dashboard_layout.dart';
import 'dashboard_widget_header.dart';
import 'latest_transaction_entry.dart';

class LatestTransactionsCard extends StatelessWidget {
  const LatestTransactionsCard({
    super.key,
    required this.size,
    required this.entries,
    required this.masked,
    required this.title,
    required this.selector,
    this.emptyText,
  });

  final DashboardWidgetSize size;

  /// Newest first.
  final List<LatestTransactionEntry> entries;
  final bool masked;

  /// Headline of M and L, with the type chip at its right.
  final String title;
  final Widget selector;

  /// Shown with no entries; default: no transactions yet.
  final String? emptyText;

  /// Height of a list row in M and L (8 + 36 + 8; with a date chip 4 + 44 + 4).
  static const double _rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    final empty = Center(
      child: Padding(
        padding: const EdgeInsets.all(SossoldiSpacing.m),
        child: Text(
          emptyText ?? context.l10n.dashboardNoTransactions,
          textAlign: TextAlign.center,
          style: context.typography.labelLarge.copyWith(
            color: context.colors.textMed,
          ),
        ),
      ),
    );
    if (size == DashboardWidgetSize.s) {
      return SossoldiWidgetCard(
        child: entries.isEmpty
            ? empty
            : _Single(entry: entries.first, masked: masked),
      );
    }
    return SossoldiWidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: SossoldiSpacing.m,
              right: SossoldiSpacing.m,
              top: SossoldiSpacing.m,
            ),
            child: DashboardWidgetHeader(title: title, selector: selector),
          ),
          Expanded(
            child: entries.isEmpty
                ? empty
                : Padding(
                    // The rows carry some padding of their own: the rest of
                    // the 12 px under the last one.
                    padding: EdgeInsets.only(
                      bottom: SossoldiSpacing.m - _rowPadding(entries.first),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final height = _rowHeight;
                        final fit = (constraints.maxHeight / height).floor();
                        final count = fit.clamp(1, entries.length);
                        return Column(
                          // L: what is left goes between the rows, so they
                          // are not stuck together; M keeps the same rhythm as L (rows 52 apart).
                          mainAxisAlignment:
                              size == DashboardWidgetSize.l && count == fit
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: [
                            for (final entry in entries.take(count))
                              _row(entry, masked: masked),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// The vertical padding of a row of the list (see [SossoldiTransactionItem]).
  static double _rowPadding(LatestTransactionEntry e) =>
      e.dateLabel != null ? SossoldiSpacing.xs : SossoldiSpacing.s;

  static Widget _row(LatestTransactionEntry e, {required bool masked}) =>
      Builder(
        builder: (context) => SossoldiTransactionItem(
          type: e.type,
          leading: Icon(
            e.icon,
            size: 24,
            color: e.iconColor ?? context.colors.textHigh,
          ),
          description: e.description,
          account: e.account,
          toAccount: e.toAccount,
          amount: e.amount,
          currencyCode: e.currency,
          recurrenceLabel: e.dateLabel,
          recurrenceChipType: e.dateChipType,
          masked: masked,
          compact: e.dateLabel != null,
          verticalPadding: _rowPadding(e),
        ),
      );
}

class _Single extends StatelessWidget {
  const _Single({required this.entry, required this.masked});

  final LatestTransactionEntry entry;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isTransfer = entry.type == SossoldiTransactionType.transfer;
    final amount = switch (entry.type) {
      SossoldiTransactionType.expense => -entry.amount,
      _ => entry.amount,
    };
    return Padding(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.s,
        children: [
          // The date chip of a recurring occurrence shares the row of the icon.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                entry.icon,
                size: 32,
                color: entry.iconColor ?? colors.textHigh,
              ),
              if (entry.dateLabel != null)
                Flexible(
                  child: SossoldiChip(
                    label: entry.dateLabel!,
                    type: entry.dateChipType,
                  ),
                ),
            ],
          ),
          // Description and account sit together, with no space between.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.bodyBoldXLarge.copyWith(
                  color: colors.textHigh,
                ),
              ),
              Text(
                isTransfer
                    ? '${entry.account} → ${entry.toAccount}'
                    : entry.account,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.labelLarge.copyWith(color: colors.textMed),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SossoldiAmount(
              value: amount,
              currencyCode: entry.currency,
              tone: isTransfer
                  ? SossoldiAmountTone.transfer
                  : SossoldiAmountTone.signed,
              style: typography.headlineSmall,
              masked: masked,
            ),
          ),
        ],
      ),
    );
  }
}
