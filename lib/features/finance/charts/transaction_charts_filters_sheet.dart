// Filters of the Charts view: accounts and categories, both multi-select.
// Same pattern as the filters of the list. Only the categories of the
// selected Expenses/Income are listed.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/mock_repository.dart';
import '../../../mock/models/category.dart';
import '../../../mock/models/transaction_time_range.dart';
import '../filter_check_row.dart';

typedef ChartFilterSelection = ({
  Set<String> accountIds,
  Set<String> categoryIds,
});

/// Returns the chosen accounts and categories (of [kind]), or null if
/// cancelled.
Future<ChartFilterSelection?> showTransactionChartsFiltersSheet(
  BuildContext context, {
  required MockRepository repository,
  required TransactionKind kind,
  required Set<String> accountIds,
  required Set<String> categoryIds,
}) {
  return showModalBottomSheet<ChartFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => TransactionChartsFiltersSheet(
      repository: repository,
      kind: kind,
      accountIds: accountIds,
      categoryIds: categoryIds,
    ),
  );
}

class TransactionChartsFiltersSheet extends StatefulWidget {
  const TransactionChartsFiltersSheet({
    super.key,
    required this.repository,
    required this.kind,
    required this.accountIds,
    required this.categoryIds,
  });

  final MockRepository repository;
  final TransactionKind kind;
  final Set<String> accountIds;
  final Set<String> categoryIds;

  @override
  State<TransactionChartsFiltersSheet> createState() =>
      _TransactionChartsFiltersSheetState();
}

class _TransactionChartsFiltersSheetState
    extends State<TransactionChartsFiltersSheet> {
  late Set<String> _accounts = {...widget.accountIds};
  late Set<String> _categories = {...widget.categoryIds};

  Set<String> _toggle(Set<String> set, String id) => {
    for (final v in set)
      if (v != id) v,
    if (!set.contains(id)) id,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = widget.repository;
    final categories = repo.categories(
      type: widget.kind == TransactionKind.expense
          ? CategoryType.expense
          : CategoryType.income,
    );
    final accounts = repo.accounts;

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          title,
          style: context.typography.labelBoldLarge.copyWith(
            color: colors.textHigh,
          ),
        ),
        child,
      ],
    );

    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.text(
        title: l10n.filters,
        closeLabel: l10n.cancel,
        onClose: () => Navigator.of(context).pop(),
        confirmLabel: l10n.filtersApply,
        onConfirm: () =>
            Navigator.of(context)
                .pop((accountIds: _accounts, categoryIds: _categories)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.xl,
          children: [
            section(
              l10n.filterAccount,
              SossoldiList(
                children: [
                  for (final a in accounts)
                    FilterCheckRow(
                      icon: Icon(a.icon, size: 24, color: a.color.main),
                      label: a.name,
                      checked: _accounts.contains(a.id),
                      onToggle: () =>
                          setState(() => _accounts = _toggle(_accounts, a.id)),
                    ),
                ],
              ),
            ),
            section(
              l10n.filterCategory,
              SossoldiList(
                children: [
                  for (final c in categories)
                    FilterCheckRow(
                      icon: Icon(c.icon, size: 24, color: c.color.main),
                      label: c.name,
                      checked: _categories.contains(c.id),
                      onToggle: () => setState(
                        () => _categories = _toggle(_categories, c.id),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              child: SossoldiButton(
                label: l10n.filtersReset,
                type: SossoldiButtonType.ghost,
                onPressed: () => setState(() {
                  _accounts = {};
                  _categories = {};
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
