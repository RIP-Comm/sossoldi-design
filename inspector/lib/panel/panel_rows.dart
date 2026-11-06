// Building blocks of the panel: sections, label-value rows, color rows with
// their tokens, the W/H/X/Y grid and the padding box.

import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../catalog/tokens.dart';

class PanelSection extends StatelessWidget {
  const PanelSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SossoldiSpacing.l),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.strokeMinus1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.s,
        children: [
          Text(
            title.toUpperCase(),
            style: context.typography.labelUppercaseBoldSmall.copyWith(
              color: colors.textLow,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// A variable of the design system (a color, a spacing, a text style...): a
/// blue informative chip next to the value it stands for.
class TokenChip extends StatelessWidget {
  const TokenChip(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) =>
      SossoldiTag(label: name, type: SossoldiTagType.info);
}

/// A label on the left; on the right the value as it is and, when it comes
/// from the design system, the variables it matches in blue chips.
class PanelRow extends StatelessWidget {
  const PanelRow({
    super.key,
    required this.label,
    this.value,
    this.tokens = const [],
    this.leading,
  });

  final String label;
  final String? value;

  /// The design system variables of [value].
  final List<String> tokens;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SossoldiSpacing.s,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: typography.labelMedium.copyWith(color: colors.textMed),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: SossoldiSpacing.s,
            runSpacing: SossoldiSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ?leading,
              if (value != null)
                Text(
                  value!,
                  style: typography.labelBoldMedium.copyWith(
                    color: colors.textHigh,
                  ),
                ),
              for (final token in tokens) TokenChip(token),
            ],
          ),
        ),
      ],
    );
  }
}

/// A color: swatch, its value and, when it is one, its variables.
class ColorRow extends StatelessWidget {
  const ColorRow({super.key, required this.label, required this.info});

  final String label;
  final ColorInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final opacity = info.opacityPercent;
    return PanelRow(
      label: label,
      leading: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: info.color,
          borderRadius: BorderRadius.circular(SossoldiRadius.xs),
          border: Border.all(color: colors.strokeDefault),
        ),
      ),
      value: '${info.hex}${opacity != null ? ' · $opacity%' : ''}',
      tokens: info.semantic.isNotEmpty ? info.semantic : [?info.primitive],
    );
  }
}

/// Two columns of label-value cells (W, H, X, Y).
class PanelGrid extends StatelessWidget {
  const PanelGrid({super.key, required this.cells});

  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    Widget cell((String, String) c) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SossoldiSpacing.s,
          vertical: SossoldiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceMed,
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
        ),
        child: Row(
          spacing: SossoldiSpacing.s,
          children: [
            Text(
              c.$1,
              style: typography.labelMedium.copyWith(color: colors.textLow),
            ),
            Text(
              c.$2,
              style: typography.labelBoldMedium.copyWith(
                color: colors.textHigh,
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      spacing: SossoldiSpacing.s,
      children: [
        for (var i = 0; i < cells.length; i += 2)
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              cell(cells[i]),
              if (i + 1 < cells.length) cell(cells[i + 1]) else const Spacer(),
            ],
          ),
      ],
    );
  }
}

/// The four sides of a padding around a box, each with its spacing token.
class InsetsBox extends StatelessWidget {
  const InsetsBox({super.key, required this.insets});

  final EdgeInsets insets;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    Widget value(double v) {
      final token = spacingToken(v);
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          Text(
            px(v),
            style: typography.labelBoldSmall.copyWith(color: colors.textHigh),
          ),
          if (token != null) TokenChip(token),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: BoxDecoration(
        color: colors.success.surface,
        borderRadius: BorderRadius.circular(SossoldiRadius.s),
      ),
      child: Column(
        spacing: SossoldiSpacing.xs,
        children: [
          value(insets.top),
          Row(
            children: [
              value(insets.left),
              Expanded(
                child: Container(
                  height: 32,
                  margin: const EdgeInsets.symmetric(
                    horizontal: SossoldiSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceHigh,
                    borderRadius: BorderRadius.circular(SossoldiRadius.xs),
                    border: Border.all(color: colors.strokeDefault),
                  ),
                ),
              ),
              value(insets.right),
            ],
          ),
          value(insets.bottom),
        ],
      ),
    );
  }
}
