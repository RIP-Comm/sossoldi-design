// Breadcrumb, from Figma component "Breadcrumb" (node 3:4274).
// With more than [maxVisible] items, the middle ones collapse into a "..."
// button that opens them in a dropdown.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_dropdown.dart';
import 'sossoldi_menu_item.dart';
import 'sossoldi_tappable.dart';

class SossoldiBreadcrumbItem {
  const SossoldiBreadcrumbItem({required this.label, this.icon, this.onTap});

  final String label;

  /// Shown instead of the label (Figma "Icon as item"); the label is then
  /// used for screen readers.
  final IconData? icon;
  final VoidCallback? onTap;
}

/// Figma: arrow (default), "/" (custom separator), chevron (icon items).
enum SossoldiBreadcrumbSeparator { arrow, slash, chevron }

class SossoldiBreadcrumb extends StatefulWidget {
  const SossoldiBreadcrumb({
    super.key,
    required this.items,
    required this.moreSemanticLabel,
    this.separator = SossoldiBreadcrumbSeparator.arrow,
    this.maxVisible = 4,
  });

  /// From the root to the current page (the last item).
  final List<SossoldiBreadcrumbItem> items;

  /// Screen reader label of the "..." button, e.g. "Show more".
  final String moreSemanticLabel;
  final SossoldiBreadcrumbSeparator separator;
  final int maxVisible;

  @override
  State<SossoldiBreadcrumb> createState() => _SossoldiBreadcrumbState();
}

class _SossoldiBreadcrumbState extends State<SossoldiBreadcrumb> {
  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _tapRegionGroup = Object();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = widget.items;
    final collapse = items.length > widget.maxVisible;
    // Keep the root and the last two items; hide the rest.
    final hidden = collapse ? items.sublist(1, items.length - 2) : const [];
    final visible = collapse
        ? [items.first, ...items.sublist(items.length - 2)]
        : items;

    Widget separator() => switch (widget.separator) {
      SossoldiBreadcrumbSeparator.slash => Text(
        '/',
        style: context.typography.labelMedium.copyWith(color: colors.textMed),
      ),
      SossoldiBreadcrumbSeparator.arrow => Icon(
        PhosphorIconsRegular.arrowRight,
        size: 16,
        color: colors.textLow,
      ),
      SossoldiBreadcrumbSeparator.chevron => Icon(
        PhosphorIconsRegular.caretRight,
        size: 20,
        color: colors.textMed,
      ),
    };

    final more = TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) => setState(_overlay.hide),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: (_) => CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, SossoldiSpacing.s),
            child: Align(
              alignment: Alignment.topLeft,
              child: TapRegion(
                groupId: _tapRegionGroup,
                child: SizedBox(
                  width: 152,
                  child: SossoldiDropdown(
                    options: [
                      for (final (i, item) in hidden.indexed)
                        SossoldiMenuItem(
                          label: item.label,
                          showDivider: i < hidden.length - 1,
                          onTap: () {
                            setState(_overlay.hide);
                            item.onTap?.call();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child: SossoldiTappable(
            onTap: () => setState(_overlay.toggle),
            semanticLabel: widget.moreSemanticLabel,
            child: Container(
              padding: const EdgeInsets.all(SossoldiSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SossoldiRadius.xs),
              ),
              child: Icon(
                PhosphorIconsBold.dotsThree,
                size: 16,
                color: colors.textMed,
              ),
            ),
          ),
        ),
      ),
    );

    final children = <Widget>[];
    for (final (i, item) in visible.indexed) {
      if (i > 0) children.add(separator());
      if (collapse && i == 1) children.addAll([more, separator()]);
      children.add(_Crumb(item: item, current: identical(item, items.last)));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: SossoldiSpacing.s,
      children: children,
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.item, required this.current});

  final SossoldiBreadcrumbItem item;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = current ? colors.textHigh : colors.textMed;
    final content = item.icon != null
        ? Icon(item.icon, size: 20, color: color)
        : Text(
            item.label,
            style: context.typography.labelMedium.copyWith(color: color),
          );
    if (current || item.onTap == null) {
      return Semantics(
        label: item.icon != null ? item.label : null,
        child: content,
      );
    }
    return SossoldiTappable(
      onTap: item.onTap,
      semanticLabel: item.icon != null ? item.label : null,
      child: content,
    );
  }
}
