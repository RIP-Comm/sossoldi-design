// Latest transactions widget (also drawn by Upcoming recurring, with a date
// chip per entry), sizes S, M and L, from Figma "Latest
// transactions - Widget content" (nodes 13:3987, 13:3999, 13:4005).
// Presentation only: LatestTransactionsWidget wires it to the repository.
//
// S shows the most recent transaction large; M and L show a list, as many
// rows as fit (3 in M).

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../model/dashboard_layout.dart';
import 'latest_transaction_entry.dart';

class LatestTransactionsCard extends StatelessWidget {
  const LatestTransactionsCard({
    super.key,
    required this.size,
    required this.entries,
    required this.masked,
    this.emptyText,
  });

  final DashboardWidgetSize size;

  /// Newest first.
  final List<LatestTransactionEntry> entries;
  final bool masked;

  /// Shown with no entries; default: no transactions yet.
  final String? emptyText;

  /// Height of one list row (8 + 20 + 16 + 8) and the gap between rows.
  static const double _rowHeight = 52;
  static const double _rowGap = 6;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SossoldiWidgetCard(
        child: Center(
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
        ),
      );
    }
    return SossoldiWidgetCard(
      child: switch (size) {
        DashboardWidgetSize.s => _Single(entry: entries.first, masked: masked),
        _ => LayoutBuilder(
          builder: (context, constraints) {
            final fit =
                ((constraints.maxHeight + _rowGap) / (_rowHeight + _rowGap))
                    .floor();
            final count = fit.clamp(1, entries.length);
            return Column(
              spacing: _rowGap,
              children: [
                for (final entry in entries.take(count))
                  _row(entry, masked: masked),
              ],
            );
          },
        ),
      },
    );
  }

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
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
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
