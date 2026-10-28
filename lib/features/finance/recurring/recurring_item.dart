import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../mock/models/transaction.dart';
import 'recurring_texts.dart';

/// One row of the Recurring lists: what a recurring transaction does on a
/// date. The date chip is blue while the date is still to come and grey once
/// it happened. Account, category and icon are read from the repository.
class RecurringItem extends StatelessWidget {
  const RecurringItem({
    super.key,
    required this.type,
    required this.description,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.planned,
    this.toAccountId,
    this.categoryId,
    this.onTap,
  });

  final TransactionType type;
  final String description;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final double amount;
  final String currency;
  final DateTime date;

  /// Not happened yet.
  final bool planned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final category = categoryId == null ? null : repo.category(categoryId!);
    return SossoldiTransactionItem(
      type: switch (type) {
        TransactionType.expense => SossoldiTransactionType.expense,
        TransactionType.income => SossoldiTransactionType.income,
        TransactionType.transfer => SossoldiTransactionType.transfer,
      },
      leading: Icon(
        category?.icon ?? PhosphorIconsRegular.arrowsLeftRight,
        size: 24,
        color: category?.color.main ?? context.colors.textHigh,
      ),
      description: description,
      account: repo.account(accountId).name,
      toAccount: toAccountId == null ? null : repo.account(toAccountId!).name,
      amount: amount,
      currencyCode: currency,
      recurrenceLabel: recurrenceDateLabel(context, date),
      recurrenceChipType: planned
          ? SossoldiChipType.info
          : SossoldiChipType.subtle,
      masked: context.hideAmounts,
      onTap: onTap,
    );
  }
}
