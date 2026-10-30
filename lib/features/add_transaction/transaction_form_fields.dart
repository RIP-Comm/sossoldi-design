// The fields of the transaction form of the Add sheet. Not in Figma: built
// from the components of the design system, in the style of the movement
// form.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/category.dart';
import '../../mock/models/recurring_transaction.dart';
import '../../mock/models/transaction.dart';
import '../../mock/models/transaction_edit.dart';
import '../finance/recurring/recurring_texts.dart';
import '../investments/movements/movement_form_fields.dart' show fieldErrorText;
import 'category_picker_sheet.dart';
import 'date_fields.dart';
import 'transaction_form_controller.dart';

class TransactionFormFields extends StatelessWidget {
  const TransactionFormFields({super.key, required this.controller});

  final TransactionFormController controller;

  TransactionFormController get c => controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l10n = context.l10n;
        final colors = context.colors;
        final repo = c.repository;
        final role = _roleOf(colors, c.type);
        final noAccounts = repo.accounts.isEmpty;
        String? err(error) => c.shown(error) == null
            ? null
            : fieldErrorText(context, c.shown(error)!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.l,
          children: [
            SossoldiTabNavigation(
              tabs: [
                SossoldiTabData.text(
                  l10n.typeExpense,
                  activeRole: colors.expense,
                ),
                SossoldiTabData.text(
                  l10n.typeIncome,
                  activeRole: colors.income,
                ),
                SossoldiTabData.text(
                  l10n.typeTransfer,
                  activeRole: colors.info,
                ),
              ],
              selectedIndex: c.type.index,
              onChanged: (i) => c.setType(TransactionType.values[i]),
            ),
            if (c.submitted && c.failure != null)
              SossoldiAlert(
                tone: SossoldiAlertTone.error,
                message: l10n.movementErrInvalid,
              ),
            if (noAccounts)
              SossoldiAlert(
                tone: SossoldiAlertTone.warning,
                message: l10n.txNoAccounts,
              )
            else ...[
              SossoldiAmountInput(
                controller: c.amount,
                focusNode: c.amountFocus,
                autofocus: true,
                prefix: c.type == TransactionType.expense ? '−' : null,
                color: role.text,
                currencySymbol: SossoldiAmountFormat.currencySymbol(
                  context,
                  c.currency,
                ),
                semanticLabel: l10n.txAmount,
                errorText: err(c.amountError),
              ),
              _description(context),
              if (c.isTransfer)
                _transferAccounts(context, err)
              else ...[
                _categorySection(context),
                SossoldiSelect<String>(
                  label: l10n.txAccount,
                  value: c.accountId,
                  onChanged: c.setAccount,
                  items: [
                    for (final a in repo.accounts)
                      SossoldiSelectItem(value: a.id, label: a.name),
                  ],
                ),
              ],
              DateChipsField(
                label: l10n.txDate,
                date: c.date,
                today: repo.today,
                lastDate: repo.today,
                onChanged: c.setDate,
              ),
              _recurringSection(context),
            ],
          ],
        );
      },
    );
  }

  static SossoldiColorRole _roleOf(dynamic colors, TransactionType t) =>
      switch (t) {
        TransactionType.expense => colors.expense,
        TransactionType.income => colors.income,
        TransactionType.transfer => colors.info,
      };

  Widget _transferAccounts(
    BuildContext context,
    String? Function(dynamic) err,
  ) {
    final l10n = context.l10n;
    final repo = c.repository;
    if (!c.transferPossible) {
      return SossoldiAlert(
        tone: SossoldiAlertTone.info,
        message: l10n.txTransferNeedsTwo,
      );
    }
    List<SossoldiSelectItem<String>> items(String? except) => [
      for (final a in repo.accounts)
        SossoldiSelectItem(value: a.id, label: a.name, enabled: a.id != except),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        SossoldiSelect<String>(
          label: l10n.txFrom,
          value: c.accountId,
          onChanged: c.setAccount,
          items: items(c.toAccountId),
        ),
        Center(
          child: SossoldiIconButton(
            icon: PhosphorIconsRegular.arrowsDownUp,
            type: SossoldiIconButtonType.outline,
            variant: SossoldiIconButtonVariant.neutral,
            semanticLabel: l10n.txSwapAccounts,
            onPressed: c.swapAccounts,
          ),
        ),
        SossoldiSelect<String>(
          label: l10n.txTo,
          value: c.toAccountId,
          onChanged: c.setToAccount,
          items: items(c.accountId),
        ),
        if (c.crossCurrency)
          SossoldiTextInput(
            controller: c.toAmount,
            label: l10n.txAmountReceived,
            suffixText: SossoldiAmountFormat.currencySymbol(
              context,
              c.toCurrency!,
            ),
            errorText: err(c.toAmountError),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
      ],
    );
  }

  Widget _categorySection(BuildContext context) {
    final l10n = context.l10n;
    final repo = c.repository;
    final all = repo.categoriesByUsage(c.categoryType);
    if (all.isEmpty) {
      return SossoldiAlert(
        tone: SossoldiAlertTone.warning,
        message: c.categoryType == CategoryType.expense
            ? l10n.txNoExpenseCategories
            : l10n.txNoIncomeCategories,
      );
    }
    final chips = c.categoryChips;
    final subs = c.subcategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiFieldFrame(
          label: l10n.txCategory,
          helperText: c.submitted && c.categoryMissing
              ? l10n.txErrCategory
              : null,
          isError: c.submitted && c.categoryMissing,
          // One row that scrolls sideways, past the padding of the sheet.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              spacing: SossoldiSpacing.s,
              children: [
                for (final cat in chips)
                  SossoldiUnitNavigator(
                    label: cat.name,
                    icon: cat.icon,
                    iconColor: cat.color.main,
                    selected: cat.id == c.categoryId,
                    onTap: () => c.setCategory(cat.id),
                  ),
                if (all.length > chips.length || c.categoryId == null)
                  SossoldiUnitNavigator(
                    label: l10n.txMore,
                    icon: PhosphorIconsRegular.dotsThree,
                    selected: false,
                    onTap: () async {
                      final pick = await showCategoryPickerSheet(
                        context,
                        type: c.categoryType,
                      );
                      if (pick != null) {
                        c.setCategory(
                          pick.categoryId,
                          subcategoryId: pick.subcategoryId,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
        if (subs.isNotEmpty)
          SossoldiFieldFrame(
            label: l10n.txSubcategory,
            child: Wrap(
              spacing: SossoldiSpacing.s,
              runSpacing: SossoldiSpacing.s,
              children: [
                for (final s in subs)
                  SossoldiUnitNavigator(
                    label: s.name,
                    selected: s.id == c.subcategoryId,
                    onTap: () => c.setSubcategory(s.id),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _description(BuildContext context) {
    final l10n = context.l10n;
    final suggestions = c.descriptionSuggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiTextInput(
          controller: c.description,
          label: l10n.txDescription,
          textInputAction: TextInputAction.done,
        ),
        if (suggestions.isNotEmpty)
          SossoldiList(
            children: [
              for (final text in suggestions)
                SossoldiMenuItem(
                  label: text,
                  leading: Icon(
                    PhosphorIconsRegular.clockCounterClockwise,
                    size: 24,
                    color: context.colors.textMed,
                  ),
                  onTap: () => c.useDescription(text),
                ),
            ],
          ),
      ],
    );
  }

  Widget _recurringSection(BuildContext context) {
    final l10n = context.l10n;
    final repo = c.repository;
    final farFuture = DateTime(
      repo.today.year + 10,
      repo.today.month,
      repo.today.day,
    );
    String? error;
    if (c.submitted && c.endBeforeStart) error = l10n.txErrEndBeforeStart;
    if (c.submitted && c.endDateMissing) error = l10n.txErrChooseDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiSwitchRow(
          label: l10n.txRecurring,
          value: c.recurring,
          onChanged: c.setRecurring,
        ),
        if (c.recurring) ...[
          SossoldiSelect<RecurrenceFrequency>(
            label: l10n.txFrequency,
            value: c.frequency,
            onChanged: c.setFrequency,
            items: [
              for (final f in RecurrenceFrequency.values)
                SossoldiSelectItem(
                  value: f,
                  label: recurrenceFrequencyLabel(context, f),
                ),
            ],
          ),
          DateChipsField(
            label: l10n.txStartDate,
            date: c.startDate,
            today: repo.today,
            lastDate: farFuture,
            onChanged: c.setStartDate,
          ),
          SossoldiFieldFrame(
            label: l10n.txEnd,
            child: SossoldiTabNavigation(
              tabs: [
                SossoldiTabData.text(l10n.txEndNever),
                SossoldiTabData.text(l10n.txEndOnDate),
                SossoldiTabData.text(l10n.txEndAfter),
              ],
              selectedIndex: c.end.index,
              onChanged: (i) => c.setEnd(RecurrenceEnd.values[i]),
            ),
          ),
          if (c.end == RecurrenceEnd.onDate)
            DateButtonField(
              label: l10n.txEndDate,
              placeholder: l10n.txChooseDate,
              date: c.endDate,
              errorText: error,
              onTap: () async {
                final picked = await pickDate(
                  context,
                  title: l10n.txEndDate,
                  lastDate: farFuture,
                  firstDate: c.startDate,
                  selected: c.endDate,
                );
                if (picked != null) c.setEndDate(picked);
              },
            ),
          if (c.end == RecurrenceEnd.afterCount)
            SossoldiTextInput(
              controller: c.count,
              label: l10n.txEndCount,
              errorText: c.shown(c.countError) == null
                  ? null
                  : fieldErrorText(context, c.shown(c.countError)!),
              keyboardType: TextInputType.number,
            ),
        ],
      ],
    );
  }
}
