import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../mock/models/transaction.dart';

/// One transaction of the list, read from the repository. Amounts are in
/// the transaction's own currency; a tap does nothing for now (the detail
/// comes with Add transaction).
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final t = transaction;
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
      amount: t.amount,
      currencyCode: t.currency,
      masked: context.hideAmounts,
    );
  }
}
