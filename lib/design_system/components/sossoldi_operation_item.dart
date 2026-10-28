// Operation row of a position (buy, sell, dividend), in the style of the
// Figma "Movement" and "Buy and sell" rows (nodes 13:5065, 13:5086): the
// type as a small tag, the description, the amount and, under it, the units
// and the price. Colors only where they mean something: a dividend is money
// coming in; buys and sells are not good or bad news, so they stay neutral.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';

class SossoldiOperationItem extends StatelessWidget {
  const SossoldiOperationItem({
    super.key,
    required this.typeLabel,
    required this.title,
    required this.amount,
    required this.currencyCode,
    this.details,
    this.positive = false,
    this.masked = false,
  });

  /// "Buy", "Sell", "Dividend"; shown uppercase in a tag.
  final String typeLabel;
  final String title;

  /// Positive; the sign is not shown (the tag says what it is).
  final num amount;
  final String currencyCode;

  /// Under the amount, e.g. "12 × 36,31 €".
  final String? details;

  /// Money coming in: the amount is shown in the positive color.
  final bool positive;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SossoldiSpacing.xs,
                    vertical: SossoldiSpacing.xs / 2,
                  ),
                  decoration: ShapeDecoration(
                    color: colors.surfaceHigh,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(SossoldiRadius.xs),
                      side: BorderSide(color: colors.strokeDefault, width: 0.5),
                    ),
                  ),
                  child: Text(
                    typeLabel.toUpperCase(),
                    style: typography.labelUppercaseSmall.copyWith(
                      color: colors.textMed,
                    ),
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.labelLarge.copyWith(color: colors.textHigh),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SossoldiSpacing.xs,
            children: [
              SossoldiAmount(
                value: amount,
                currencyCode: currencyCode,
                masked: masked,
                showPlusSign: positive,
                tone: positive
                    ? SossoldiAmountTone.signed
                    : SossoldiAmountTone.neutral,
                style: typography.labelBoldLarge,
              ),
              if (details != null)
                Text(
                  masked ? '' : details!,
                  style: typography.labelMedium.copyWith(color: colors.textMed),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
