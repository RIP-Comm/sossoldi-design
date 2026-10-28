// The form of a budget, from the Figma "Onboarding 0.2.6" (node 13:3507): a
// bottom sheet with X, title and check, the type (period), the amount and two
// switches. Built as a component of its own: the onboarding uses it inside the
// form of a category and Settings > Budgets will use it too. It touches no
// data: it returns the [BudgetDraft] and the caller saves it.
// Differences from Figma: "Count for overall budget" starts on, not off, and
// the title is "New budget" in sentence case.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/budget.dart';
import '../../mock/models/category_edit.dart';
import '../accounts/account_form_controller.dart' show parseAmount;
import '../finance/budget/budget_texts.dart';

/// What the form of a budget returned: the budget as typed, or its deletion.
@immutable
class BudgetFormResult {
  const BudgetFormResult.saved(BudgetDraft this.draft) : deleted = false;
  const BudgetFormResult.deleted() : draft = null, deleted = true;

  final BudgetDraft? draft;
  final bool deleted;
}

/// Opens the form of a new budget, or of [editing]. [takenPeriods] are the
/// periods another budget of the category already uses: they cannot be
/// picked. [deleteConfirmation] builds the modal that confirms the delete (a
/// "Delete budget" button is shown only when [editing]); null deletes at once.
/// Returns null when the form is closed with the X.
Future<BudgetFormResult?> showBudgetFormSheet(
  BuildContext context, {
  BudgetDraft? editing,
  Set<BudgetPeriod> takenPeriods = const {},
  Future<bool> Function(BuildContext context)? deleteConfirmation,
}) {
  final locale = Localizations.localeOf(context).toString();
  final currency = AppScope.read(context).repository.mainCurrency;
  return showModalBottomSheet<BudgetFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _BudgetFormSheet(
      editing: editing,
      takenPeriods: takenPeriods,
      locale: locale,
      currency: currency,
      deleteConfirmation: deleteConfirmation,
    ),
  );
}

class _BudgetFormSheet extends StatefulWidget {
  const _BudgetFormSheet({
    required this.editing,
    required this.takenPeriods,
    required this.locale,
    required this.currency,
    required this.deleteConfirmation,
  });

  final BudgetDraft? editing;
  final Set<BudgetPeriod> takenPeriods;
  final String locale;
  final String currency;
  final Future<bool> Function(BuildContext context)? deleteConfirmation;

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _amount = TextEditingController();
  late BudgetPeriod _period;
  late bool _limitAlert;
  late bool _countForOverall;
  bool _touched = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _period = e?.period ?? _firstFreePeriod();
    _limitAlert = e?.limitAlert ?? false;
    _countForOverall = e?.countForOverall ?? true;
    if (e != null) {
      _amount.text = e.amount == e.amount.roundToDouble()
          ? e.amount.toStringAsFixed(0)
          : e.amount.toString().replaceAll('.', ',');
    }
    _amount.addListener(() => setState(() => _touched = true));
  }

  /// Monthly when it is free, else the first period that is.
  BudgetPeriod _firstFreePeriod() {
    if (!widget.takenPeriods.contains(BudgetPeriod.monthly)) {
      return BudgetPeriod.monthly;
    }
    return BudgetPeriod.values.firstWhere(
      (p) => !widget.takenPeriods.contains(p),
      orElse: () => BudgetPeriod.monthly,
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double? get _parsed => parseAmount(_amount.text, widget.locale);

  /// The amount is a number above zero.
  bool get _amountValid => (_parsed ?? 0) > 0;

  String? _errorText() {
    final l10n = context.l10n;
    if (!_touched) return null;
    if (_amount.text.trim().isEmpty) return l10n.budgetAmountRequired;
    return _amountValid ? null : l10n.budgetAmountPositive;
  }

  void _save() {
    if (!_amountValid) return;
    Navigator.of(context).pop(
      BudgetFormResult.saved(
        BudgetDraft(
          id: widget.editing?.id,
          period: _period,
          amount: _parsed!,
          limitAlert: _limitAlert,
          countForOverall: _countForOverall,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirm = widget.deleteConfirmation;
    if (confirm != null && !await confirm(context)) return;
    if (mounted) Navigator.of(context).pop(const BudgetFormResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.icon(
        title: _isEditing ? l10n.budgetFormEdit : l10n.budgetFormNew,
        onClose: () => Navigator.of(context).pop(),
        closeSemanticLabel: l10n.close,
        onConfirm: _save,
        confirmSemanticLabel: l10n.accountSave,
        confirmEnabled: _amountValid,
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _fields(context),
              ),
            ),
          ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: SossoldiSpacing.s),
              child: SossoldiButton(
                label: l10n.budgetDelete,
                type: SossoldiButtonType.ghost,
                tone: SossoldiButtonTone.danger,
                size: SossoldiButtonSize.large,
                iconRight: PhosphorIconsRegular.trash,
                onPressed: _delete,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        SossoldiSelect<BudgetPeriod>(
          label: l10n.budgetSelectType,
          value: _period,
          onChanged: (p) => setState(() => _period = p),
          items: [
            for (final p in BudgetPeriod.values)
              SossoldiSelectItem(
                value: p,
                label: budgetPeriodLabel(context, p),
                // A period another budget of the category uses is not free.
                enabled: p == _period || !widget.takenPeriods.contains(p),
              ),
          ],
        ),
        SossoldiTextInput(
          controller: _amount,
          label: l10n.budgetSetAmount,
          placeholder: l10n.budgetAmountPlaceholder,
          suffixText: SossoldiAmountFormat.currencySymbol(
            context,
            widget.currency,
          ),
          errorText: _errorText(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SossoldiSwitchRow(
          label: l10n.budgetLimitAlert,
          value: _limitAlert,
          onChanged: (v) => setState(() => _limitAlert = v),
        ),
        SossoldiSwitchRow(
          label: l10n.budgetCountForOverall,
          value: _countForOverall,
          onChanged: (v) => setState(() => _countForOverall = v),
        ),
      ],
    );
  }
}
