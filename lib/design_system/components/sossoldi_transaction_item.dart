// Transaction item, from Figma component "Transaction itemNew"
// (node 3:5670), types Income, Expense and Transfer.
// The Type=Button variant is SossoldiListAddButton.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_chip.dart';
import 'sossoldi_tappable.dart';

enum SossoldiTransactionType { income, expense, transfer }

class SossoldiTransactionItem extends StatelessWidget {
  const SossoldiTransactionItem({
    super.key,
    required this.type,
    required this.leading,
    required this.description,
    required this.account,
    required this.amount,
    required this.currencyCode,
    this.toAccount,
    this.recurrenceLabel,
    this.recurrenceChipType = SossoldiChipType.info,
    this.masked = false,
    this.compact = false,
    this.onTap,
  }) : assert(
         type != SossoldiTransactionType.transfer || toAccount != null,
         'Transfers need toAccount',
       );

  final SossoldiTransactionType type;

  /// 24px slot, usually the category icon.
  final Widget leading;
  final String description;

  /// Account name; for transfers, the source account.
  final String account;

  /// Destination account, transfers only.
  final String? toAccount;

  /// Absolute amount; the sign comes from [type].
  final num amount;
  final String currencyCode;

  /// Next occurrence of a recurring transaction (e.g. "31 May").
  final String? recurrenceLabel;

  /// Color of the [recurrenceLabel] chip: info for what is still to come,
  /// subtle for what already happened.
  final SossoldiChipType recurrenceChipType;
  final bool masked;

  /// Less vertical padding, so a row with a [recurrenceLabel] (taller, the chip
  /// is under the amount) is as tall as one without it. Used by the Dashboard.
  final bool compact;
  final VoidCallback? onTap;

  static double _lineHeight(TextStyle style) =>
      (style.fontSize ?? 14) * (style.height ?? 1.2);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final secondary = typography.labelMedium.copyWith(color: colors.textMed);

    final (num signed, SossoldiAmountTone tone) = switch (type) {
      SossoldiTransactionType.income => (
        amount.abs(),
        SossoldiAmountTone.signed,
      ),
      SossoldiTransactionType.expense => (
        -amount.abs(),
        SossoldiAmountTone.signed,
      ),
      SossoldiTransactionType.transfer => (
        amount.abs(),
        SossoldiAmountTone.transfer,
      ),
    };

    final row = Container(
      color: colors.surfaceHigh,
      padding: EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: compact ? SossoldiSpacing.xs : SossoldiSpacing.s,
      ),
      child: Row(
        spacing: SossoldiSpacing.s,
        children: [
          SizedBox.square(dimension: 24, child: Center(child: leading)),
          Expanded(
            child: ConstrainedBox(
              // The height of the two lines, so a row without description is
              // as tall as one with it.
              constraints: BoxConstraints(
                minHeight:
                    _lineHeight(typography.labelLarge) +
                    _lineHeight(typography.labelMedium),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Without a description the account alone is centered.
                  if (description.trim().isNotEmpty)
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.labelLarge.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                  if (type == SossoldiTransactionType.transfer)
                    Row(
                      spacing: SossoldiSpacing.xs,
                      children: [
                        Flexible(
                          child: Text(
                            account,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: secondary,
                          ),
                        ),
                        Icon(
                          PhosphorIconsRegular.arrowsLeftRight,
                          size: 16,
                          color: colors.primary.text,
                        ),
                        Flexible(
                          child: Text(
                            toAccount!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: secondary,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SossoldiSpacing.xs,
            children: [
              SossoldiAmount(
                value: signed,
                currencyCode: currencyCode,
                tone: tone,
                masked: masked,
              ),
              if (recurrenceLabel != null)
                SossoldiChip(label: recurrenceLabel!, type: recurrenceChipType),
            ],
          ),
        ],
      ),
    );

    return onTap == null ? row : SossoldiTappable(onTap: onTap, child: row);
  }
}
