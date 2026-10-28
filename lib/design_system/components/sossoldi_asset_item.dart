// Asset row, from Figma component "Asset" (node 3:4456),
// types Default (with trend chart) and Onboarding - Detailed (with value
// and position details). The Type=Button variant is SossoldiListAddButton.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_amount.dart';
import 'sossoldi_right_chart.dart';
import 'sossoldi_tappable.dart';

class SossoldiAssetItem extends StatelessWidget {
  /// Default: trend chart on the right, when [chart] is given.
  const SossoldiAssetItem({
    super.key,
    required this.name,
    required this.typeLabel,
    required this.identifier,
    this.chart,
    this.onTap,
  }) : value = null,
       currencyCode = null,
       details = const [];

  /// Onboarding - Detailed: total value and details (quantity, average
  /// cost, ...) on the right.
  const SossoldiAssetItem.detailed({
    super.key,
    required this.name,
    required this.typeLabel,
    required this.identifier,
    required num this.value,
    required String this.currencyCode,
    required this.details,
    this.onTap,
  }) : chart = null;

  final String name;

  /// Asset class, e.g. "ETF". Shown uppercase.
  final String typeLabel;

  /// Ticker and/or ISIN, e.g. "VWCE - IE00BK5BQT80"; empty for an asset
  /// that has neither (a manual one): the line is left out.
  final String identifier;
  final SossoldiRightChart? chart;
  final num? value;
  final String? currencyCode;

  /// Label/value pairs, already formatted (use SossoldiAmountFormat).
  final List<(String label, String value)> details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final detailed = value != null;

    final info = Row(
      spacing: SossoldiSpacing.s,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.shapeMed,
            shape: BoxShape.circle,
          ),
          child: Text(
            name.isEmpty ? '' : name.characters.first.toUpperCase(),
            style: typography.headlineSmall.copyWith(
              color: colors.primary.onSurface,
            ),
          ),
        ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelUppercaseLarge.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                  if (identifier.isNotEmpty)
                    Text(
                      identifier.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.labelUppercaseMedium.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    Widget? right;
    if (detailed) {
      final detailStyle = typography.labelMedium.copyWith(
        color: colors.textMed,
      );
      right = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SossoldiAmount(
            value: value!,
            currencyCode: currencyCode!,
            style: typography.labelBoldLarge,
          ),
          for (final (label, val) in details)
            Padding(
              padding: const EdgeInsets.only(top: SossoldiSpacing.xs),
              child: Text('$label $val', style: detailStyle),
            ),
        ],
      );
    } else if (chart != null) {
      right = chart;
    }

    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
        ),
      ),
      child: Row(
        crossAxisAlignment: detailed
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        spacing: SossoldiSpacing.m,
        children: [
          Expanded(child: info),
          ?right,
        ],
      ),
    );
    return onTap == null ? row : SossoldiTappable(onTap: onTap, child: row);
  }
}
