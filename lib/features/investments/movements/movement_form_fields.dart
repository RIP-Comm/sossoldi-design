// The fields of a movement, from the Investments components (Figma node
// 13:5033) and the existing inputs: not designed in Figma, so built from the
// design system. Used by the sheet that adds a movement and by the page that
// changes one (there the type and the asset are fixed).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/holding.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/movement_edit.dart';
import '../investments_texts.dart';
import 'movement_form_controller.dart';

String fieldErrorText(BuildContext context, FieldError e) {
  final l10n = context.l10n;
  return switch (e) {
    FieldError.required => l10n.movementErrRequired,
    FieldError.notANumber => l10n.movementErrNumber,
    FieldError.notPositive => l10n.movementErrPositive,
    FieldError.future => l10n.movementErrFuture,
    FieldError.chooseAsset => l10n.movementErrChooseAsset,
  };
}

/// Why the repository refused a movement, in the user's language.
String failureText(
  BuildContext context,
  MovementFailure failure,
  DateTime? failedOn,
) {
  final l10n = context.l10n;
  return switch (failure) {
    MovementFailure.negativeQuantity => l10n.movementErrNegative(
      failedOn == null
          ? ''
          : DateFormat.yMMMd(Localizations.localeOf(context).toString())
                .format(failedOn),
    ),
    _ => l10n.movementErrInvalid,
  };
}

class MovementFormFields extends StatefulWidget {
  const MovementFormFields({super.key, required this.controller});

  final MovementFormController controller;

  @override
  State<MovementFormFields> createState() => _MovementFormFieldsState();
}

class _MovementFormFieldsState extends State<MovementFormFields> {
  final TextEditingController _assetSearch = TextEditingController();
  String _assetQuery = '';

  MovementFormController get c => widget.controller;

  @override
  void dispose() {
    _assetSearch.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final l10n = context.l10n;
    final today = c.repository.today;
    final picked = await showSossoldiBottomSheet<DateTime>(
      context: context,
      toolbar: Builder(
        builder: (sheet) => SossoldiBottomSheetToolbar.icon(
          title: l10n.movementFieldDate,
          onClose: () => Navigator.of(sheet).pop(),
          closeSemanticLabel: l10n.close,
        ),
      ),
      builder: (sheet) => Container(
        padding: const EdgeInsets.all(SossoldiSpacing.s),
        decoration: ShapeDecoration(
          color: sheet.colors.surfaceHigh,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(SossoldiRadius.m),
          ),
        ),
        child: SossoldiDateRangePicker(
          start: null,
          end: null,
          // A dividend can be expected; the rest has already happened.
          lastDate: c.type == MovementType.dividend
              ? DateTime(today.year + 1, today.month, today.day)
              : today,
          onChanged: (start, _) => Navigator.of(sheet).pop(start),
          previousMonthSemanticLabel: l10n.previousMonth,
          nextMonthSemanticLabel: l10n.nextMonth,
        ),
      ),
    );
    if (picked != null) c.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = c.repository;
    final masked = context.hideAmounts;
    // An opening buy has no account and no commission.
    final opening = c.editing?.isOpening ?? false;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        String? err(FieldError? e) {
          final shown = c.shown(e);
          return shown == null ? null : fieldErrorText(context, shown);
        }

        final holding = c.holdingId == null ? null : repo.holding(c.holdingId!);
        final currency = holding?.currency ?? repo.mainCurrency;
        final symbol = SossoldiAmountFormat.currencySymbol(context, currency);
        final liquidity = c.type == MovementType.buy ? c.liquidityAfter : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            if (c.submitted && c.failure != null)
              SossoldiAlert(
                tone: SossoldiAlertTone.error,
                message: failureText(context, c.failure!, c.failedOn),
              ),
            if (!c.isEditing)
              SossoldiTabNavigation(
                tabs: [
                  for (final t in MovementType.values)
                    SossoldiTabData.text(movementTypeLabel(context, t)),
                ],
                selectedIndex: c.type.index,
                onChanged: (i) => c.selectType(MovementType.values[i]),
              ),
            if (!c.isEditing) _assetSection(context, err),
            if (repo.brokerAccounts.length > 1 && !opening)
              SossoldiSelect<String>(
                label: l10n.movementFieldAccount,
                value: c.accountId,
                onChanged: c.setAccount,
                items: [
                  for (final a in repo.brokerAccounts)
                    SossoldiSelectItem(value: a.id, label: a.name),
                ],
              ),
            _DateField(
              label: l10n.movementFieldDate,
              date: c.date,
              errorText: err(c.dateError),
              onTap: _pickDate,
            ),
            if (c.isTrade) ...[
              SossoldiTextInput(
                controller: c.quantity,
                label: l10n.movementFieldQuantity,
                helperText:
                    c.type == MovementType.sell &&
                        holding != null &&
                        !c.isEditing
                    ? l10n.movementHeld(unitsText(context, holding.quantity))
                    : null,
                errorText: err(c.quantityError),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SossoldiTextInput(
                controller: c.price,
                label: l10n.movementFieldUnitPrice,
                suffixText: symbol,
                errorText: err(c.priceError),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              if (!opening)
                SossoldiTextInput(
                  controller: c.fee,
                  label: l10n.movementFieldFee,
                  suffixText: symbol,
                  errorText: err(c.feeError),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
            ] else ...[
              SossoldiTextInput(
                controller: c.amount,
                label: c.type == MovementType.dividend
                    ? l10n.movementFieldNetAmount
                    : l10n.movementFieldAmount,
                suffixText: symbol,
                errorText: err(c.amountError),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SossoldiTextInput(
                controller: c.description,
                label: c.type == MovementType.cost
                    ? l10n.movementFieldDescription
                    : l10n.movementFieldDescriptionOptional,
                errorText: err(c.descriptionError),
              ),
            ],
            if (liquidity != null && liquidity < 0)
              SossoldiAlert(
                tone: SossoldiAlertTone.warning,
                message: l10n.movementLiquidityWarning(
                  masked
                      ? '••••'
                      : SossoldiAmountFormat.money(
                          context,
                          liquidity,
                          currencyCode: repo.mainCurrency,
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// The asset: chosen among the positions held (sell, dividend, cost) or, for
  /// a buy, found in the catalog or entered by hand.
  Widget _assetSection(
    BuildContext context,
    String? Function(FieldError?) err,
  ) {
    final l10n = context.l10n;
    final repo = c.repository;
    if (c.type != MovementType.buy) {
      final holdings = c.type == MovementType.cost
          ? [for (final a in repo.movementAssets()) (a.holdingId, a.label)]
          : [
              for (final h in repo.holdings)
                (
                  h.id,
                  h.isManual ? h.manualName! : repo.asset(h.assetId!).name,
                ),
            ];
      return SossoldiSelect<String>(
        label: c.type == MovementType.cost
            ? l10n.movementFieldAssetOptional
            : l10n.movementFieldAsset,
        value: c.holdingId ?? (c.type == MovementType.cost ? '' : null),
        placeholder: l10n.movementErrChooseAsset.replaceAll('.', ''),
        helperText: err(c.assetError),
        onChanged: (v) => c.selectHolding(v.isEmpty ? null : v),
        items: [
          if (c.type == MovementType.cost)
            SossoldiSelectItem(value: '', label: l10n.movementNoAsset),
          for (final (id, label) in holdings)
            SossoldiSelectItem(value: id, label: label),
        ],
      );
    }
    // The asset chosen: from the catalog, or a position of the portfolio (a
    // manual asset bought again).
    final chosen = c.assetId == null ? null : repo.asset(c.assetId!);
    final chosenHolding = c.holdingId == null
        ? null
        : repo.holding(c.holdingId!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Row(
          spacing: SossoldiSpacing.s,
          children: [
            SossoldiUnitNavigator(
              label: l10n.movementAssetCatalog,
              selected: !c.isManual,
              onTap: () => c.setManual(false),
            ),
            SossoldiUnitNavigator(
              label: l10n.movementAssetManual,
              selected: c.isManual,
              onTap: () => c.setManual(true),
            ),
          ],
        ),
        if (c.isManual) ...[
          SossoldiTextInput(
            controller: c.manualName,
            label: l10n.movementManualName,
            errorText: err(c.assetError),
          ),
          SossoldiSelect<ManualAssetType>(
            label: l10n.movementManualType,
            value: c.manualType,
            onChanged: c.setManualType,
            items: [
              for (final t in ManualAssetType.values)
                SossoldiSelectItem(
                  value: t,
                  label: manualTypeLabel(context, t),
                ),
            ],
          ),
        ] else if (chosen != null || chosenHolding != null)
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.s),
                side: BorderSide(color: context.colors.strokePlus1),
              ),
            ),
            child: SossoldiMenuItem(
              label: chosen?.name ?? chosenHolding!.manualName!,
              subtitle: chosen == null
                  ? null
                  : '${chosen.ticker} – ${chosen.isin}',
              trailing: SossoldiButton(
                label: l10n.movementChangeAsset,
                type: SossoldiButtonType.ghost,
                onPressed: () {
                  _assetSearch.clear();
                  setState(() => _assetQuery = '');
                  c.selectHolding(null);
                  c.selectCatalogAsset(null);
                },
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.xs,
            children: [
              SossoldiSearchField(
                controller: _assetSearch,
                placeholder: l10n.movementSearchAsset,
                clearSemanticLabel: l10n.clearSearch,
                results: _assetQuery.trim().isEmpty
                    ? const []
                    : [
                        for (final a in repo.searchAssets(_assetQuery).take(6))
                          '${a.name} (${a.ticker})',
                      ],
                onChanged: (q) => setState(() => _assetQuery = q),
                onResultTap: (i) {
                  final a = repo.searchAssets(_assetQuery).take(6).toList()[i];
                  c.selectCatalogAsset(a.id);
                },
              ),
              if (err(c.assetError) != null)
                Text(
                  err(c.assetError)!,
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.error.text,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// The date of the form: a field that opens the calendar.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final border = SossoldiFieldFrame.borderColor(
      context,
      enabled: true,
      focused: false,
      hasValue: true,
      isError: errorText != null,
    );
    return SossoldiFieldFrame(
      label: label,
      helperText: errorText,
      isError: errorText != null,
      child: SossoldiTappable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SossoldiSpacing.m,
            vertical: SossoldiSpacing.l,
          ),
          decoration: SossoldiFieldFrame.decoration(context, border),
          child: Row(
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMMd(locale).format(date),
                  style: context.typography.labelLarge.copyWith(
                    color: colors.textHigh,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.calendarBlank,
                size: 20,
                color: colors.textMed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
