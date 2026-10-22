import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'foundation_page.dart';

class CategoryColorsUseCase extends StatelessWidget {
  const CategoryColorsUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Category colors (main + tint)',
          children: [
            for (final (i, pair) in CategoryColors.all.indexed)
              _PairTile(
                index: i,
                main: pair.main,
                tint: pair.tintFor(brightness),
              ),
          ],
        ),
      ],
    );
  }
}

class _PairTile extends StatelessWidget {
  const _PairTile({
    required this.index,
    required this.main,
    required this.tint,
  });

  final int index;
  final Color main;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiRadius.s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: main),
              const SizedBox(width: SossoldiSpacing.s),
              CircleAvatar(radius: 12, backgroundColor: tint),
              const Spacer(),
              Text(
                '#${index + 1}',
                style: context.typography.captionSmall.copyWith(
                  color: context.colors.textMed,
                ),
              ),
            ],
          ),
          const SizedBox(height: SossoldiSpacing.s),
          // Example usage: budget bar with tint track and main fill.
          ClipRRect(
            borderRadius: BorderRadius.circular(SossoldiRadius.max),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 4,
              color: main,
              backgroundColor: tint,
            ),
          ),
        ],
      ),
    );
  }
}
