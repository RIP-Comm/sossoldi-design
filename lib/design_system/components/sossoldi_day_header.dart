// Day header of a grouped transaction list, from Figma "Day > Title"
// (node 13:4572): the date on the left, the day's net as a green or red
// chip on the right.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_chip.dart';

class SossoldiDayHeader extends StatelessWidget {
  const SossoldiDayHeader({
    super.key,
    required this.title,
    this.total,
    this.positive = true,
  });

  final String title;

  /// The day's balance, already formatted. Null hides the chip.
  final String? total;

  /// Green chip when true, red when false.
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: SossoldiSpacing.s,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.labelLarge.copyWith(
              color: context.colors.textMed,
            ),
          ),
        ),
        if (total != null)
          SossoldiChip(
            label: total!,
            type: positive ? SossoldiChipType.income : SossoldiChipType.expense,
          ),
      ],
    );
  }
}
