// Bottom navigation bar, from Figma component "NavbarNew" (node 13:3855):
// a white pill with the page tabs and, apart from it, the round primary
// action button ("+").

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
    return Row(
      spacing: SossoldiSpacing.xl,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxPillWidth),
              child: Container(
                height: height,
                padding: const EdgeInsets.all(2),
                // Not in Figma: in dark mode the shadow is invisible and the
                // bar (surfaceHigh) is close to the background, so a thin
                // border marks its edge. Drawn on top so it takes no space.
                // Light mode is unchanged.
                foregroundDecoration:
                    Theme.of(context).brightness == Brightness.dark
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(SossoldiRadius.max),
                        border: Border.all(color: colors.strokePlus1),
                      )
                    : null,
                decoration: BoxDecoration(
                  color: colors.surfaceHigh,
                  borderRadius: BorderRadius.circular(SossoldiRadius.max),
                  boxShadow: SossoldiShadows.m,
                ),
                child: Row(
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
        SossoldiTappable(
          onTap: onAction,
          semanticLabel: actionSemanticLabel,
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: colors.primary.surface,
              shape: BoxShape.circle,
              boxShadow: SossoldiShadows.m,
            ),
            child: Icon(actionIcon, size: 24, color: colors.primary.onSurface),
          ),
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
        padding: const EdgeInsets.symmetric(vertical: SossoldiSpacing.xs),
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
