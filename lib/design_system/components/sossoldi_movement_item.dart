// Movement row of Investments, from the Figma rows of Movements (node
// 13:4987): the type as a chip with an icon, the name of the asset and its
// "ticker – ISIN", the amount and, under it, the details (units and price of
// a buy or a sell, the description of a dividend or a cost). The amount of a
// buy or a sell is neutral (green or red would read as a gain or a loss), a
// dividend is green and a cost red.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_chip.dart';
import 'sossoldi_tappable.dart';

/// How the amount and the chip of a movement are colored.
enum SossoldiMovementTone { neutral, income, expense }

class SossoldiMovementItem extends StatelessWidget {
  const SossoldiMovementItem({
    super.key,
    required this.typeLabel,
    required this.typeIcon,
    required this.amount,
    required this.currencyCode,
    this.tone = SossoldiMovementTone.neutral,
    this.title,
    this.subtitle,
    this.details,
    this.masked = false,
    this.onTap,
  });

  /// "Buy", "Dividend"...
  final String typeLabel;
  final IconData typeIcon;

  /// Signed: a cost is negative.
  final num amount;
  final String currencyCode;
  final SossoldiMovementTone tone;

  /// Name of the asset (a cost with no asset: its description).
  final String? title;

  /// "VWCE – IE00BK5BQT80".
  final String? subtitle;

  /// Units and price, or the description.
  final String? details;
  final bool masked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final chipType = switch (tone) {
      SossoldiMovementTone.neutral => SossoldiChipType.standard,
      SossoldiMovementTone.income => SossoldiChipType.income,
      SossoldiMovementTone.expense => SossoldiChipType.expense,
    };
    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      color: colors.surfaceHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: SossoldiSpacing.m,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SossoldiSpacing.xs,
              children: [
                SossoldiChip(
                  label: typeLabel,
                  iconLeft: typeIcon,
                  type: chipType,
                ),
                if (title != null)
                  Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelLarge.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelMedium.copyWith(
                      color: colors.textMed,
                    ),
                  ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: SossoldiSpacing.xs,
              children: [
                SossoldiAmount(
                  value: amount,
                  currencyCode: currencyCode,
                  masked: masked,
                  showPlusSign: tone == SossoldiMovementTone.income,
                  tone: tone == SossoldiMovementTone.neutral
                      ? SossoldiAmountTone.neutral
                      : SossoldiAmountTone.signed,
                  style: typography.labelBoldLarge,
                ),
                if (details != null)
                  Text(
                    masked ? '' : details!,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelMedium.copyWith(
                      color: colors.textMed,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return onTap == null ? row : SossoldiTappable(onTap: onTap, child: row);
  }
}
