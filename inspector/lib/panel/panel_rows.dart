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

/// A label on the left, the value and its token on the right.
class PanelRow extends StatelessWidget {
  const PanelRow({
    super.key,
    required this.label,
    required this.value,
    this.token,
    this.leading,
    this.highlight = false,
  });

  final String label;
  final String value;

  /// The design system token of [value], shown as a tag.
  final String? token;
  final Widget? leading;

  /// Shows [value] itself as a token.
  final bool highlight;

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
              Text(
                value,
                style: typography.labelBoldMedium.copyWith(
                  color: highlight ? colors.primary.text : colors.textHigh,
                ),
              ),
              if (token != null)
                SossoldiTag(label: token!, type: SossoldiTagType.positive),
            ],
          ),
        ),
      ],
    );
  }
}

/// A color: swatch, semantic tokens (or the primitive) and the hex value.
class ColorRow extends StatelessWidget {
  const ColorRow({super.key, required this.label, required this.info});

  final String label;
  final ColorInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final names = info.semantic.isNotEmpty
        ? info.semantic.join(' · ')
        : info.primitive;
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
      value: names ?? info.hex,
      highlight: names != null,
      token: names != null
          ? '${info.hex}${opacity != null ? ' · $opacity%' : ''}'
          : null,
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
      return Text(
        token == null ? px(v) : '${px(v)} · $token',
        style: typography.labelBoldSmall.copyWith(
          color: token == null ? colors.textHigh : colors.success.text,
        ),
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
