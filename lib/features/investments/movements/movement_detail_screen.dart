// Page of one movement, in the pattern of the budget and recurring pages:
// Back, the type and the asset, Edit. Read-only until Edit; then the numbers
// become fields (the type and the asset do not change), Edit is Done and a
// red "Delete movement" appears at the bottom. Not in Figma.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/mock_repository.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/movement_edit.dart';
import '../investments_texts.dart';
import '../positions/position_detail_screen.dart';
import 'movement_form_controller.dart';
import 'movement_form_fields.dart';

class MovementDetailScreen extends StatefulWidget {
  const MovementDetailScreen({super.key, required this.movementId});

  final String movementId;

  @override
  State<MovementDetailScreen> createState() => _MovementDetailScreenState();
}

class _MovementDetailScreenState extends State<MovementDetailScreen> {
  late final MockRepository _repo = AppScope.read(context).repository;
  MovementFormController? _form;
  String? _error;

  /// The movement, or null once it is gone.
  InvestmentMovement? get _movement {
    for (final m in _repo.movements()) {
      if (m.id == widget.movementId) return m;
    }
    return null;
  }

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  void _startEditing() {
    final m = _movement;
    if (m == null) return;
    setState(() {
      _error = null;
      _form = MovementFormController(_repo, editing: m);
    });
  }

  void _stopEditing() {
    _form?.dispose();
    setState(() {
      _form = null;
      _error = null;
    });
  }

  void _save() {
    final form = _form!;
    if (form.submit()) _stopEditing();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final check = _repo.deleteMovement(widget.movementId, dryRun: true);
    if (!check.ok) {
      setState(
        () => _error = failureText(context, check.failure!, check.failedOn),
      );
      return;
    }
    final confirmed = await showSossoldiModal<bool>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          Text(
            l10n.movementDeleteTitle,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            l10n.movementDeleteMessage,
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
                  label: l10n.movementDeleteConfirm,
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
    _repo.deleteMovement(widget.movementId);
    // Back to the list, which already shows it gone.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final m = _movement;
        if (m == null) return const SizedBox.shrink();
        final entry = _repo.movementEntry(m);
        final editing = _form != null;
        final name = entry.ticker ?? entry.name ?? m.description ?? '';
        return PopScope(
          canPop: !editing,
          // Back while editing leaves edit mode instead of the page.
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _stopEditing();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceMed,
            body: SafeArea(
              child: Column(
                children: [
                  SossoldiBottomSheetToolbar.text(
                    title: '${movementTypeLabel(context, m.type)} · $name',
                    closeLabel: editing ? l10n.cancel : l10n.back,
                    closeIcon: editing ? null : PhosphorIconsRegular.caretLeft,
                    onClose: editing
                        ? _stopEditing
                        : () => Navigator.of(context).pop(),
                    confirmLabel: editing
                        ? l10n.doneEditing
                        : l10n.movementDetailEdit,
                    onConfirm: editing ? _save : _startEditing,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          SossoldiSpacing.l,
                          SossoldiSpacing.l,
                          SossoldiSpacing.l,
                          SossoldiSpacing.l +
                              MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: SossoldiSpacing.l,
                          children: [
                            if (_error != null)
                              SossoldiAlert(
                                tone: SossoldiAlertTone.error,
                                message: _error!,
                              ),
                            _Summary(entry: entry, form: _form),
                            if (editing)
                              Center(
                                child: SossoldiButton(
                                  label: l10n.movementDelete,
                                  tone: SossoldiButtonTone.danger,
                                  size: SossoldiButtonSize.large,
                                  onPressed: _delete,
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

/// The read-only rows of the movement, or its fields while editing.
class _Summary extends StatelessWidget {
  const _Summary({required this.entry, required this.form});

  final MovementEntry entry;
  final MovementFormController? form;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = context.repository;
    final m = entry.movement;
    final masked = context.hideAmounts;
    final locale = Localizations.localeOf(context).toString();

    Widget card(List<Widget> rows) => Container(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: rows,
      ),
    );
    Widget row(String label, Widget value) => Row(
      spacing: SossoldiSpacing.s,
      children: [
        Expanded(
          child: Text(
            label,
            style: typography.labelLarge.copyWith(color: colors.textMed),
          ),
        ),
        Flexible(child: value),
      ],
    );
    Widget text(String t) => Text(
      masked ? '••••' : t,
      textAlign: TextAlign.end,
      style: typography.labelLarge.copyWith(color: colors.textHigh),
    );
    Widget plain(String t) => Text(
      t,
      textAlign: TextAlign.end,
      style: typography.labelLarge.copyWith(color: colors.textHigh),
    );
    String money(double v, String currency, {bool plus = false}) =>
        SossoldiAmountFormat.money(
          context,
          v,
          currencyCode: currency,
          showPlusSign: plus,
        );

    final account = m.accountId == null ? null : repo.account(m.accountId!);
    final isTrade = m.type == MovementType.buy || m.type == MovementType.sell;

    // The type and the asset are always read-only.
    final identity = card([
      row(l10n.movementDetailType, plain(movementTypeLabel(context, m.type))),
      if (entry.name != null)
        row(
          l10n.movementDetailAsset,
          entry.holdingOpen
              ? SossoldiTappable(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PositionDetailScreen(holdingId: m.holdingId!),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: SossoldiSpacing.xs,
                    children: [
                      Flexible(
                        child: Text(
                          entry.name!,
                          textAlign: TextAlign.end,
                          style: typography.labelLarge.copyWith(
                            color: colors.primary.text,
                          ),
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: colors.primary.text,
                      ),
                    ],
                  ),
                )
              : plain(entry.name!),
        ),
    ]);

    if (form != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.l,
        children: [
          identity,
          MovementFormFields(controller: form!),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        identity,
        card([
          if (account != null)
            row(l10n.movementDetailAccount, plain(account.name)),
          row(
            l10n.movementDetailDate,
            plain(DateFormat.yMMMMd(locale).format(m.date)),
          ),
          if (isTrade) ...[
            row(
              l10n.movementDetailQuantity,
              text(unitsText(context, m.quantity ?? 0)),
            ),
            row(
              l10n.movementDetailPrice,
              text(money(m.price ?? 0, m.currency)),
            ),
            row(l10n.movementDetailFee, text(money(m.fee, m.currency))),
          ] else ...[
            if (m.description != null)
              row(l10n.movementFieldDescription, plain(m.description!)),
          ],
          row(
            l10n.movementDetailTotal,
            text(
              money(
                m.type == MovementType.cost ? -entry.total : entry.total,
                m.currency,
                plus: m.type == MovementType.dividend,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}
