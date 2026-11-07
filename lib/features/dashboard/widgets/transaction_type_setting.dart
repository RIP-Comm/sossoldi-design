import 'package:flutter/widgets.dart';

import '../../../l10n/l10n.dart';
import '../../../mock/models/transaction.dart';
import 'dashboard_type_selector.dart';

/// The transaction type chosen in the header of Latest transactions and
/// Upcoming recurring, kept in the settings of the placement.
abstract final class TransactionTypeSetting {
  static const key = 'type';

  /// Null: all the types.
  static TransactionType? of(Map<String, String> settings) {
    for (final t in TransactionType.values) {
      if (t.name == settings[key]) return t;
    }
    return null;
  }

  static String label(BuildContext context, TransactionType? type) {
    final l10n = context.l10n;
    return switch (type) {
      null => l10n.transactionTypeAll,
      TransactionType.expense => l10n.kindExpenses,
      TransactionType.income => l10n.kindIncome,
      TransactionType.transfer => l10n.kindTransfers,
    };
  }

  /// Lowercase singular, for "No expense transactions".
  static String noun(BuildContext context, TransactionType type) {
    final l10n = context.l10n;
    return switch (type) {
      TransactionType.expense => l10n.typeExpense,
      TransactionType.income => l10n.typeIncome,
      TransactionType.transfer => l10n.typeTransfer,
    }.toLowerCase();
  }

  /// The chip of the header.
  static Widget selector(
    BuildContext context, {
    required TransactionType? selected,
    required bool enabled,
    required void Function(String key, String? value)? onChanged,
  }) => DashboardTypeSelector(
    label: label(context, selected),
    options: [
      (key: null, label: label(context, null)),
      for (final t in TransactionType.values)
        (key: t.name, label: label(context, t)),
    ],
    selected: selected?.name,
    semanticLabel: context.l10n.dashboardTransactionTypeSemantic,
    enabled: enabled && onChanged != null,
    onSelected: (value) => onChanged?.call(key, value),
  );
}
