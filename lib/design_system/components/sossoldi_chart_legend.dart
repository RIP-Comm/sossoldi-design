// Chart legend, from Figma "Legend" (node 13:4636): a wrapping list of a
// 10px colored square, the name and, optionally, the amount.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

class SossoldiLegendItem {
  const SossoldiLegendItem({
    required this.color,
    required this.label,
    this.value,
  });

  final Color color;
  final String label;

  /// Shown after the name, in the strong text color.
  final String? value;
}

class SossoldiChartLegend extends StatelessWidget {
  const SossoldiChartLegend({super.key, required this.items});

  final List<SossoldiLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Same size as the amounts in the chart's indicator.
    final style = context.typography.labelSmall;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // A long name gives way instead of overflowing the row.
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.label,
                        style: style.copyWith(color: colors.textMed),
                      ),
                      if (item.value != null)
                        TextSpan(
                          text: ' ${item.value}',
                          style: style.copyWith(color: colors.textHigh),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
