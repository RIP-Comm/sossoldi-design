// Category row, from Figma component "Category" (node 3:4366),
// types Default, Open (expanded with subcategories) and Suggested.
// The Type=Button variant is SossoldiListAddButton.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';
import 'sossoldi_tappable.dart';

class SossoldiSubcategory {
  const SossoldiSubcategory({
    required this.name,
    required this.leading,
    this.onTap,
  });

  final String name;
  final Widget leading;
  final VoidCallback? onTap;
}

class SossoldiCategoryItem extends StatefulWidget {
  /// Default / Open: tapping the row expands its subcategories, if any.
  const SossoldiCategoryItem({
    super.key,
    required this.name,
    required this.leading,
    this.subtitle,
    this.subcategories = const [],
    this.initiallyExpanded = false,
    this.onTap,
    this.onRowTap,
    this.expandSemanticLabel,
    this.collapseSemanticLabel,
    this.hasChevron = false,
  }) : onAdd = null,
       addSemanticLabel = null;

  /// Suggested: a category the user can add with the trailing "+".
  const SossoldiCategoryItem.suggested({
    super.key,
    required this.name,
    required this.leading,
    required VoidCallback this.onAdd,
    required String this.addSemanticLabel,
    this.subtitle,
  }) : subcategories = const [],
       initiallyExpanded = false,
       onTap = null,
       onRowTap = null,
       expandSemanticLabel = null,
       collapseSemanticLabel = null,
       hasChevron = false;

  final String name;

  /// 24px slot, usually the category icon.
  final Widget leading;

  /// Second line (e.g. budget or subcategory names).
  final String? subtitle;
  final List<SossoldiSubcategory> subcategories;
  final bool initiallyExpanded;

  /// Tap on a category without subcategories.
  final VoidCallback? onTap;

  /// Tap on the row of a category that has subcategories, when it must do
  /// something else than open them (e.g. edit the category): then only the
  /// caret opens and closes the list. Not in Figma's Default / Open types,
  /// where the whole row toggles; added for the onboarding (node 13:3685).
  final VoidCallback? onRowTap;

  /// Screen reader labels of the caret when [onRowTap] is set.
  final String? expandSemanticLabel;
  final String? collapseSemanticLabel;
  final VoidCallback? onAdd;
  final String? addSemanticLabel;

  /// A right chevron: the row opens a page (with [onTap], no subcategories).
  /// Not in Figma: added for Settings > Categories.
  final bool hasChevron;

  @override
  State<SossoldiCategoryItem> createState() => _SossoldiCategoryItemState();
}

class _SossoldiCategoryItemState extends State<SossoldiCategoryItem> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _hasSubitems => widget.subcategories.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final caretOnly = widget.onRowTap != null && _hasSubitems;
    void toggle() => setState(() => _expanded = !_expanded);

    Widget? trailing;
    if (widget.onAdd != null) {
      trailing = SossoldiIconButton(
        icon: PhosphorIconsRegular.plus,
        size: SossoldiIconButtonSize.xs,
        semanticLabel: widget.addSemanticLabel!,
        onPressed: widget.onAdd,
      );
    } else if (widget.hasChevron && !_hasSubitems) {
      trailing = SizedBox.square(
        dimension: 24,
        child: Icon(
          PhosphorIconsRegular.caretRight,
          size: 16,
          color: colors.textHigh,
        ),
      );
    } else if (_hasSubitems) {
      final caret = Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          _expanded
              ? PhosphorIconsRegular.caretUp
              : PhosphorIconsRegular.caretDown,
          size: 16,
          color: colors.textHigh,
        ),
      );
      trailing = caretOnly
          ? SossoldiTappable(
              onTap: toggle,
              semanticLabel: _expanded
                  ? widget.collapseSemanticLabel
                  : widget.expandSemanticLabel,
              child: Padding(
                padding: const EdgeInsets.all(SossoldiSpacing.s),
                child: caret,
              ),
            )
          : caret;
    }

    final header = _Row(
      leading: widget.leading,
      name: widget.name,
      subtitle: widget.subtitle,
      trailing: trailing,
      onTap: caretOnly
          ? widget.onRowTap
          : _hasSubitems
          ? toggle
          : widget.onTap,
      expanded: _hasSubitems && !caretOnly ? _expanded : null,
    );

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.s),
      child: ColoredBox(
        color: colors.surfaceHigh,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (_expanded && _hasSubitems)
                Padding(
                  padding: const EdgeInsets.all(SossoldiSpacing.xs),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colors.surfaceMed,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(SossoldiRadius.s),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final sub in widget.subcategories)
                          _Row(
                            leading: sub.leading,
                            name: sub.name,
                            onTap: sub.onTap,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.name,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.expanded,
  });

  final Widget leading;
  final String name;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      child: Row(
        spacing: SossoldiSpacing.s,
        children: [
          SizedBox.square(dimension: 24, child: Center(child: leading)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.labelLarge.copyWith(color: colors.textHigh),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelSmall.copyWith(
                      color: colors.textMed,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      expanded: expanded,
      child: SossoldiTappable(onTap: onTap, child: row),
    );
  }
}
