import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../mock/models/transaction.dart';
import '../model/dashboard_layout.dart';
import 'latest_transaction_entry.dart';
import 'latest_transactions_card.dart';

/// Latest transactions (transfers included), reading from the repository.
class LatestTransactionsWidget extends StatelessWidget {
  const LatestTransactionsWidget({super.key, required this.size});

  final DashboardWidgetSize size;

  /// More than any size can show; the card cuts to what fits.
  static const _count = 8;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    return LatestTransactionsCard(
      size: size,
      masked: context.hideAmounts,
      entries: [
        for (final t in repo.latestTransactions(_count))
          LatestTransactionEntry(
            type: switch (t.type) {
              TransactionType.expense => SossoldiTransactionType.expense,
              TransactionType.income => SossoldiTransactionType.income,
              TransactionType.transfer => SossoldiTransactionType.transfer,
            },
            icon: t.categoryId == null
                ? PhosphorIconsRegular.arrowsLeftRight
                : repo.category(t.categoryId!).icon,
            iconColor: t.categoryId == null
                ? null
                : repo.category(t.categoryId!).color.main,
            description: t.description,
            account: repo.account(t.accountId).name,
            toAccount: t.toAccountId == null
                ? null
                : repo.account(t.toAccountId!).name,
            amount: t.amount,
            currency: t.currency,
          ),
      ],
    );
  }
}
