// Menu item, from Figma component "Menu item" (node 3:4108): a row with
// optional icon, second line, trailing tag and chevron. Used in lists,
// dropdowns, Select and Search results.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tag.dart';
import 'sossoldi_tappable.dart';

class SossoldiMenuItem extends StatelessWidget {
  const SossoldiMenuItem({
    super.key,
    required this.label,
    this.subtitle,
    this.leading,
    this.tag,
    this.hasSubitems = false,
    this.showDivider = false,
    this.selected,
    this.onTap,
  });

  final String label;

  /// Second line, truncated to one line.
  final String? subtitle;

  /// 24px slot, usually an icon.
  final Widget? leading;

  /// Small label on the right (Figma "Tag", with stroke).
  final String? tag;

  /// Shows a chevron to signal a nested menu.
  final bool hasSubitems;
  final bool showDivider;
  final bool? selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.strokeMinus1))
            : null,
      ),
      child: Row(
        spacing: SossoldiSpacing.m,
        children: [
          Expanded(
            child: Row(
              spacing: SossoldiSpacing.s,
              children: [
                if (leading != null)
                  SizedBox.square(dimension: 24, child: Center(child: leading)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: typography.labelLarge.copyWith(
                          color: colors.textHigh,
                        ),
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
                if (tag != null) SossoldiTag(label: tag!, hasStroke: true),
              ],
            ),
          ),
          if (hasSubitems)
            SizedBox.square(
              dimension: 24,
              child: Icon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: colors.textHigh,
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return SossoldiTappable(onTap: onTap, selected: selected, child: row);
  }
}
