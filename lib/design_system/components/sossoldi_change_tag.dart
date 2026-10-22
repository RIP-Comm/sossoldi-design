// Change indicator: a positive/negative Tag showing a variation as money
// ("+147,45 €") or percentage ("+0,85%"). Built on the Figma "Tag"
// (Type=Positive/Negative), as used in Account and Right chart.

import 'package:flutter/material.dart';

import 'sossoldi_amount_format.dart';
import 'sossoldi_tag.dart';

class SossoldiChangeTag extends StatelessWidget {
  /// Variation in money.
  const SossoldiChangeTag.money({
    super.key,
    required this.value,
    required String this.currencyCode,
  });

  /// Variation as a fraction (0.0123 = +1,23%).
  const SossoldiChangeTag.percent({super.key, required this.value})
    : currencyCode = null;

  final num value;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final label = currencyCode == null
        ? SossoldiAmountFormat.percent(context, value)
        : SossoldiAmountFormat.money(
            context,
            value,
            currencyCode: currencyCode!,
            showPlusSign: true,
          );
    return SossoldiTag(
      label: label,
      type: value < 0 ? SossoldiTagType.negative : SossoldiTagType.positive,
    );
  }
}
