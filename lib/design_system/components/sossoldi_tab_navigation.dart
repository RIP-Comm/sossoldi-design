// Tab navigation (segmented control), from Figma component
// "Tab navigation" (node 3:3808). Text tabs share the width equally;
// icon tabs keep their own size.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tab.dart';

class SossoldiTabNavigation extends StatelessWidget {
  const SossoldiTabNavigation({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// Tab contents; [SossoldiTab.active] and [SossoldiTab.onTap] are set
  /// by the navigation, so build them with any value.
  final List<SossoldiTabData> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final iconOnly = tabs.every((t) => t.label == null);
    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surfaceLow,
        borderRadius: BorderRadius.circular(SossoldiRadius.m),
      ),
      child: Row(
        mainAxisSize: iconOnly ? MainAxisSize.min : MainAxisSize.max,
        spacing: SossoldiSpacing.xs,
        children: [
          for (final (i, tab) in tabs.indexed)
            if (iconOnly)
              tab.build(active: i == selectedIndex, onTap: () => onChanged(i))
            else
              Expanded(
                child: tab.build(
                  active: i == selectedIndex,
                  onTap: () => onChanged(i),
                ),
              ),
        ],
      ),
    );
  }
}

/// Content of one tab in a [SossoldiTabNavigation].
class SossoldiTabData {
  const SossoldiTabData.text(String this.label, {this.icon, this.counter})
    : semanticLabel = null;

  const SossoldiTabData.icon(
    IconData this.icon, {
    required String this.semanticLabel,
  }) : label = null,
       counter = null;

  final String? label;
  final IconData? icon;
  final String? counter;
  final String? semanticLabel;

  Widget build({required bool active, required VoidCallback onTap}) {
    if (label == null) {
      return SossoldiTab.icon(
        icon: icon!,
        active: active,
        onTap: onTap,
        semanticLabel: semanticLabel!,
      );
    }
    return SossoldiTab(
      label: label!,
      icon: icon,
      counter: counter,
      active: active,
      onTap: onTap,
    );
  }
}
