// Page of one transaction, opened from every row of a transaction (Finance
// list, account and category pages, Dashboard "Latest transactions"). Back and
// Edit in the bar, then a receipt (zigzag bottom) with, centered: the category
// icon (the transfer icon in blue for a transfer), the amount in Headline
// Small, the description in Body Bold XL (when there is one), the account and
// under it the date in the same style; for a transaction born from a recurrence,
// the chip of its frequency with a button to the recurrence. No Figma node yet.
//
// Edit opens the form of the transaction (a bottom sheet); for a recurring
// one it asks first: only this transaction, or the recurrence (its own page,
// which changes only the dates to come).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/transaction.dart';
import '../finance/recurring/recurring_detail_screen.dart';
import '../finance/recurring/recurring_texts.dart';
import 'transaction_edit_sheet.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  /// The route to push from any screen.
  static Route<void> route(String transactionId) => MaterialPageRoute<void>(
    builder: (_) => TransactionDetailScreen(transactionId: transactionId),
  );

  static void _openRecurrence(BuildContext context, String recurringId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecurringDetailScreen(recurringId: recurringId),
      ),
    );
  }

  /// Opens the form of this one transaction.
  Future<void> _editThis(BuildContext context, Transaction t) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await showTransactionEditSheet(context, t);
    switch (result) {
      case TransactionEditResult.saved:
        if (!context.mounted) return;
        showSossoldiSnackbar(
          context,
          messenger: messenger,
          type: SossoldiSnackbarType.success,
          title: l10n.transactionUpdated,
        );
      case TransactionEditResult.deleted:
        // The page of something that is gone closes quietly.
        navigator.pop();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = context.repository;
    final masked = context.hideAmounts;
    final Transaction t;
    try {
      t = repo.transaction(transactionId);
    } on StateError {
      return Scaffold(backgroundColor: colors.surfaceMed);
    }
    final isTransfer = t.type == TransactionType.transfer;
    final category = t.categoryId == null ? null : repo.category(t.categoryId!);
    final iconColor = category?.color.main ?? colors.primary.text;
    final iconBackground =
        category?.color.tintFor(Theme.of(context).brightness) ??
        colors.primary.surface.withValues(alpha: 0.12);
    final locale = Localizations.localeOf(context).toString();
    final account = isTransfer
        ? '${repo.account(t.accountId).name} → '
              '${repo.account(t.toAccountId!).name}'
        : repo.account(t.accountId).name;
    final amount = t.type == TransactionType.expense ? -t.amount : t.amount;
    final recurrence = repo.recurringOrNull(t.recurringId);
    final accountStyle = typography.bodyLarge.copyWith(color: colors.textHigh);
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: Column(
          children: [
            SossoldiBottomSheetToolbar.text(
              title: '',
              closeLabel: l10n.back,
              closeIcon: PhosphorIconsRegular.caretLeft,
              onClose: () => Navigator.of(context).pop(),
              confirmLabel: l10n.transactionDetailEdit,
              // A recurring one: Edit is a dropdown (only this one, or the
              // recurrence); otherwise it opens the form.
              onConfirm: recurrence == null
                  ? () => _editThis(context, t)
                  : () {},
              confirmMenu: recurrence == null
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (popover) => SossoldiMenuItem(
                            label: l10n.transactionAskOnlyThis,
                            onTap: () {
                              SossoldiPopover.close(popover);
                              _editThis(context, t);
                            },
                          ),
                        ),
                        Builder(
                          builder: (popover) => SossoldiMenuItem(
                            label: l10n.transactionAskRecurrence,
                            onTap: () {
                              SossoldiPopover.close(popover);
                              _openRecurrence(context, recurrence.id);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SossoldiSpacing.l),
                // The whole width of the page, whatever the content.
                child: SizedBox(
                  width: double.infinity,
                  child: SossoldiReceipt(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: SossoldiSpacing.s,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category?.icon ??
                                PhosphorIconsRegular.arrowsLeftRight,
                            size: 32,
                            color: iconColor,
                          ),
                        ),
                        SossoldiAmount(
                          value: amount,
                          currencyCode: t.currency,
                          tone: isTransfer
                              ? SossoldiAmountTone.transfer
                              : SossoldiAmountTone.signed,
                          style: typography.headlineSmall,
                          masked: masked,
                        ),
                        if (t.description.trim().isNotEmpty)
                          Text(
                            t.description,
                            textAlign: TextAlign.center,
                            style: typography.bodyBoldXLarge.copyWith(
                              color: colors.textHigh,
                            ),
                          ),
                        Column(
                          children: [
                            Text(
                              account,
                              textAlign: TextAlign.center,
                              style: accountStyle,
                            ),
                            Text(
                              DateFormat.yMMMd(locale).format(t.date),
                              // Medium emphasis.
                              style: accountStyle.copyWith(
                                color: colors.textMed,
                              ),
                            ),
                          ],
                        ),
                        if (recurrence != null) ...[
                          SossoldiChip(
                            label: recurrenceFrequencyLabel(
                              context,
                              recurrence.frequency,
                            ),
                            type: SossoldiChipType.subtle,
                          ),
                          SossoldiButton(
                            label: l10n.transactionShowRecurrence,
                            type: SossoldiButtonType.ghost,
                            iconRight: PhosphorIconsRegular.arrowRight,
                            onPressed: () =>
                                _openRecurrence(context, recurrence.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
