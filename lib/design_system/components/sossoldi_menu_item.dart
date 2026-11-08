// Menu item, from Figma component "Menu item" (node 3:4108): a row with
// optional icon, second line, trailing tag and chevron. Used in lists,
// dropdowns, Select and Search results.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
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
    this.trailing,
    this.selected,
    this.onTap,
    this.enabled = true,
    this.dense = false,
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

  /// Control on the right (e.g. a switch). Replaces the chevron.
  final Widget? trailing;

  /// The selected option of a list, dropdown or select: tinted, with a check
  /// on the right (unless there is a [trailing] control). Null or false: a
  /// normal item.
  final bool? selected;
  final VoidCallback? onTap;

  /// A disabled item is dimmed and ignores taps.
  final bool enabled;

  /// Compact row (36 high, smaller label) for long navigation lists. Not in
  /// Figma: added for the Inspector's menu of screens.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final row = Container(
      constraints: BoxConstraints(minHeight: dense ? 36 : 48),
      padding: dense
          ? const EdgeInsets.symmetric(
              horizontal: SossoldiSpacing.s,
              vertical: SossoldiSpacing.xs,
            )
          : const EdgeInsets.all(SossoldiSpacing.s),
      decoration: ShapeDecoration(
        // The selected option: a primary tint and a check on the right.
        color: selected == true
            ? colors.selectedPrimarySurface
            : colors.surfaceHigh,
        shape: selected == true
            ? RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.s),
              )
            : const RoundedRectangleBorder(),
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
                        style:
                            (dense
                                    ? typography.labelMedium
                                    : typography.labelLarge)
                                .copyWith(
                                  color: enabled
                                      ? colors.textHigh
                                      : colors.textLow,
                                ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.labelLarge.copyWith(
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
          if (trailing != null)
            trailing!
          else if (selected == true)
            SizedBox.square(
              dimension: 24,
              child: Icon(
                PhosphorIconsRegular.check,
                size: dense ? 16 : 20,
                color: colors.primary.text,
              ),
            )
          else if (hasSubitems)
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
    return SossoldiTappable(
      onTap: enabled ? onTap : null,
      selected: selected,
      child: row,
    );
  }
}
