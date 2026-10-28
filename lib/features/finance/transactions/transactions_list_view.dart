// Finance > Transactions > List, from Figma "2.1.0 - Finance - Transactions"
// (node 13:4556): search and filters, the transactions grouped by day, and
// the pagination. All the data comes from the controller, which gets it
// from MockRepository.searchTransactions; nothing is filtered here.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../finance_controller.dart';
import 'active_filter_chips.dart';
import 'transaction_filters_sheet.dart';
import 'transaction_day_list.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({
    super.key,
    required this.controller,
    required this.onPageSelected,
  });

  final FinanceController controller;

  /// The page the user picked; the screen scrolls back to the top.
  final ValueChanged<int> onPageSelected;

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
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
    final controller = widget.controller;
    final chosen = await showTransactionFiltersSheet(
      context,
      repository: context.repository,
      filter: controller.filter,
      defaults: controller.defaultFilter,
    );
    if (chosen != null) controller.applyFilter(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = widget.controller;
    final result = controller.result;

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
                    onChanged: controller.setQuery,
                  ),
                ),
                SossoldiFilterButton(
                  semanticLabel: l10n.filters,
                  active: controller.activeFilterCount > 0,
                  onPressed: _openFilters,
                ),
              ],
            ),
            ActiveFilterChips(
              filter: controller.filter,
              onRemoveDate: controller.removeDate,
              onRemoveTypes: controller.removeTypes,
              onRemoveCategories: controller.removeCategories,
              onRemoveAmount: controller.removeAmount,
              onRemoveAccounts: controller.removeAccounts,
            ),
          ],
        ),
        if (result.items.isEmpty)
          SossoldiEmptyState(
            icon: PhosphorIconsRegular.magnifyingGlass,
            title: l10n.emptyTransactionsTitle,
            message: controller.isRefined
                ? l10n.emptyTransactionsFiltered
                : l10n.emptyTransactionsPlain,
            actionLabel: controller.isRefined ? l10n.clearFilters : null,
            onAction: controller.isRefined ? controller.clearAll : null,
          )
        else ...[
          TransactionDayList(result: result),
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
