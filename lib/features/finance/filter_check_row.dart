import 'package:flutter/widgets.dart';

import '../../design_system/design_system.dart';

/// A row of a multi-select list in a filters sheet: icon, name and a
/// checkbox; tapping anywhere on the row toggles it.
class FilterCheckRow extends StatelessWidget {
  const FilterCheckRow({
    super.key,
    required this.icon,
    required this.label,
    required this.checked,
    required this.onToggle,
  });

  final Widget icon;
  final String label;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => SossoldiMenuItem(
    label: label,
    leading: icon,
    trailing: IgnorePointer(
      child: SossoldiCheckbox(value: checked, onChanged: (_) {}),
    ),
    // The checkbox shows the state; the row is not tinted like a selected
    // option of a dropdown.
    onTap: onToggle,
  );
}
