// Change of a value over a period, for the Dashboard widgets (Net worth,
// Investments). Not in Figma: built from the tag and the amount tokens.
//
// A tag with an arrow (up or down) and the percentage, colored as positive or
// negative, and the amount in plain text beside it. Without a percentage (the
// base was zero) the tag shows the amount and the plain text goes away.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount_format.dart';
import 'sossoldi_tag.dart';

class SossoldiChangeIndicator extends StatelessWidget {
  const SossoldiChangeIndicator({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.percent,
    this.masked = false,
  });

  /// Change in money (negative: down).
  final double amount;
  final String currencyCode;

  /// Change as a fraction (0.0123 = +1,23%); null when it cannot be worked
  /// out (zero base).
  final double? percent;

  /// Hides the figures (Hidden Mode); the arrow and the color stay.
  final bool masked;

  static const _mask = '••••';

  @override
  Widget build(BuildContext context) {
    // The sign comes from the percentage when there is one.
    final sign = percent ?? amount;
    final (type, icon) = sign < 0
        ? (SossoldiTagType.negative, PhosphorIconsBold.arrowDown)
        : sign > 0
        ? (SossoldiTagType.positive, PhosphorIconsBold.arrowUp)
        : (SossoldiTagType.standard, PhosphorIconsBold.minus);
    final money = masked
        ? _mask
        : SossoldiAmountFormat.money(
            context,
            amount,
            currencyCode: currencyCode,
            showPlusSign: true,
          );
    final tagLabel = percent == null
        ? money
        : masked
        ? _mask
        : SossoldiAmountFormat.percent(context, percent!, showPlusSign: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiTag(label: tagLabel, type: type, iconLeft: icon),
        if (percent != null)
          Flexible(
            child: Text(
              money,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.labelMedium.copyWith(
                color: context.colors.textMed,
              ),
            ),
          ),
      ],
    );
  }
}
