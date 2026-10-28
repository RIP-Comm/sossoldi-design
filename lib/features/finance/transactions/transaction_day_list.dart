import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../mock/date_utils.dart';
import '../../../mock/models/transaction.dart';
import '../../../mock/models/transaction_page.dart';
import 'day_title.dart';
import 'transaction_row.dart';

/// The transactions of a page grouped by day, as in the Finance list: the
/// date and the day's total (income minus expenses of all the filtered
/// transactions of the day, transfers excluded) over a card with the rows.
class TransactionDayList extends StatelessWidget {
  const TransactionDayList({super.key, required this.result});

  final TransactionPage result;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final masked = context.hideAmounts;
    final days = <DateTime, List<Transaction>>{};
    for (final t in result.items) {
      days.putIfAbsent(dateOnly(t.date), () => []).add(t);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        for (final entry in days.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              SossoldiDayHeader(
                title: dayTitle(context, entry.key),
                // Days with only transfers have no total.
                total: result.netByDay[entry.key] == null
                    ? null
                    : masked
                    ? '••••'
                    : SossoldiAmountFormat.money(
                        context,
                        result.netByDay[entry.key]!,
                        currencyCode: repo.mainCurrency,
                        showPlusSign: true,
                      ),
                positive: (result.netByDay[entry.key] ?? 0) >= 0,
              ),
              SossoldiList(
                children: [
                  for (final t in entry.value)
                    TransactionRow(key: ValueKey(t.id), transaction: t),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
