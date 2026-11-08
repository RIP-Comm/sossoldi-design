// Recurring transaction page, from Figma "2.3.1 - Finance - Recurrent
// transaction page" (node 13:4820): Back, the name and Edit; the details
// (period, amount, active) and the old transactions by year. Not from Figma:
// the fields are read-only until Edit, and edit mode has Done and "Delete
// recurrence".

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/recurring_occurrence.dart';
import '../../../mock/models/recurring_transaction.dart';
import '../../../mock/models/transaction.dart';
import '../../transactions/transaction_detail_screen.dart';
import 'recurring_detail_controller.dart';
import 'recurring_item.dart';
import 'recurring_texts.dart';

class RecurringDetailScreen extends StatefulWidget {
  const RecurringDetailScreen({super.key, required this.recurringId});

  final String recurringId;

  @override
  State<RecurringDetailScreen> createState() => _RecurringDetailScreenState();
}

class _RecurringDetailScreenState extends State<RecurringDetailScreen> {
  late final RecurringDetailController _controller = RecurringDetailController(
    AppScope.read(context).repository,
    widget.recurringId,
  );
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _startEditing() {
    final locale = Localizations.localeOf(context).toString();
    _amount.text = NumberFormat(
      '0.##',
      locale,
    ).format(_controller.recurring!.amount);
    _controller.startEditing(_amount.text);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final name = _controller.recurring!.description;
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            l10n.recurringDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.recurringDeleteMessage(name),
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
                  label: l10n.recurringDeleteConfirm,
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
    // Back to the Recurring tab, which already shows it gone.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final r = _controller.recurring;
        if (r == null) return const SizedBox.shrink();
        final editing = _controller.isEditing;
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
                  SossoldiBottomSheetToolbar.text(
                    // The name shows in edit mode only; the box carries it otherwise.
                    title: editing ? r.description : '',
                    closeLabel: editing ? l10n.cancel : l10n.back,
                    closeIcon: editing ? null : PhosphorIconsRegular.caretLeft,
                    onClose: editing
                        ? _controller.cancelEditing
                        : () => Navigator.of(context).pop(),
                    confirmLabel: editing
                        ? l10n.doneEditing
                        : l10n.recurringEdit,
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
                        padding: const EdgeInsets.all(SossoldiSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: SossoldiSpacing.l,
                          children: [
                            _DetailsSection(
                              recurring: r,
                              controller: _controller,
                              amountField: _amount,
                            ),
                            // Not in edit mode: only the fields and Delete.
                            if (!editing)
                              _HistorySection(controller: _controller),
                            if (editing)
                              Center(
                                child: SossoldiButton(
                                  label: l10n.recurringDelete,
                                  type: SossoldiButtonType.ghost,
                                  tone: SossoldiButtonTone.danger,
                                  iconRight: PhosphorIconsRegular.trash,
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

/// The top of the page: a box (no zigzag, same look as the receipt of a
/// transaction) with the category icon, the amount, the description, the account
/// and, in chips, the period and whether it is active. In edit mode the
/// amount, period and active switch become fields.
class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.recurring,
    required this.controller,
    required this.amountField,
  });

  final RecurringTransaction recurring;
  final RecurringDetailController controller;
  final TextEditingController amountField;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = context.repository;
    final editing = controller.isEditing;
    final error = controller.amountError;
    final masked = context.hideAmounts;
    final r = recurring;
    final isTransfer = r.type == TransactionType.transfer;
    final category = r.categoryId == null ? null : repo.category(r.categoryId!);
    final iconBackground =
        category?.color.tintFor(Theme.of(context).brightness) ??
        colors.primary.surface.withValues(alpha: 0.12);
    final account = isTransfer
        ? '${repo.account(r.accountId).name} → '
              '${repo.account(r.toAccountId!).name}'
        : repo.account(r.accountId).name;
    final amount = r.type == TransactionType.expense ? -r.amount : r.amount;
    // Edit mode: the fields, as before.
    if (editing) {
      return _Section(
        title: l10n.recurringSectionDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            SossoldiSelect<RecurrenceFrequency>(
              label: l10n.recurringPeriod,
              value: controller.frequency,
              onChanged: controller.setFrequency,
              items: [
                for (final f in RecurrenceFrequency.values)
                  SossoldiSelectItem(
                    value: f,
                    label: recurrenceFrequencyLabel(context, f),
                  ),
              ],
            ),
            SossoldiTextInput(
              controller: amountField,
              label: l10n.recurringAmount,
              suffixText: SossoldiAmountFormat.currencySymbol(
                context,
                recurring.currency,
              ),
              errorText: switch (error) {
                RecurringAmountError.required => l10n.budgetAmountRequired,
                RecurringAmountError.notPositive => l10n.budgetAmountPositive,
                null => null,
              },
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: controller.setAmount,
              onSubmitted: (_) => controller.save(),
            ),
            ClipRSuperellipse(
              borderRadius: BorderRadius.circular(SossoldiRadius.s),
              child: SossoldiMenuItem(
                label: l10n.recurringActive,
                trailing: SossoldiSwitch(
                  value: controller.isActive,
                  onChanged: controller.setActive,
                  semanticLabel: l10n.recurringActive,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.l),
      child: ColoredBox(
        color: colors.surfaceHigh,
        child: Padding(
          padding: const EdgeInsets.all(SossoldiSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category?.icon ?? PhosphorIconsRegular.arrowsLeftRight,
                    size: 32,
                    color: category?.color.main ?? colors.primary.text,
                  ),
                ),
              ),
              Center(
                child: SossoldiAmount(
                  value: amount,
                  currencyCode: r.currency,
                  tone: isTransfer
                      ? SossoldiAmountTone.transfer
                      : SossoldiAmountTone.signed,
                  style: typography.headlineSmall,
                  masked: masked,
                ),
              ),
              Text(
                r.description,
                textAlign: TextAlign.center,
                style: typography.bodyBoldXLarge.copyWith(
                  color: colors.textHigh,
                ),
              ),
              Text(
                account,
                textAlign: TextAlign.center,
                style: typography.bodyLarge.copyWith(color: colors.textHigh),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: SossoldiSpacing.s,
                children: [
                  SossoldiChip(
                    label: recurrenceFrequencyLabel(
                      context,
                      controller.frequency,
                    ),
                    type: SossoldiChipType.subtle,
                  ),
                  SossoldiChip(
                    label: controller.isActive
                        ? l10n.recurringActive
                        : l10n.recurringPausedLabel,
                    type: controller.isActive
                        ? SossoldiChipType.success
                        : SossoldiChipType.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final RecurringDetailController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final groups = controller.history;
    return _Section(
      title: l10n.recurringSectionOld,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.l,
        children: [
          SossoldiSelect<RecurringHistoryRange>(
            label: l10n.recurringRangeLabel,
            value: controller.range,
            onChanged: controller.selectRange,
            items: [
              for (final r in RecurringHistoryRange.values)
                SossoldiSelectItem(
                  value: r,
                  label: recurringRangeLabel(context, r),
                ),
            ],
          ),
          if (groups.isEmpty)
            Container(
              decoration: ShapeDecoration(
                color: colors.surfaceHigh,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(SossoldiRadius.m),
                ),
              ),
              child: SossoldiEmptyState(
                icon: PhosphorIconsRegular.clockCounterClockwise,
                title: l10n.recurringHistoryEmpty,
              ),
            ),
          for (final g in groups)
            _YearGroup(group: g, recurring: controller.recurring!),
        ],
      ),
    );
  }
}

class _YearGroup extends StatelessWidget {
  const _YearGroup({required this.group, required this.recurring});

  final RecurringYearGroup group;
  final RecurringTransaction recurring;

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    final masked = context.hideAmounts;
    final total = masked
        ? '••••'
        : SossoldiAmountFormat.money(
            context,
            group.total,
            currencyCode: repo.mainCurrency,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Row(
          spacing: SossoldiSpacing.s,
          children: [
            Expanded(
              child: Text(
                '${group.year}',
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.textMed,
                ),
              ),
            ),
            SossoldiChip(
              label: total,
              type: switch (recurring.type) {
                TransactionType.expense => SossoldiChipType.expense,
                TransactionType.income => SossoldiChipType.income,
                TransactionType.transfer => SossoldiChipType.subtle,
              },
            ),
          ],
        ),
        SossoldiList(
          children: [
            for (final t in group.transactions)
              RecurringItem(
                key: ValueKey(t.id),
                type: t.type,
                description: t.description,
                accountId: t.accountId,
                toAccountId: t.toAccountId,
                categoryId: t.categoryId,
                amount: t.amount,
                currency: t.currency,
                date: t.date,
                planned: false,
                onTap: () =>
                    Navigator.of(context)
                        .push(TransactionDetailScreen.route(t.id)),
              ),
          ],
        ),
      ],
    );
  }
}
