// The form of a category, from the Figma "Onboarding 0.2.1" (node 13:3414,
// empty), "0.2.4" (13:3479, with a subcategory) and "0.2.5" (13:3521, with a
// budget): a bottom sheet with X, title and check, the main info, the icon
// and color (as in the form of an account), the budgets (expense only) and
// the subcategories. Budgets and subcategories added here stay in a draft,
// saved only with the check. Added, not in Figma: the red "Delete category"
// of the edit and the confirmation of a change of type that discards budgets.
// Differences from Figma: a budget row shows period and amount ("Monthly ·
// 130 €"), not the share spent, because in onboarding nothing is spent yet.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/budget.dart';
import '../../mock/models/category.dart';
import '../../mock/models/category_edit.dart';
import '../accounts/icon_group_labels.dart';
import '../budgets/budget_form_sheet.dart';
import '../finance/budget/budget_texts.dart';
import 'category_form_controller.dart';
import 'category_texts.dart';
import 'subcategory_form_sheet.dart';

/// Opens the form of a new category (of [initialType]), or of [editing].
/// Returns whether a
/// category was saved or deleted.
Future<bool> showCategoryFormSheet(
  BuildContext context, {
  Category? editing,
  CategoryType initialType = CategoryType.expense,
}) async {
  final repository = AppScope.read(context).repository;
  // Made once, here: the builder runs again when the keyboard comes and goes,
  // and a new controller would lose the draft.
  final controller = CategoryFormController(
    repository,
    editing: editing,
    initialType: initialType,
  );
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _CategoryFormSheet(controller: controller),
  );
  return saved ?? false;
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.controller});

  final CategoryFormController controller;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  CategoryFormController get c => widget.controller;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _save() {
    if (c.submit()) Navigator.of(context).pop(true);
  }

  Future<void> _pickIcon() async {
    final l10n = context.l10n;
    final icon = await showSossoldiIconPicker(
      context: context,
      title: l10n.accountChooseIcon,
      closeSemanticLabel: l10n.close,
      selected: c.icon,
      color: c.color,
      groupLabel: (id) => iconGroupLabel(l10n, id),
    );
    if (icon != null) c.setIcon(icon);
  }

  /// A modal with a title, a message, "Cancel" and a red confirm button.
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            title,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            message,
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
                  label: confirmLabel,
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
    return confirmed == true && mounted;
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final ok = await _confirm(
      title: l10n.categoryDeleteTitle,
      message: l10n.categoryDeleteMessage(c.editing!.name),
      confirmLabel: l10n.categoryDeleteConfirm,
    );
    if (ok && c.delete() && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _changeType(CategoryType type) async {
    final l10n = context.l10n;
    if (type == CategoryType.income && c.budgets.isNotEmpty) {
      final ok = await _confirm(
        title: l10n.categoryTypeChangeTitle,
        message: l10n.categoryTypeChangeMessage,
        confirmLabel: l10n.categoryTypeChangeConfirm,
      );
      if (!ok) return;
    }
    c.setType(type);
  }

  Future<void> _addBudget() async {
    final result = await showBudgetFormSheet(
      context,
      takenPeriods: c.takenPeriods(),
    );
    final draft = result?.draft;
    if (draft != null) c.addBudget(draft);
  }

  Future<void> _editBudget(int index) async {
    final l10n = context.l10n;
    final budget = c.budgets[index];
    final result = await showBudgetFormSheet(
      context,
      editing: budget,
      takenPeriods: c.takenPeriods(index: index),
      deleteConfirmation: (_) => _confirm(
        title: l10n.budgetDeleteTitle,
        message: l10n.budgetDeleteMessage(
          budgetPeriodLabel(context, budget.period),
          c.name.text.trim().isEmpty ? l10n.categoryNew : c.name.text.trim(),
        ),
        confirmLabel: l10n.budgetDeleteConfirm,
      ),
    );
    if (result == null) return;
    if (result.deleted) {
      c.removeBudget(index);
    } else if (result.draft != null) {
      c.updateBudget(index, result.draft!);
    }
  }

  Future<void> _addSubcategory() async {
    final result = await showSubcategoryFormSheet(
      context,
      nameTaken: c.subcategoryNameTaken,
    );
    final name = result?.name;
    if (name != null) c.addSubcategory(name);
  }

  Future<void> _editSubcategory(int index) async {
    final result = await showSubcategoryFormSheet(
      context,
      editing: c.subcategories[index].name,
      nameTaken: (n) => c.subcategoryNameTaken(n, index: index),
    );
    if (result == null) return;
    if (result.deleted) {
      c.removeSubcategory(index);
    } else if (result.name != null) {
      c.renameSubcategory(index, result.name!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: ListenableBuilder(
        listenable: c,
        builder: (context, _) => SossoldiBottomSheetToolbar.icon(
          title: c.isEditing ? l10n.categoryEdit : l10n.categoryNew,
          onClose: () => Navigator.of(context).pop(false),
          closeSemanticLabel: l10n.close,
          onConfirm: _save,
          confirmSemanticLabel: l10n.accountSave,
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

  String? _nameError() {
    final l10n = context.l10n;
    return switch (c.nameError) {
      null => null,
      CategoryFieldError.nameRequired => l10n.categoryErrName,
      CategoryFieldError.nameTaken => l10n.categoryErrNameTaken,
    };
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          title,
          style: context.typography.labelBoldLarge.copyWith(
            color: context.colors.textHigh,
          ),
        ),
        child,
      ],
    );
  }

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xl,
      children: [
        if (c.failure == CategoryFailure.inUse)
          SossoldiAlert(
            tone: SossoldiAlertTone.error,
            message: l10n.categoryErrInUse,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            Text(
              l10n.accountMainInfo,
              style: typography.labelBoldLarge.copyWith(color: colors.textHigh),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.s,
              children: [
                // The type cannot change once the category exists.
                if (!c.isEditing)
                  SossoldiSelect<CategoryType>(
                    label: l10n.categoryType,
                    value: c.type,
                    onChanged: _changeType,
                    items: [
                      SossoldiSelectItem(
                        value: CategoryType.expense,
                        label: l10n.categoryTypeExpense,
                      ),
                      SossoldiSelectItem(
                        value: CategoryType.income,
                        label: l10n.categoryTypeIncome,
                      ),
                    ],
                  ),
                SossoldiTextInput(
                  controller: c.name,
                  label: l10n.accountName,
                  placeholder: l10n.categoryNamePlaceholder,
                  errorText: _nameError(),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ],
        ),
        _iconAndColor(context),
        if (c.type == CategoryType.expense)
          _section(context, l10n.categoryBudget, _budgetList(context)),
        _section(
          context,
          l10n.categorySubcategories,
          _subcategoryList(context),
        ),
        if (c.isEditing)
          Center(
            child: SossoldiButton(
              label: l10n.categoryDelete,
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

  Widget _budgetList(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final currency = c.repository.mainCurrency;
    final budgets = c.budgets;
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.s),
      child: ColoredBox(
        color: colors.surfaceHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, b) in budgets.indexed)
              SossoldiTappable(
                onTap: () => _editBudget(i),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SossoldiSpacing.m,
                    vertical: SossoldiSpacing.s,
                  ),
                  child: Row(
                    spacing: SossoldiSpacing.s,
                    children: [
                      Expanded(
                        child: Text(
                          budgetPeriodLabel(context, b.period),
                          style: typography.labelLarge.copyWith(
                            color: colors.textHigh,
                          ),
                        ),
                      ),
                      Text(
                        budgetAmountText(context, b.amount, currency),
                        style: typography.labelLarge.copyWith(
                          color: colors.textMed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SossoldiListAddButton(
              label: l10n.categoryAddBudget,
              // Every period taken: nothing left to add.
              onPressed: c.takenPeriods().length < BudgetPeriod.values.length
                  ? _addBudget
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _subcategoryList(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final subs = c.subcategories;
    if (subs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(SossoldiSpacing.l),
        decoration: ShapeDecoration(
          color: colors.surfaceLow,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(SossoldiRadius.m),
          ),
        ),
        child: Column(
          spacing: SossoldiSpacing.s,
          children: [
            Text(
              l10n.categorySubcategoriesHint,
              textAlign: TextAlign.center,
              style: context.typography.bodyMedium.copyWith(
                color: colors.textMed,
              ),
            ),
            SossoldiButton(
              label: l10n.categoryAddSubcategory,
              type: SossoldiButtonType.ghost,
              size: SossoldiButtonSize.large,
              onPressed: _addSubcategory,
            ),
          ],
        ),
      );
    }
    return SossoldiList(
      children: [
        for (final (i, s) in subs.indexed)
          SossoldiCategoryItem(
            name: s.name,
            leading: Icon(c.icon, size: 24, color: c.color.main),
            onTap: () => _editSubcategory(i),
          ),
        SossoldiListAddButton(
          label: l10n.categoryAddSubcategory,
          onPressed: _addSubcategory,
        ),
      ],
    );
  }

  Widget _iconAndColor(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        Text(
          l10n.accountIconAndColor,
          style: typography.labelBoldLarge.copyWith(color: colors.textHigh),
        ),
        Column(
          spacing: SossoldiSpacing.xl,
          children: [
            SossoldiTappable(
              onTap: _pickIcon,
              semanticLabel: l10n.accountChooseIcon,
              child: Column(
                spacing: SossoldiSpacing.s,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.color.tintFor(brightness),
                      border: Border.all(color: colors.strokeDefault),
                    ),
                    child: Icon(c.icon, size: 32, color: c.color.main),
                  ),
                  Text(
                    l10n.accountTapToSelect,
                    style: typography.labelSmall.copyWith(
                      color: colors.textMed,
                    ),
                  ),
                ],
              ),
            ),
            SossoldiColorPicker(
              color: c.color.main,
              hueSemanticLabel: l10n.accountColorHue,
              saturationSemanticLabel: l10n.accountColorSaturation,
              onChanged: (color) => c.setColor(CategoryColor.fromColor(color)),
            ),
          ],
        ),
      ],
    );
  }
}
