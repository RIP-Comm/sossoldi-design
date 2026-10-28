// Icon picker of accounts and categories: a row of tabs, one icon for each
// group of icons (finance, shopping, travel...) as in the emoji keyboard, and
// under it the grid of the icons of the selected group. Not in Figma (the
// "Icon and color" selector only says "Tap to select"): built from the design
// system, to be reused by the categories.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/category_colors.dart';
import '../tokens/category_icons.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_bottom_sheet.dart';
import 'sossoldi_bottom_sheet_toolbar.dart';
import 'sossoldi_tab_navigation.dart';
import 'sossoldi_tappable.dart';

class SossoldiIconPicker extends StatefulWidget {
  const SossoldiIconPicker({
    super.key,
    required this.selected,
    required this.color,
    required this.onSelected,
    required this.groupLabel,
    this.groups = CategoryIcons.groups,
  });

  final IconData? selected;

  /// The selected icon is drawn in it, on its tint.
  final CategoryColor color;
  final ValueChanged<IconData> onSelected;

  /// Name of a group, for the screen readers (its tab is only an icon).
  final String Function(CategoryIconGroupId id) groupLabel;
  final List<CategoryIconGroup> groups;

  @override
  State<SossoldiIconPicker> createState() => _SossoldiIconPickerState();
}

class _SossoldiIconPickerState extends State<SossoldiIconPicker> {
  static const double _cell = 48;

  late int _index = _initialIndex();

  /// The group the selected icon is in, else the first.
  int _initialIndex() {
    final selected = widget.selected;
    if (selected == null) return 0;
    final i = widget.groups.indexWhere((g) => g.icons.contains(selected));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    final group = widget.groups[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        // 11 tabs do not fit a phone: the row scrolls.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SossoldiTabNavigation(
            tabs: [
              for (final g in widget.groups)
                SossoldiTabData.icon(
                  g.icon,
                  semanticLabel: widget.groupLabel(g.id),
                ),
            ],
            selectedIndex: _index,
            onChanged: (i) => setState(() => _index = i),
          ),
        ),
        Expanded(
          child: Container(
            decoration: ShapeDecoration(
              color: colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: GridView.builder(
              // A new group starts at the top.
              key: ValueKey(group.id),
              padding: const EdgeInsets.all(SossoldiSpacing.s),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: _cell,
                mainAxisSpacing: SossoldiSpacing.xs,
                crossAxisSpacing: SossoldiSpacing.xs,
              ),
              itemCount: group.icons.length,
              itemBuilder: (context, i) {
                final icon = group.icons[i];
                final selected = icon == widget.selected;
                return SossoldiTappable(
                  onTap: () => widget.onSelected(icon),
                  selected: selected,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? widget.color.tintFor(brightness) : null,
                      border: selected
                          ? Border.all(color: widget.color.main)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: selected ? widget.color.main : colors.shapeHigh,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the picker in a full-height bottom sheet and returns the icon tapped
/// (the sheet closes with it), or null when it is dismissed.
Future<IconData?> showSossoldiIconPicker({
  required BuildContext context,
  required String title,
  required String closeSemanticLabel,
  required IconData? selected,
  required CategoryColor color,
  required String Function(CategoryIconGroupId id) groupLabel,
}) {
  return showModalBottomSheet<IconData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (sheet) => SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.icon(
        title: title,
        onClose: () => Navigator.of(sheet).pop(),
        closeSemanticLabel: closeSemanticLabel,
      ),
      child: SossoldiIconPicker(
        selected: selected,
        color: color,
        groupLabel: groupLabel,
        onSelected: (icon) => Navigator.of(sheet).pop(icon),
      ),
    ),
  );
}
