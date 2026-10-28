import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/date_utils.dart';
import '../../../mock/models/transaction.dart';
import '../../../mock/models/transaction_filter.dart';

/// One removable chip per active filter group. The date is always there
/// (the default is the current month); removing it means "any date".
/// A group whose callback is null is not shown: a filter that is fixed by
/// the page (e.g. the date and category of a budget) has no chip.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.filter,
    this.onRemoveDate,
    this.onRemoveTypes,
    this.onRemoveCategories,
    this.onRemoveAmount,
    this.onRemoveAccounts,
  });

  final TransactionFilter filter;
  final VoidCallback? onRemoveDate;
  final VoidCallback? onRemoveTypes;
  final VoidCallback? onRemoveCategories;
  final VoidCallback? onRemoveAmount;
  final VoidCallback? onRemoveAccounts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final f = filter;
    final locale = Localizations.localeOf(context).toString();

    Widget chip(String name, String value, VoidCallback onRemove) =>
        SossoldiFilterChip(
          name: name,
          value: value,
          onRemove: onRemove,
          removeSemanticLabel: '${l10n.removeFilter}: $name',
        );

    String names(Iterable<String> list) {
      final all = list.toList();
      return all.length <= 2
          ? all.join(', ')
          : '${all.take(2).join(', ')} +${all.length - 2}';
    }

    String money(double v) => SossoldiAmountFormat.money(
      context,
      v,
      currencyCode: repo.mainCurrency,
      decimalDigits: v == v.roundToDouble() ? 0 : 2,
    );

    final chips = <Widget>[
      if (f.hasDateRange && onRemoveDate != null)
        chip(l10n.filterDate, _dateText(f, locale), onRemoveDate!),
      if (f.types.isNotEmpty && onRemoveTypes != null)
        chip(
          l10n.filterType,
          names([
            for (final t in TransactionType.values)
              if (f.types.contains(t))
                switch (t) {
                  TransactionType.expense => l10n.typeExpense,
                  TransactionType.income => l10n.typeIncome,
                  TransactionType.transfer => l10n.typeTransfer,
                },
          ]),
          onRemoveTypes!,
        ),
      if (f.categoryIds.isNotEmpty && onRemoveCategories != null)
        chip(
          l10n.filterCategory,
          names([
            for (final c in repo.categories())
              if (f.categoryIds.contains(c.id)) c.name,
          ]),
          onRemoveCategories!,
        ),
      if (f.hasAmountRange && onRemoveAmount != null)
        chip(
          l10n.filterAmount,
          f.minAmount != null && f.maxAmount != null
              ? '${money(f.minAmount!)} – ${money(f.maxAmount!)}'
              : f.minAmount != null
              ? '≥ ${money(f.minAmount!)}'
              : '≤ ${money(f.maxAmount!)}',
          onRemoveAmount!,
        ),
      if (f.accountIds.isNotEmpty && onRemoveAccounts != null)
        chip(
          l10n.filterAccount,
          names([
            for (final a in repo.accounts)
              if (f.accountIds.contains(a.id)) a.name,
          ]),
          onRemoveAccounts!,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: SossoldiSpacing.s,
      runSpacing: SossoldiSpacing.s,
      children: chips,
    );
  }

  /// "October 2026" for a whole month, otherwise "Oct 3, 2026 – Oct 20, 2026".
  static String _dateText(TransactionFilter f, String locale) {
    final from = f.from;
    final to = f.to;
    if (from != null &&
        to != null &&
        from.day == 1 &&
        from.year == to.year &&
        from.month == to.month &&
        to.day == daysInMonth(to.year, to.month)) {
      return toBeginningOfSentenceCase(
            DateFormat.yMMMM(locale).format(from),
            locale,
          ) ??
          '';
    }
    final format = DateFormat.yMMMd(locale);
    if (from != null && to != null) {
      return from == to
          ? format.format(from)
          : '${format.format(from)} – ${format.format(to)}';
    }
    return format.format((from ?? to)!);
  }
}
