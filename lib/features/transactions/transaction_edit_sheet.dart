// The form that edits one transaction already made: a bottom sheet like the
// ones of accounts and categories (X, title, check), with the amount,
// description, category and subcategory (selects), account(s) and date, and
// a red "Delete transaction" at the end. Not in Figma. The type cannot change.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/category.dart';
import '../../mock/models/transaction.dart';
import '../add_transaction/date_fields.dart';
import 'transaction_edit_controller.dart';

/// How the sheet closed: saved, deleted, or nothing.
enum TransactionEditResult { saved, deleted }

Future<TransactionEditResult?> showTransactionEditSheet(
  BuildContext context,
  Transaction transaction,
) {
  final repository = AppScope.read(context).repository;
  final locale = Localizations.localeOf(context).toString();
  // Made once, here: the builder runs again with the keyboard.
  final controller = TransactionEditController(
    repository,
    locale: locale,
    transaction: transaction,
  );
  return showModalBottomSheet<TransactionEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _TransactionEditSheet(controller: controller),
  );
}

class _TransactionEditSheet extends StatefulWidget {
  const _TransactionEditSheet({required this.controller});

  final TransactionEditController controller;

  @override
  State<_TransactionEditSheet> createState() => _TransactionEditSheetState();
}

class _TransactionEditSheetState extends State<_TransactionEditSheet> {
  TransactionEditController get c => widget.controller;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _save() {
    if (c.submit()) Navigator.of(context).pop(TransactionEditResult.saved);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            l10n.transactionDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.transactionDeleteMessage,
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
                  label: l10n.transactionDeleteConfirm,
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
    if (c.delete()) Navigator.of(context).pop(TransactionEditResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: ListenableBuilder(
        listenable: c,
        builder: (context, _) => SossoldiBottomSheetToolbar.icon(
          title: l10n.transactionEdit,
          onClose: () => Navigator.of(context).pop(),
          closeSemanticLabel: l10n.close,
          onConfirm: _save,
          confirmSemanticLabel: l10n.transactionSave,
          confirmEnabled: c.isValid,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ListenableBuilder(
            listenable: c,
            builder: (context, _) => _fields(context),
          ),
        ),
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    final repo = c.repository;
    final accounts = repo.accounts;
    final categoryType = c.transaction.type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final subs = c.subcategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        if (c.submitted && c.failure != null)
          SossoldiAlert(
            tone: SossoldiAlertTone.error,
            message: l10n.movementErrInvalid,
          ),
        SossoldiTextInput(
          controller: c.amount,
          label: l10n.txAmount,
          suffixText: SossoldiAmountFormat.currencySymbol(context, c.currency),
          errorText: c.submitted && c.amountMissing
              ? l10n.budgetAmountPositive
              : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
        ),
        SossoldiTextInput(
          controller: c.description,
          label: l10n.txDescription,
          textInputAction: TextInputAction.done,
        ),
        if (c.isTransfer) ...[
          SossoldiSelect<String>(
            label: l10n.txFrom,
            value: c.accountId,
            onChanged: c.setAccount,
            items: [
              for (final a in accounts)
                SossoldiSelectItem(
                  value: a.id,
                  label: a.name,
                  enabled: a.id != c.toAccountId,
                ),
            ],
          ),
          SossoldiSelect<String>(
            label: l10n.txTo,
            value: c.toAccountId,
            onChanged: c.setToAccount,
            items: [
              for (final a in accounts)
                SossoldiSelectItem(
                  value: a.id,
                  label: a.name,
                  enabled: a.id != c.accountId,
                ),
            ],
          ),
        ] else ...[
          SossoldiSelect<String>(
            label: l10n.txCategory,
            value: c.categoryId,
            onChanged: c.setCategory,
            helperText: c.submitted && c.categoryId == null
                ? l10n.txErrCategory
                : null,
            items: [
              for (final cat in repo.categories(type: categoryType))
                SossoldiSelectItem(value: cat.id, label: cat.name),
            ],
          ),
          if (subs.isNotEmpty)
            SossoldiSelect<String>(
              label: l10n.txSubcategory,
              // '' stands for no subcategory.
              value: c.subcategoryId ?? '',
              onChanged: (id) => c.setSubcategory(id.isEmpty ? null : id),
              items: [
                SossoldiSelectItem(
                  value: '',
                  label: l10n.transactionSubcategoryNone,
                ),
                for (final s in subs)
                  SossoldiSelectItem(value: s.id, label: s.name),
              ],
            ),
          SossoldiSelect<String>(
            label: l10n.txAccount,
            value: c.accountId,
            onChanged: c.setAccount,
            items: [
              for (final a in accounts)
                SossoldiSelectItem(value: a.id, label: a.name),
            ],
          ),
        ],
        DateButtonField(
          label: l10n.txDate,
          date: c.date,
          onTap: () async {
            final picked = await pickDate(
              context,
              title: l10n.txDate,
              lastDate: repo.today,
              selected: c.date,
            );
            if (picked != null) c.setDate(picked);
          },
        ),
        const SizedBox(height: SossoldiSpacing.m),
        // Same as "Delete account" and "Delete category".
        Center(
          child: SossoldiButton(
            label: l10n.transactionDelete,
            type: SossoldiButtonType.ghost,
            tone: SossoldiButtonTone.danger,
            size: SossoldiButtonSize.large,
            iconRight: PhosphorIconsRegular.trash,
            onPressed: _confirmDelete,
          ),
        ),
      ],
    );
  }
}
