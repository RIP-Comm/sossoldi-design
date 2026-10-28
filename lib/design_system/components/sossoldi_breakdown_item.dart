// Row of the portfolio breakdown, from the Figma "Division" of Positions
// (node 13:4948): the name, the percentage in bold with the amount next to
// it, and a thin bar (4px) in the color of the row over a lighter track.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';

class SossoldiBreakdownItem extends StatelessWidget {
  const SossoldiBreakdownItem({
    super.key,
    required this.name,
    required this.share,
    required this.value,
    required this.currencyCode,
    required this.color,
    required this.trackColor,
    required this.percentText,
    this.masked = false,
  });

  final String name;

  /// 0 to 1: how much of the bar is filled.
  final double share;
  final num value;
  final String currencyCode;
  final Color color;
  final Color trackColor;

  /// The percentage, already formatted ("50%").
  final String percentText;

  /// Hides the amount; the bar stays.
  final bool masked;

  static const double barHeight = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final fill = share.isNaN ? 0.0 : share.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.s,
        children: [
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.labelLarge.copyWith(color: colors.textHigh),
                ),
              ),
              Text(
                percentText,
                style: typography.labelBoldLarge.copyWith(
                  color: colors.textHigh,
                ),
              ),
              SossoldiAmount(
                value: value,
                currencyCode: currencyCode,
                masked: masked,
                style: typography.labelMedium.copyWith(),
                tone: SossoldiAmountTone.neutral,
              ),
            ],
          ),
          ClipRSuperellipse(
            borderRadius: BorderRadius.circular(SossoldiRadius.max),
            child: SizedBox(
              height: barHeight,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: trackColor)),
                  FractionallySizedBox(
                    widthFactor: fill,
                    heightFactor: 1,
                    alignment: Alignment.centerLeft,
                    child: ColoredBox(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
