// Budget page, adapted from Figma "Category page" (node 13:4781): Back,
// the category and Edit; the budget card; and the expenses counted in it.
// Not from Figma: only this budget (no other budgets of the category, no
// "Add budget"), the edit mode with the amount, and "Delete budget".

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/budget_status.dart';
import '../transactions/active_filter_chips.dart';
import '../transactions/transaction_day_list.dart';
import '../transactions/transaction_filters_sheet.dart';
import 'budget_detail_controller.dart';
import 'budget_texts.dart';

class BudgetDetailScreen extends StatefulWidget {
  const BudgetDetailScreen({super.key, required this.budgetId});

  final String budgetId;

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  late final BudgetDetailController _controller = BudgetDetailController(
    AppScope.read(context).repository,
    widget.budgetId,
  );
  final TextEditingController _search = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    _amount.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _startEditing() {
    final locale = Localizations.localeOf(context).toString();
    final amount = _controller.status!.amount;
    _amount.text = NumberFormat('0.##', locale).format(amount);
    _controller.startEditing(_amount.text);
  }

  Future<void> _openFilters() async {
    final chosen = await showTransactionFiltersSheet(
      context,
      repository: _controller.repository,
      filter: _controller.filter,
      defaults: _controller.baseFilter,
      // The budget fixes the period, the category and "expenses only".
      showDate: false,
      showType: false,
      showCategory: false,
    );
    if (chosen != null) _controller.applyFilter(chosen);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final repo = _controller.repository;
    final b = _controller.budget!;
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            l10n.budgetDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.budgetDeleteMessage(
              budgetPeriodLabel(context, b.period).toLowerCase(),
              repo.category(b.categoryId).name,
            ),
            style: context.typography.labelLarge.copyWith(
              color: context.colors.textMed,
            ),
          ),
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: SossoldiButton(
                  label: l10n.cancel,
                  type: SossoldiButtonType.outline,
                  size: SossoldiButtonSize.large,
                  expanded: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              Expanded(
                child: SossoldiButton(
                  label: l10n.budgetDeleteConfirm,
                  tone: SossoldiButtonTone.danger,
                  size: SossoldiButtonSize.large,
                  expanded: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _controller.delete();
    // Back to the Budget tab, which already shows the budget gone.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final status = _controller.status;
        if (status == null) return const SizedBox.shrink();
        final repo = _controller.repository;
        final editing = _controller.isEditing;
        final category = repo.category(status.budget.categoryId);
        return PopScope(
          canPop: !editing,
          // Back while editing leaves edit mode instead of the page.
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _controller.cancelEditing();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceMed,
            body: SafeArea(
              child: Column(
                children: [
                  // The same bar as a sheet's: Back, title, action.
                  SossoldiBottomSheetToolbar.text(
                    title: category.name,
                    closeLabel: editing ? l10n.cancel : l10n.back,
                    closeIcon: editing ? null : PhosphorIconsRegular.caretLeft,
                    onClose: editing
                        ? _controller.cancelEditing
                        : () => Navigator.of(context).pop(),
                    confirmLabel: editing ? l10n.doneEditing : l10n.budgetEdit,
                    onConfirm: editing ? _controller.save : _startEditing,
                  ),
                  Expanded(
                    // A tap outside the field closes the keyboard and
                    // checks the amount typed so far.
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _controller.checkAmount();
                      },
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        controller: _scroll,
                        padding: const EdgeInsets.all(SossoldiSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: SossoldiSpacing.l,
                          children: [
                            _BudgetSection(
                              status: status,
                              controller: _controller,
                              amountField: _amount,
                            ),
                            _ExpensesSection(
                              controller: _controller,
                              search: _search,
                              onFilters: _openFilters,
                              onPage: (p) {
                                _controller.goToPage(p);
                                if (_scroll.hasClients) _scroll.jumpTo(0);
                              },
                            ),
                            if (editing)
                              Center(
                                child: SossoldiButton(
                                  label: l10n.budgetDelete,
                                  tone: SossoldiButtonTone.danger,
                                  size: SossoldiButtonSize.large,
                                  onPressed: _confirmDelete,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: SossoldiSpacing.s,
    children: [
      Text(
        title,
        style: context.typography.titleMedium.copyWith(
          color: context.colors.textHigh,
        ),
      ),
      child,
    ],
  );
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({
    required this.status,
    required this.controller,
    required this.amountField,
  });

  final BudgetStatus status;
  final BudgetDetailController controller;
  final TextEditingController amountField;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final category = repo.category(status.budget.categoryId);
    final brightness = Theme.of(context).brightness;
    final error = controller.amountError;
    return _Section(
      title: l10n.budgetSectionBudget,
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.circular(SossoldiRadius.m),
        child: ColoredBox(
          color: context.colors.surfaceHigh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SossoldiBudgetItem(
                title: budgetPeriodLabel(context, status.budget.period),
                percent: budgetPercent(context, status.usage),
                remaining: budgetRemainingText(
                  context,
                  remaining: status.remaining,
                  overBy: status.overBy,
                  currency: status.currency,
                  masked: context.hideAmounts,
                ),
                tone: budgetTone(status.state),
                bar: SossoldiBudgetBar(
                  value: status.usage,
                  color: category.color.main,
                  trackColor: category.color.tintFor(brightness),
                ),
              ),
              if (controller.isEditing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SossoldiSpacing.m,
                    0,
                    SossoldiSpacing.m,
                    SossoldiSpacing.m,
                  ),
                  child: SossoldiTextInput(
                    controller: amountField,
                    label: l10n.budgetAmount,
                    suffixText: SossoldiAmountFormat.currencySymbol(
                      context,
                      status.currency,
                    ),
                    errorText: switch (error) {
                      BudgetAmountError.required => l10n.budgetAmountRequired,
                      BudgetAmountError.notPositive =>
                        l10n.budgetAmountPositive,
                      null => null,
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: controller.setDraft,
                    onSubmitted: (_) => controller.save(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensesSection extends StatefulWidget {
  const _ExpensesSection({
    required this.controller,
    required this.search,
    required this.onFilters,
    required this.onPage,
  });

  final BudgetDetailController controller;
  final TextEditingController search;
  final VoidCallback onFilters;
  final ValueChanged<int> onPage;

  @override
  State<_ExpensesSection> createState() => _ExpensesSectionState();
}

class _ExpensesSectionState extends State<_ExpensesSection> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncSearchText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncSearchText);
    super.dispose();
  }

  /// "Clear filters" empties the search from the controller's side.
  void _syncSearchText() {
    if (widget.search.text != widget.controller.filter.query) {
      widget.search.text = widget.controller.filter.query;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.controller;
    final result = c.result;
    return _Section(
      title: l10n.budgetSectionExpenses,
      child: Column(
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
                      controller: widget.search,
                      placeholder: l10n.budgetSearchExpenses,
                      clearSemanticLabel: l10n.clearSearch,
                      onChanged: c.setQuery,
                    ),
                  ),
                  SossoldiFilterButton(
                    semanticLabel: l10n.filters,
                    active: c.activeFilterCount > 0,
                    onPressed: widget.onFilters,
                  ),
                ],
              ),
              ActiveFilterChips(
                filter: c.filter,
                onRemoveAmount: c.removeAmount,
                onRemoveAccounts: c.removeAccounts,
              ),
            ],
          ),
          if (result.items.isEmpty)
            SossoldiEmptyState(
              icon: PhosphorIconsRegular.magnifyingGlass,
              title: c.isRefined
                  ? l10n.emptyTransactionsTitle
                  : l10n.emptyBudgetExpensesTitle,
              message: c.isRefined ? l10n.emptyTransactionsFiltered : null,
              actionLabel: c.isRefined ? l10n.clearFilters : null,
              onAction: c.isRefined ? c.clearAll : null,
            )
          else ...[
            TransactionDayList(result: result),
            if (result.pageCount > 1)
              SossoldiPagination(
                page: result.page,
                pageCount: result.pageCount,
                onChanged: widget.onPage,
                previousSemanticLabel: l10n.paginationPrevious,
                nextSemanticLabel: l10n.paginationNext,
              ),
          ],
        ],
      ),
    );
  }
}
