// Bottom navigation bar, from Figma component "NavbarNew" (node 13:3855):
// a white pill with the page tabs and, apart from it, the round primary
// action button ("+").

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiNavbarItem {
  const SossoldiNavbarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;

  /// Regular-weight icon, shown when the tab is not selected.
  final IconData icon;

  /// Filled icon, shown when the tab is selected.
  final IconData activeIcon;
}

class SossoldiNavbar extends StatelessWidget {
  const SossoldiNavbar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    required this.onAction,
    required this.actionSemanticLabel,
    this.actionIcon = PhosphorIconsRegular.plus,
  });

  final List<SossoldiNavbarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Tap on the round button next to the tabs.
  final VoidCallback onAction;
  final String actionSemanticLabel;
  final IconData actionIcon;

  /// Height of the bar and size of the action button.
  static const double height = 54;

  static const double _maxPillWidth = 288;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pill = Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxPillWidth),
          child: Container(
            height: height,
            // Not in Figma: the bar (surfaceHigh) is close to the background
            // and its shadow is faint, so a thin border marks its edge, the
            // same in light and dark. Drawn on top so it takes no space.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SossoldiRadius.max),
              border: Border.all(color: colors.strokeMinus1),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SossoldiRadius.max),
              boxShadow: SossoldiShadows.m,
            ),
            // Try: light blur of what scrolls behind, translucent fill.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SossoldiRadius.max),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(SossoldiSpacing.xs),
                  color: colors.surfaceHighPlus1.withValues(alpha: 0.8),
                  child: Row(
                    // The selected pill fills the height inside the padding.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, item) in items.indexed)
                        Expanded(
                          child: _Tab(
                            item: item,
                            selected: i == selectedIndex,
                            onTap: () => onChanged(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final action = SossoldiTappable(
      onTap: onAction,
      semanticLabel: actionSemanticLabel,
      child: Container(
        width: height,
        height: height,
        decoration: BoxDecoration(
          color: colors.primary.surface,
          shape: BoxShape.circle,
          // Deeper than the bar: on the blue the light one is lost.
          boxShadow: SossoldiShadows.xl,
        ),
        child: Icon(actionIcon, size: 24, color: colors.primary.onSurface),
      ),
    );
    // The bar is painted over the shadow of the button: a Row would paint the
    // button last, so the two are stacked in the order that gives that.
    return Stack(
      children: [
        Align(alignment: Alignment.centerRight, child: action),
        Padding(
          padding: const EdgeInsets.only(right: height + SossoldiSpacing.xl),
          child: Row(children: [pill]),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final SossoldiNavbarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary.text : colors.textHigh;
    return SossoldiTappable(
      onTap: onTap,
      selected: selected,
      semanticLabel: item.label,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? colors.selectedSurface : null,
          borderRadius: BorderRadius.circular(SossoldiRadius.max),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: color,
            ),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
