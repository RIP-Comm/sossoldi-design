// The form of an asset of the onboarding, from the Figma "Onboarding 0.3.1"
// and "0.3.2" (nodes 13:3437 and 13:3459): a bottom sheet with X, title and
// check, the type, the asset, the amount, the average purchase price and the
// "Counts for Net Worth" switch. Differences from Figma: the switch starts on;
// in edit mode the type and the asset are fixed and a red "Delete asset" (with
// a confirmation) closes the form (not in Figma, same pattern as the other
// forms). A manual asset has only a name (its kind is "other").

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/holding.dart';
import '../../mock/models/movement_edit.dart';
import '../../mock/models/portfolio.dart';
import '../investments/investments_texts.dart' show positionKindLabel;
import 'asset_form_controller.dart';

/// Opens the form of a new asset, or of [editing]. Returns whether an asset
/// was saved or deleted.
Future<bool> showAssetFormSheet(
  BuildContext context, {
  Holding? editing,
}) async {
  final repository = AppScope.read(context).repository;
  final locale = Localizations.localeOf(context).toString();
  // Made once, here: the builder runs again when the position it reads is
  // deleted, and it must not look for it then.
  final controller = AssetFormController(
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
    builder: (_) => _AssetFormSheet(controller: controller),
  );
  return saved ?? false;
}

class _AssetFormSheet extends StatefulWidget {
  const _AssetFormSheet({required this.controller});

  final AssetFormController controller;

  @override
  State<_AssetFormSheet> createState() => _AssetFormSheetState();
}

class _AssetFormSheetState extends State<_AssetFormSheet> {
  AssetFormController get c => widget.controller;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    c.dispose();
    super.dispose();
  }

  void _save() {
    if (c.submit()) Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final name = c.repository.holdingName(c.editing!.id);
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            l10n.assetDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.assetDeleteMessage(name),
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
                  label: l10n.assetDeleteConfirm,
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

  String? _errorText(AssetFieldError? e) {
    final l10n = context.l10n;
    return switch (e) {
      null => null,
      AssetFieldError.chooseAsset => l10n.assetErrChoose,
      AssetFieldError.duplicate => l10n.assetErrDuplicate,
      AssetFieldError.nameRequired => l10n.assetErrNameRequired,
      AssetFieldError.nameTaken => l10n.assetErrNameTaken,
      AssetFieldError.amountRequired => l10n.assetErrAmount,
      AssetFieldError.amountInvalid => l10n.assetErrAmountInvalid,
      AssetFieldError.amountNotPositive => l10n.assetErrAmountPositive,
      AssetFieldError.amountDecimals => l10n.assetErrAmountDecimals,
      AssetFieldError.priceRequired => l10n.assetErrPrice,
      AssetFieldError.priceInvalid => l10n.assetErrAmountInvalid,
      AssetFieldError.priceNotPositive => l10n.assetErrPricePositive,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: ListenableBuilder(
        listenable: c,
        builder: (context, _) => SossoldiBottomSheetToolbar.icon(
          title: c.isEditing ? l10n.assetEdit : l10n.assetNew,
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

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xl,
      children: [
        if (c.failure == MovementFailure.negativeQuantity)
          SossoldiAlert(
            tone: SossoldiAlertTone.error,
            message: l10n.assetErrDeleteRefused,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            Text(
              l10n.assetMainDetails,
              style: typography.labelBoldLarge.copyWith(color: colors.textHigh),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.s,
              children: [
                SossoldiSelect<PositionKind>(
                  label: l10n.assetType,
                  placeholder: l10n.assetTypePlaceholder,
                  value: c.kind,
                  onChanged: c.isEditing ? null : c.selectKind,
                  items: [
                    for (final k in PositionKind.values)
                      SossoldiSelectItem(
                        value: k,
                        label: positionKindLabel(context, k),
                      ),
                  ],
                ),
                _assetField(context),
                SossoldiTextInput(
                  controller: c.quantity,
                  label: l10n.assetAmount,
                  placeholder: l10n.assetAmountPlaceholder,
                  errorText: _errorText(c.quantityError),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SossoldiTextInput(
                  controller: c.price,
                  label: l10n.assetAveragePrice,
                  placeholder: l10n.assetPricePlaceholder,
                  suffixText: SossoldiAmountFormat.currencySymbol(
                    context,
                    c.currency,
                  ),
                  errorText: _errorText(c.priceError),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        SossoldiSwitchRow(
          label: l10n.assetCountsForNetWorth,
          value: c.countsForNetWorth,
          onChanged: c.setCountsForNetWorth,
        ),
        if (c.isEditing)
          Center(
            child: SossoldiButton(
              label: l10n.assetDelete,
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

  /// The asset: off until a type is chosen; then a search in the catalog of
  /// that type (as in the form of a movement), or the name of a manual asset.
  Widget _assetField(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = c.repository;
    if (c.kind == null) {
      return SossoldiSelect<String>(
        label: l10n.assetAsset,
        placeholder: l10n.assetAssetPlaceholder,
        value: null,
        onChanged: null,
        items: const [],
      );
    }
    if (c.isManual) {
      return SossoldiTextInput(
        controller: c.manualName,
        label: l10n.assetAsset,
        placeholder: l10n.assetManualNamePlaceholder,
        enabled: !c.isEditing,
        errorText: _errorText(c.assetError),
      );
    }
    final chosen = c.assetId == null ? null : repo.asset(c.assetId!);
    if (chosen != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          Text(
            l10n.assetAsset,
            style: context.typography.labelMedium.copyWith(
              color: colors.textHigh,
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.s),
              ),
            ),
            // The border over the row: the row's own background would hide
            // its inner half.
            foregroundDecoration: ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.s),
                side: BorderSide(color: colors.strokePlus1),
              ),
            ),
            child: SossoldiMenuItem(
              label: chosen.name,
              subtitle: '${chosen.ticker} – ${chosen.isin}',
              trailing: c.isEditing
                  ? null
                  : SossoldiButton(
                      label: l10n.movementChangeAsset,
                      type: SossoldiButtonType.ghost,
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                        c.selectAsset(null);
                      },
                    ),
            ),
          ),
          if (c.assetError != null)
            Text(
              _errorText(c.assetError)!,
              style: context.typography.labelMedium.copyWith(
                color: colors.error.text,
              ),
            ),
        ],
      );
    }
    final results = _query.trim().isEmpty
        ? const <dynamic>[]
        : c.search(_query).take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiSearchField(
          controller: _search,
          placeholder: l10n.assetSearch,
          clearSemanticLabel: l10n.clearSearch,
          results: [for (final a in results) '${a.name} (${a.ticker})'],
          onChanged: (q) => setState(() => _query = q),
          onResultTap: (i) => c.selectAsset(results[i].id as String),
        ),
        if (c.assetError != null)
          Text(
            _errorText(c.assetError)!,
            style: context.typography.labelMedium.copyWith(
              color: colors.error.text,
            ),
          ),
      ],
    );
  }
}
