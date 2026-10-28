// The form of a subcategory, from the Figma "Onboarding 0.2.2" and "0.2.3"
// (nodes 13:3552 and 13:3565): a bottom sheet with X, title and check and the
// name. It touches no data: it returns the name typed (or its deletion) and
// the form of the category keeps it in its draft. The red "Delete
// subcategory" of the edit is not in Figma (same pattern as Delete budget).

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// What the form of a subcategory returned: the name, or its deletion.
class SubcategoryFormResult {
  const SubcategoryFormResult.saved(String this.name) : deleted = false;
  const SubcategoryFormResult.deleted() : name = null, deleted = true;

  final String? name;
  final bool deleted;
}

/// Opens the form of a new subcategory, or of the one called [editing].
/// [nameTaken] says whether another subcategory of the category has the name.
/// Returns null when the form is closed with the X.
Future<SubcategoryFormResult?> showSubcategoryFormSheet(
  BuildContext context, {
  String? editing,
  required bool Function(String name) nameTaken,
}) {
  return showModalBottomSheet<SubcategoryFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) =>
        _SubcategoryFormSheet(editing: editing, nameTaken: nameTaken),
  );
}

class _SubcategoryFormSheet extends StatefulWidget {
  const _SubcategoryFormSheet({required this.editing, required this.nameTaken});

  final String? editing;
  final bool Function(String name) nameTaken;

  @override
  State<_SubcategoryFormSheet> createState() => _SubcategoryFormSheetState();
}

class _SubcategoryFormSheetState extends State<_SubcategoryFormSheet> {
  final _name = TextEditingController();
  bool _touched = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _name.text = widget.editing ?? '';
    _name.addListener(() => setState(() => _touched = true));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _empty => _name.text.trim().isEmpty;
  bool get _taken => !_empty && widget.nameTaken(_name.text.trim());
  bool get _valid => !_empty && !_taken;

  String? _errorText() {
    final l10n = context.l10n;
    if (_taken) return l10n.subcategoryErrNameTaken;
    if (_touched && _empty) return l10n.categoryErrName;
    return null;
  }

  void _save() {
    if (_valid) {
      Navigator.of(context).pop(SubcategoryFormResult.saved(_name.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.icon(
        title: _isEditing ? l10n.subcategoryEdit : l10n.subcategoryNew,
        onClose: () => Navigator.of(context).pop(),
        closeSemanticLabel: l10n.close,
        onConfirm: _save,
        confirmSemanticLabel: l10n.accountSave,
        confirmEnabled: _valid,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SossoldiTextInput(
                controller: _name,
                label: l10n.accountName,
                placeholder: l10n.subcategoryNamePlaceholder,
                errorText: _errorText(),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
            ),
          ),
          if (_isEditing)
            Padding(
              padding: EdgeInsets.only(
                top: SossoldiSpacing.s,
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SossoldiButton(
                label: l10n.subcategoryDelete,
                type: SossoldiButtonType.ghost,
                tone: SossoldiButtonTone.danger,
                size: SossoldiButtonSize.large,
                iconRight: PhosphorIconsRegular.trash,
                onPressed: () =>
                    Navigator.of(context)
                        .pop(const SubcategoryFormResult.deleted()),
              ),
            ),
        ],
      ),
    );
  }
}
