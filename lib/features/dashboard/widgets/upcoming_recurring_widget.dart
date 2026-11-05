import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/transaction.dart';
import '../../finance/recurring/recurring_texts.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'latest_transaction_entry.dart';
import 'latest_transactions_card.dart';
import 'transaction_type_setting.dart';

/// The next occurrences of the active recurring transactions, from today on
/// (today included), soonest first. Same card as Latest transactions, with
/// the date of each occurrence as a chip.
class UpcomingRecurringWidget extends StatelessWidget {
  const UpcomingRecurringWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// More than any size can show; the card cuts to what fits.
  static const _count = 8;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final today = repo.today;
    final l10n = context.l10n;
    final type = TransactionTypeSetting.of(instance.settings);
    return LatestTransactionsCard(
      size: size,
      masked: context.hideAmounts,
      title: l10n.widgetUpcomingRecurringName,
      emptyText: type == null
          ? l10n.dashboardNoUpcomingRecurring
          : l10n.dashboardNoRecurringOfType(
              TransactionTypeSetting.noun(context, type),
            ),
      selector: TransactionTypeSetting.selector(
        context,
        selected: type,
        enabled: !instance.editing,
        onChanged: instance.onSettingChanged,
      ),
      entries: [
        for (final o in repo.upcomingRecurrences(
          limit: _count,
          includeToday: true,
          type: type,
        ))
          () {
            final r = repo.recurring(o.recurringId);
            final category = r.categoryId == null
                ? null
                : repo.category(r.categoryId!);
            return LatestTransactionEntry(
              type: switch (o.type) {
                TransactionType.expense => SossoldiTransactionType.expense,
                TransactionType.income => SossoldiTransactionType.income,
                TransactionType.transfer => SossoldiTransactionType.transfer,
              },
              icon: category?.icon ?? PhosphorIconsRegular.arrowsLeftRight,
              iconColor: category?.color.main,
              description: r.description,
              account: repo.account(r.accountId).name,
              toAccount: r.toAccountId == null
                  ? null
                  : repo.account(r.toAccountId!).name,
              amount: o.amount,
              currency: o.currency,
              dateLabel: recurrenceDateLabel(context, o.date),
              dateChipType: o.date.isAfter(today)
                  ? SossoldiChipType.info
                  : SossoldiChipType.subtle,
            );
          }(),
      ],
    );
  }
}
