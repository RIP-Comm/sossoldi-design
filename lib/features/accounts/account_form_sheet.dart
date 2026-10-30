// The form of an account, from the Figma "Onboarding 0.1.1" (node 13:3386)
// and 0.1.1 filled (13:3400): a bottom sheet with X, title and check, the
// main info and the icon and color. The icon picker and the red "Delete
// account" of the edit are not in Figma (added). The currency is one for the
// whole app, so there is no currency field (see the comment where it was).

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/account.dart';
import '../../mock/models/account_edit.dart';
import 'account_form_controller.dart';
import 'icon_group_labels.dart';

/// Opens the form of a new account, or of [editing]. Returns whether an
/// account was saved or deleted.
Future<bool> showAccountFormSheet(
  BuildContext context, {
  Account? editing,
}) async {
  final repository = AppScope.read(context).repository;
  final locale = Localizations.localeOf(context).toString();
  // Made once, here: the builder runs again when the keyboard comes and goes,
  // and a new controller would lose what was typed.
  final controller = AccountFormController(
    repository,
    locale: locale,
    editing: editing,
  );
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _AccountFormSheet(controller: controller),
  );
  return saved ?? false;
}

class _AccountFormSheet extends StatefulWidget {
  const _AccountFormSheet({required this.controller});

  final AccountFormController controller;

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  AccountFormController get c => widget.controller;

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
            l10n.accountDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.accountDeleteMessage(c.editing!.name),
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
                  label: l10n.accountDeleteConfirm,
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
    if (c.delete()) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: ListenableBuilder(
        listenable: c,
        builder: (context, _) => SossoldiBottomSheetToolbar.icon(
          title: c.isEditing ? l10n.accountEdit : l10n.accountNew,
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

  String? _errorText(AccountFieldError? error) {
    final l10n = context.l10n;
    return switch (error) {
      null => null,
      AccountFieldError.nameRequired => l10n.accountErrName,
      AccountFieldError.nameTaken => l10n.accountErrNameTaken,
      AccountFieldError.amountRequired => l10n.accountErrAmount,
      AccountFieldError.amountInvalid => l10n.accountErrAmountInvalid,
    };
  }

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xl,
      children: [
        if (c.failure == AccountFailure.inUse)
          SossoldiAlert(
            tone: SossoldiAlertTone.error,
            message: l10n.accountErrInUse,
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
                SossoldiTextInput(
                  controller: c.name,
                  label: l10n.accountName,
                  placeholder: l10n.accountNamePlaceholder,
                  errorText: _errorText(c.nameError),
                  textInputAction: TextInputAction.next,
                ),
                SossoldiTextInput(
                  controller: c.amount,
                  label: l10n.accountAmount,
                  suffixText: SossoldiAmountFormat.currencySymbol(
                    context,
                    c.currency,
                  ),
                  errorText: _errorText(c.amountError),
                  // Numbers only (no minus on the iOS decimal pad).
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                // One currency for the whole app (the main one), so the account
                // has no currency of its own for now. Kept here for when accounts
                // in several currencies come back.
                // SossoldiSelect<String>(
                //   label: l10n.currency,
                //   value: c.currency,
                //   onChanged: c.setCurrency,
                //   items: [
                //     for (final code in repo.supportedCurrencies)
                //       SossoldiSelectItem(
                //         value: code,
                //         label: currencyLabel(context, code),
                //       ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
        SossoldiSwitchRow(
          label: l10n.accountMain,
          description: c.mainLocked ? l10n.accountMainHint : null,
          value: c.isMain,
          onChanged: c.mainLocked ? null : c.setMain,
        ),
        _iconAndColor(context),
        if (c.isEditing)
          SossoldiButton(
            label: l10n.accountDelete,
            tone: SossoldiButtonTone.danger,
            size: SossoldiButtonSize.large,
            expanded: true,
            onPressed: _confirmDelete,
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
