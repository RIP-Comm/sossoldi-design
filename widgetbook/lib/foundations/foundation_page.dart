import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

/// Scrollable page on the theme background, shared by foundation use cases.
class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surfaceLow,
      child: ListView(
        padding: const EdgeInsets.all(SossoldiSpacing.xl),
        children: children,
      ),
    );
  }
}

class FoundationSection extends StatelessWidget {
  const FoundationSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SossoldiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.titleMedium.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          const SizedBox(height: SossoldiSpacing.s),
          Wrap(
            spacing: SossoldiSpacing.s,
            runSpacing: SossoldiSpacing.s,
            children: children,
          ),
        ],
      ),
    );
  }
}

/// A color chip with its name and hex value.
class ColorSwatchTile extends StatelessWidget {
  const ColorSwatchTile({super.key, required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex = color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    return Container(
      width: 152,
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: ShapeDecoration(
        color: context.colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
          side: BorderSide(color: context.colors.strokeMinus1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: ShapeDecoration(
              color: color,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.xs),
                side: BorderSide(color: context.colors.strokeDefault),
              ),
            ),
          ),
          const SizedBox(height: SossoldiSpacing.xs),
          Text(
            name,
            style: context.typography.labelBoldSmall.copyWith(
              color: context.colors.textHigh,
            ),
          ),
          Text(
            '#$hex',
            style: context.typography.captionSmall.copyWith(
              color: context.colors.textMed,
            ),
          ),
        ],
      ),
    );
  }
}
