// The transactions of one account: search, filters, the rows grouped by day
// and the pagination, as in Finance > Transactions > List but with the state
// of the account page. The account is fixed, so its filter has no chip and no
// section in the sheet. Nothing is filtered here: the controller reads the
// repository.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../finance/transactions/active_filter_chips.dart';
import '../finance/transactions/transaction_day_list.dart';
import '../finance/transactions/transaction_filters_sheet.dart';
import 'account_detail_controller.dart';

class AccountTransactionsSection extends StatefulWidget {
  const AccountTransactionsSection({
    super.key,
    required this.controller,
    required this.onPageSelected,
  });

  final AccountDetailController controller;

  /// The page the user picked; the screen scrolls back to the top.
  final ValueChanged<int> onPageSelected;

  @override
  State<AccountTransactionsSection> createState() =>
      _AccountTransactionsSectionState();
}

class _AccountTransactionsSectionState
    extends State<AccountTransactionsSection> {
  late final TextEditingController _search = TextEditingController(
    text: widget.controller.filter.query,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncSearchText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncSearchText);
    _search.dispose();
    super.dispose();
  }

  /// "Clear filters" empties the search from the controller's side.
  void _syncSearchText() {
    if (_search.text != widget.controller.filter.query) {
      _search.text = widget.controller.filter.query;
    }
  }

  Future<void> _openFilters() async {
    final c = widget.controller;
    final chosen = await showTransactionFiltersSheet(
      context,
      repository: context.repository,
      filter: c.filter,
      defaults: c.baseFilter,
      // The account is fixed by the page.
      showAccount: false,
    );
    if (chosen != null) c.applyFilter(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.controller;
    final result = c.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.s,
          children: [
            Row(
              spacing: SossoldiSpacing.s,
              children: [
                Expanded(
                  child: SossoldiSearchField(
                    controller: _search,
                    placeholder: l10n.searchTransactions,
                    clearSemanticLabel: l10n.clearSearch,
                    onChanged: c.setQuery,
                  ),
                ),
                SossoldiFilterButton(
                  semanticLabel: l10n.filters,
                  active: c.activeFilterCount > 0,
                  onPressed: _openFilters,
                ),
              ],
            ),
            ActiveFilterChips(
              filter: c.filter,
              onRemoveDate: c.removeDate,
              onRemoveTypes: c.removeTypes,
              onRemoveCategories: c.removeCategories,
              onRemoveAmount: c.removeAmount,
            ),
          ],
        ),
        if (result.items.isEmpty)
          SossoldiEmptyState(
            icon: PhosphorIconsRegular.magnifyingGlass,
            title: l10n.emptyTransactionsTitle,
            message: c.isRefined
                ? l10n.emptyTransactionsFiltered
                : l10n.accountNoTransactions,
            actionLabel: c.isRefined ? l10n.clearFilters : null,
            onAction: c.isRefined ? c.clearAll : null,
          )
        else ...[
          TransactionDayList(result: result, forAccountId: c.accountId),
          if (result.pageCount > 1)
            SossoldiPagination(
              page: result.page,
              pageCount: result.pageCount,
              onChanged: widget.onPageSelected,
              previousSemanticLabel: l10n.paginationPrevious,
              nextSemanticLabel: l10n.paginationNext,
            ),
        ],
      ],
    );
  }
}
