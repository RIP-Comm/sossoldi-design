// Portfolio value card, from Figma "Main KPI" (node 13:5053): the value of
// the portfolio, its total P&L as a percentage chip and an amount, and the
// available liquidity. Used by the Investments Overview and Positions.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_change_tag.dart';

class SossoldiPortfolioCard extends StatelessWidget {
  const SossoldiPortfolioCard({
    super.key,
    required this.label,
    required this.value,
    required this.gain,
    required this.gainPercent,
    required this.currencyCode,
    required this.liquidityLabel,
    required this.liquidity,
    this.masked = false,
  });

  /// "Portfolio value".
  final String label;

  /// Positions plus liquidity.
  final num value;

  /// Total unrealized profit or loss, in [currencyCode].
  final num gain;

  /// The same as a fraction of the cost (0.12 = +12%).
  final num gainPercent;
  final String currencyCode;

  /// "Available liquidity".
  final String liquidityLabel;
  final num liquidity;

  /// Hides the amounts (Hidden Mode); the percentage and the colors stay
  /// apart from the figures.
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
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: typography.labelMedium.copyWith(color: colors.textMed),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SossoldiAmount(
                    value: value,
                    currencyCode: currencyCode,
                    masked: masked,
                    style: typography.labelBoldXLarge,
                  ),
                ),
              ),
              SossoldiChangeTag.percent(value: gainPercent),
              SossoldiAmount(
                value: gain,
                currencyCode: currencyCode,
                masked: masked,
                showPlusSign: true,
                tone: SossoldiAmountTone.signed,
              ),
            ],
          ),
          const SizedBox(height: SossoldiSpacing.s),
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: Text(
                  liquidityLabel,
                  style: typography.labelMedium.copyWith(color: colors.textMed),
                ),
              ),
              SossoldiAmount(
                value: liquidity,
                currencyCode: currencyCode,
                masked: masked,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
