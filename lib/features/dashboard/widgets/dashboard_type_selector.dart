import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../design_system/design_system.dart';

/// The type chip of the header of a Dashboard widget ("All", "Weekly",
/// "Income"…) with a caret; a tap
/// opens a menu. [enabled] false (edit mode) dims it and ignores taps.
class DashboardTypeSelector extends StatelessWidget {
  const DashboardTypeSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
    this.enabled = true,
    this.disabledKeys = const {},
  });

  final String label;

  /// Menu entries in order; the key is what [onSelected] receives (null: all).
  final List<({String? key, String label})> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String semanticLabel;
  final bool enabled;

  /// Entries shown but dimmed and not selectable (e.g. a period the history
  /// does not cover).
  final Set<String?> disabledKeys;

  @override
  Widget build(BuildContext context) {
    final chip = Semantics(
      label: semanticLabel,
      value: label,
      button: true,
      enabled: enabled,
      child: SossoldiChip(
        label: label,
        type: SossoldiChipType.subtle,
        iconRight: PhosphorIconsRegular.caretDown,
      ),
    );
    if (!enabled) {
      return IgnorePointer(child: Opacity(opacity: 0.5, child: chip));
    }
    return SossoldiPopover(
      width: 200,
      alignEnd: true,
      // Opens above when the widget is low on the screen.
      flipBelow: 340,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            Builder(
              builder: (popover) => SossoldiMenuItem(
                label: o.label,
                selected: o.key == selected,
                enabled: !disabledKeys.contains(o.key),
                onTap: () {
                  SossoldiPopover.close(popover);
                  onSelected(o.key);
                },
              ),
            ),
        ],
      ),
      child: chip,
    );
  }
}
