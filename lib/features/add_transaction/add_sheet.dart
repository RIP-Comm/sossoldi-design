// The Add sheet: one bottom sheet to record a transaction (expense, income,
// transfer, also recurring) or an investment movement. Not in Figma: the
// movement form was the visual reference. The title opens a small menu to
// change what is being added without closing the sheet.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/investment_movement.dart';
import '../investments/movements/movement_form_controller.dart';
import '../investments/movements/movement_form_fields.dart';
import 'add_sheet_draft.dart';
import 'transaction_form_controller.dart';
import 'transaction_form_fields.dart';

/// Opens the Add sheet, in the mode (and with the fields filled) that [draft]
/// says; a transaction by default. Returns whether something was added.
Future<bool> showAddSheet(
  BuildContext context, {
  AddSheetDraft draft = const AddSheetDraft(),
}) async {
  final repository = AppScope.read(context).repository;
  final locale = Localizations.localeOf(context).toString();
  // Where the snackbar goes when the sheet closes, lifted above the bottom
  // bar of the app.
  final outer = ScaffoldMessenger.of(context);
  final view = View.of(context);
  final safeBottom = view.padding.bottom / view.devicePixelRatio;
  final bottomMargin =
      math.max(safeBottom, SossoldiSpacing.l) +
      SossoldiNavbar.height +
      SossoldiSpacing.l;
  // Made once, here: the builder runs again when the keyboard comes and goes,
  // and new controllers would lose what was typed.
  final transaction = TransactionFormController(
    repository,
    locale: locale,
    draft: draft,
  );
  final movement = MovementFormController(
    repository,
    type: draft.movementType ?? MovementType.buy,
    holdingId: draft.holdingId,
  );
  final added = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _AddSheet(
      repository: repository,
      mode: draft.mode,
      transaction: transaction,
      movement: movement,
      outerMessenger: outer,
      outerBottomMargin: bottomMargin,
    ),
  );
  return added ?? false;
}

class _AddSheet extends StatefulWidget {
  const _AddSheet({
    required this.repository,
    required this.mode,
    required this.transaction,
    required this.movement,
    required this.outerMessenger,
    required this.outerBottomMargin,
  });

  final MockRepository repository;
  final AddMode mode;
  final TransactionFormController transaction;
  final MovementFormController movement;
  final ScaffoldMessengerState outerMessenger;
  final double outerBottomMargin;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  late AddMode _mode = widget.mode;

  @override
  void dispose() {
    widget.transaction.dispose();
    widget.movement.dispose();
    super.dispose();
  }

  bool get _isTransaction => _mode == AddMode.transaction;

  /// Saves what the form says. Returns the way to take it back, or null when
  /// the form is not valid (its errors show).
  VoidCallback? _save() {
    final repo = widget.repository;
    if (_isTransaction) {
      final added = widget.transaction.submit();
      return added == null ? null : () => repo.undoAdded(added);
    }
    if (!widget.movement.submit()) return null;
    final id = widget.movement.addedId;
    return id == null ? null : () => repo.deleteMovement(id);
  }

  void _add() {
    final undo = _save();
    if (undo == null) return;
    final l10n = context.l10n;
    showSossoldiSnackbar(
      context,
      messenger: widget.outerMessenger,
      bottomMargin: widget.outerBottomMargin,
      type: SossoldiSnackbarType.success,
      title: _isTransaction ? l10n.addTransactionDone : l10n.addMovementDone,
      actionLabel: l10n.addUndo,
      onAction: undo,
    );
    Navigator.of(context).pop(true);
  }

  void _setMode(AddMode mode) {
    if (mode == _mode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _mode = mode);
  }

  Widget _title(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final title = _isTransaction ? l10n.addNewTransaction : l10n.addNewMovement;
    Widget option(String label, AddMode mode) => Builder(
      builder: (popover) => SossoldiMenuItem(
        label: label,
        selected: _mode == mode,
        onTap: () {
          SossoldiPopover.close(popover);
          _setMode(mode);
        },
      ),
    );
    return Center(
      child: SossoldiPopover(
        width: 260,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(l10n.addModeTransaction, AddMode.transaction),
            option(l10n.addModeMovement, AddMode.movement),
          ],
        ),
        child: Semantics(
          label: l10n.addModeSemantic,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SossoldiSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: SossoldiSpacing.xs,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.titleMedium.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretDown,
                  size: 16,
                  color: colors.textHigh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listenable = _isTransaction ? widget.transaction : widget.movement;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: ListenableBuilder(
        listenable: listenable,
        builder: (context, _) => SossoldiBottomSheetToolbar.icon(
          title: _isTransaction ? l10n.addNewTransaction : l10n.addNewMovement,
          titleWidget: _title(context),
          onClose: () => Navigator.of(context).pop(false),
          closeSemanticLabel: l10n.close,
          // Off until every required field is filled.
          onConfirm: _add,
          confirmEnabled: _isTransaction
              ? widget.transaction.isValid
              : widget.movement.isValid,
          confirmSemanticLabel: _isTransaction
              ? l10n.addTransactionButton
              : l10n.addMovementButton,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: _isTransaction
              ? TransactionFormFields(controller: widget.transaction)
              : MovementFormFields(controller: widget.movement),
        ),
      ),
    );
  }
}
