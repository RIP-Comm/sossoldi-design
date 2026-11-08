// Account row, from Figma component "Account" (node 3:4430),
// types Default and Stroke. The Type=Button variant is SossoldiListAddButton.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_change_tag.dart';
import 'sossoldi_tappable.dart';

class SossoldiAccountItem extends StatelessWidget {
  const SossoldiAccountItem({
    super.key,
    required this.name,
    required this.balance,
    required this.currencyCode,
    this.leading,
    this.tag,
    this.variation,
    this.hasStroke = false,
    this.masked = false,
    this.hasChevron = false,
    this.onTap,
  });

  final String name;
  final num balance;
  final String currencyCode;

  /// 24px slot, usually the account icon.
  final Widget? leading;

  /// A small tag after the name (e.g. "Main").
  final Widget? tag;

  /// Change of the balance in the selected period, in [currencyCode].
  final num? variation;

  /// Bottom divider, for stacked rows (Figma Type=Stroke).
  final bool hasStroke;
  final bool masked;

  /// A chevron on the right: the row opens a page (the account's page).
  final bool hasChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: hasStroke
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
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.labelLarge.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                ),
                ?tag,
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SossoldiSpacing.xs,
            children: [
              SossoldiAmount(
                value: balance,
                currencyCode: currencyCode,
                masked: masked,
                style: context.typography.labelBoldLarge,
              ),
              if (variation != null && !masked)
                SossoldiChangeTag.money(
                  value: variation!,
                  currencyCode: currencyCode,
                ),
            ],
          ),
          if (hasChevron)
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
    return onTap == null ? row : SossoldiTappable(onTap: onTap, child: row);
  }
}
