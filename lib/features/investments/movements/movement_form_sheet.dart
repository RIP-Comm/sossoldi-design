import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/investment_movement.dart';
import 'movement_form_controller.dart';
import 'movement_form_fields.dart';

/// Opens the form that records a movement: [type] selected (a buy by
/// default) and, when given, the position already chosen. Returns whether a
/// movement was saved.
Future<bool> showMovementFormSheet(
  BuildContext context, {
  MovementType type = MovementType.buy,
  String? holdingId,
}) async {
  final repository = AppScope.read(context).repository;
  // Made once, here: the builder runs again when the keyboard comes and goes,
  // and a new controller would lose what was typed.
  final controller = MovementFormController(
    repository,
    type: type,
    holdingId: holdingId,
  );
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _MovementFormSheet(controller: controller),
  );
  return saved ?? false;
}

class _MovementFormSheet extends StatefulWidget {
  const _MovementFormSheet({required this.controller});

  final MovementFormController controller;

  @override
  State<_MovementFormSheet> createState() => _MovementFormSheetState();
}

class _MovementFormSheetState extends State<_MovementFormSheet> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _save() {
    if (widget.controller.submit()) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.text(
        title: l10n.movementNew,
        closeLabel: l10n.cancel,
        onClose: () => Navigator.of(context).pop(false),
        confirmLabel: l10n.movementAdd,
        onConfirm: _save,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: MovementFormFields(controller: widget.controller),
        ),
      ),
    );
  }
}
