import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../mock/models/transaction.dart';
import '../recurring/recurring_texts.dart';

/// One transaction of the list, read from the repository. Amounts are in
/// the transaction's own currency; one born from a recurrence has a chip
/// with its frequency (Monthly, Weekly, ...) under the amount; a tap does nothing for now (the detail
/// comes with Add transaction).
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    this.forAccountId,
  });

  final Transaction transaction;

  /// The list of one account: a transfer shows what moved that account, so
  /// an incoming one between currencies shows what arrived, in the
  /// destination's currency.
  final String? forAccountId;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final t = transaction;
    final incoming =
        t.type == TransactionType.transfer &&
        t.toAccountId != null &&
        t.toAccountId == forAccountId &&
        t.accountId != forAccountId;
    final recurrence = repo.recurringOrNull(t.recurringId);
    final category = t.categoryId == null ? null : repo.category(t.categoryId!);
    return SossoldiTransactionItem(
      type: switch (t.type) {
        TransactionType.expense => SossoldiTransactionType.expense,
        TransactionType.income => SossoldiTransactionType.income,
        TransactionType.transfer => SossoldiTransactionType.transfer,
      },
      leading: Icon(
        category?.icon ?? PhosphorIconsRegular.arrowsLeftRight,
        size: 24,
        color: category?.color.main ?? context.colors.textHigh,
      ),
      description: t.description,
      account: repo.account(t.accountId).name,
      toAccount: t.toAccountId == null
          ? null
          : repo.account(t.toAccountId!).name,
      amount: incoming ? (t.toAmount ?? t.amount) : t.amount,
      currencyCode: incoming
          ? repo.account(t.toAccountId!).currency
          : t.currency,
      // A transaction born from a recurrence: its frequency under the amount.
      recurrenceLabel: recurrence == null
          ? null
          : recurrenceFrequencyLabel(context, recurrence.frequency),
      recurrenceChipType: SossoldiChipType.subtle,
      masked: context.hideAmounts,
    );
  }
}
