// Insight of the moment widget, size S only. No Figma node: the card of the
// other Dashboard widgets with a round icon in the color of the tone, a short
// title (2 lines) and, anchored to the bottom, the detail built from the
// components of the widgets that show the same thing (see InsightTexts).
// Presentation only: InsightWidget wires it to the engine.
//
// What does not fit is scaled down so it never leaves the height of the card.

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../insights/insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    this.bottom,
    this.attachedDetail,
    this.onTap,
  });

  final InsightTone tone;
  final IconData icon;
  final String title;

  /// The detail, anchored to the bottom.
  final Widget? bottom;

  /// A detail right under the title (up to two lines), for the neutral state.
  final String? attachedDetail;

  /// Tap on the card; null when there is nothing to open (or in edit mode).
  final VoidCallback? onTap;

  static const double _iconBox = 36;

  ({Color background, Color foreground}) _colors(BuildContext context) {
    final colors = context.colors;
    return switch (tone) {
      InsightTone.negative => (
        background: colors.error.surface,
        foreground: colors.error.text,
      ),
      InsightTone.attention => (
        background: colors.warning.surface,
        foreground: colors.warning.text,
      ),
      InsightTone.positive => (
        background: colors.success.surface,
        foreground: colors.success.text,
      ),
      InsightTone.neutral => (
        background: colors.surfaceMed,
        foreground: colors.textMed,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tint = _colors(context);

    return SossoldiWidgetCard(
      child: Semantics(
        container: true,
        button: onTap != null,
        label: title,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(SossoldiSpacing.m),
            child: LayoutBuilder(
              builder: (context, constraints) {
                Widget fit(Alignment alignment, Widget child) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: alignment,
                  child: SizedBox(width: constraints.maxWidth, child: child),
                );
                final top = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: SossoldiSpacing.xs,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: _iconBox,
                        height: _iconBox,
                        decoration: BoxDecoration(
                          color: tint.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 20, color: tint.foreground),
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.labelBoldLarge.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                    if (attachedDetail != null)
                      Text(
                        attachedDetail!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography.labelLarge.copyWith(
                          color: colors.textMed,
                        ),
                      ),
                  ],
                );
                // The detail takes its own height at the bottom; the top gets
                // all the rest (and shrinks only when it does not fit).
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: fit(Alignment.topLeft, top),
                      ),
                    ),
                    if (bottom != null) ...[
                      const SizedBox(height: SossoldiSpacing.xs),
                      fit(Alignment.bottomLeft, bottom!),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
