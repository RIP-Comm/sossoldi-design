// Amount with currency. Every amount shown in the app goes through this
// widget: locale formatting, currency, positive/negative color and
// masking for the future Hidden Mode.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import 'sossoldi_amount_format.dart';

enum SossoldiAmountTone {
  /// Text color, no sign coloring (balances, totals).
  neutral,

  /// Income color when >= 0, expense color when < 0.
  signed,

  /// Primary color (transfers between accounts).
  transfer,
}

class SossoldiAmount extends StatelessWidget {
  const SossoldiAmount({
    super.key,
    required this.value,
    required this.currencyCode,
    this.tone = SossoldiAmountTone.neutral,
    this.style,
    this.showPlusSign = false,
    this.masked = false,
    this.textAlign,
  });

  final num value;

  /// ISO 4217 code, e.g. "EUR".
  final String currencyCode;
  final SossoldiAmountTone tone;

  /// Text style without color; defaults to Label/Large.
  final TextStyle? style;
  final bool showPlusSign;

  /// Hides the figure (Hidden Mode).
  final bool masked;
  final TextAlign? textAlign;

  static const _mask = '••••';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (tone) {
      SossoldiAmountTone.neutral => colors.textHigh,
      SossoldiAmountTone.transfer => colors.primary.text,
      SossoldiAmountTone.signed =>
        value < 0 ? colors.expense.text : colors.income.text,
    };
    final text = masked
        ? _mask
        : SossoldiAmountFormat.money(
            context,
            value,
            currencyCode: currencyCode,
            showPlusSign: showPlusSign,
          );
    return Text(
      text,
      maxLines: 1,
      textAlign: textAlign,
      style: (style ?? context.typography.labelLarge).copyWith(color: color),
    );
  }
}
