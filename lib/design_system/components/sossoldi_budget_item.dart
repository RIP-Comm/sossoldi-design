// Budget row, from Figma component "Budget" (node 13:4284): the name, the
// percentage spent and what is left, and the bar. With [prominent] it is
// the "Overall budget" header (node 13:4750), with a larger title.
//
// Texts come ready from the caller (amounts are formatted there); the tone
// colors the figures: under the limit, close to it (from 80%) or over it.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_chip.dart';
import 'sossoldi_tappable.dart';

/// How the figures of a budget are colored. Not in Figma (it only shows the
/// first): warning and error use the state tokens.
enum SossoldiBudgetTone { ok, warning, exceeded }

class SossoldiBudgetItem extends StatelessWidget {
  const SossoldiBudgetItem({
    super.key,
    required this.title,
    required this.percent,
    required this.remaining,
    required this.bar,
    this.tone = SossoldiBudgetTone.ok,
    this.periodLabel,
    this.prominent = false,
    this.showDivider = false,
    this.card = false,
    this.onTap,
  });

  final String title;

  /// "50%".
  final String percent;

  /// "120 € left" or "35 € over".
  final String remaining;

  /// A [SossoldiBudgetBar] (or any bar).
  final Widget bar;
  final SossoldiBudgetTone tone;

  /// Subtle chip above the title (e.g. "Monthly").
  final String? periodLabel;

  /// Larger title: the "Overall budget" card.
  final bool prominent;
  final bool showDivider;

  /// A small rounded card for a horizontal list (Finance Overview): the
  /// period chip and the name, then the figures, then the bar. Give it a
  /// width.
  final bool card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final percentColor = switch (tone) {
      SossoldiBudgetTone.ok => colors.textHigh,
      SossoldiBudgetTone.warning => colors.warning.text,
      SossoldiBudgetTone.exceeded => colors.error.text,
    };
    final asChip = tone == SossoldiBudgetTone.exceeded && !prominent;
    final remainingColor = tone == SossoldiBudgetTone.exceeded
        ? colors.error.text
        : colors.textMed;
    if (card) {
      final figures = tone == SossoldiBudgetTone.exceeded
          ? Row(
              spacing: SossoldiSpacing.xs,
              children: [
                SossoldiChip(label: percent, type: SossoldiChipType.error),
                Flexible(
                  child: Text(
                    remaining,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.labelMedium.copyWith(
                      color: remainingColor,
                    ),
                  ),
                ),
              ],
            )
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: percent,
                    style: typography.labelBoldLarge.copyWith(
                      color: percentColor,
                    ),
                  ),
                  TextSpan(
                    text: ' $remaining',
                    style: typography.labelMedium.copyWith(
                      color: remainingColor,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
      final body = Container(
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
          mainAxisSize: MainAxisSize.min,
          spacing: SossoldiSpacing.s,
          children: [
            // The period chip sits 4px above the name.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.xs,
              children: [
                if (periodLabel != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SossoldiChip(
                      label: periodLabel!,
                      type: SossoldiChipType.subtle,
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
            figures,
            bar,
          ],
        ),
      );
      return onTap == null ? body : SossoldiTappable(onTap: onTap, child: body);
    }
    final row = Container(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.strokeMinus1))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.xs,
        children: [
          if (periodLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: SossoldiChip(
                label: periodLabel!,
                type: SossoldiChipType.subtle,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  spacing: SossoldiSpacing.s,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (prominent
                                    ? typography.titleLarge
                                    : typography.labelLarge)
                                .copyWith(color: colors.textHigh),
                      ),
                    ),
                    // The figures keep their room; a very long amount is cut
                    // before it pushes the title out of the row.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.65,
                      ),
                      child: asChip
                          // Over the limit (not the overall one): the
                          // percentage goes in an error chip.
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: SossoldiSpacing.xs,
                              children: [
                                SossoldiChip(
                                  label: percent,
                                  type: SossoldiChipType.error,
                                ),
                                Flexible(
                                  child: Text(
                                    remaining,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: typography.labelMedium.copyWith(
                                      color: remainingColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: percent,
                                    style: typography.labelBoldLarge.copyWith(
                                      color: percentColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' $remaining',
                                    style: typography.labelMedium.copyWith(
                                      color: remainingColor,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ),
              bar,
            ],
          ),
        ],
      ),
    );
    return onTap == null ? row : SossoldiTappable(onTap: onTap, child: row);
  }
}
