import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _icon = PhosphorIconsRegular.sticker;

class ChipUseCase extends StatelessWidget {
  const ChipUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Types',
          children: [
            for (final type in SossoldiChipType.values)
              SossoldiChip(
                label: type.name,
                type: type,
                iconLeft: _icon,
                iconRight: _icon,
              ),
          ],
        ),
        const FoundationSection(
          title: 'Without icons',
          children: [
            SossoldiChip(label: 'Chip text'),
            SossoldiChip(label: 'Chip text', type: SossoldiChipType.income),
          ],
        ),
      ],
    );
  }
}

class FilterChipUseCase extends StatelessWidget {
  const FilterChipUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Variants',
          children: [
            SossoldiFilterChip(
              name: 'Name',
              value: 'Text',
              onRemove: () {},
              removeSemanticLabel: 'Remove filter',
            ),
            SossoldiFilterChip(
              name: 'Name',
              value: 'Text',
              icon: _icon,
              onRemove: () {},
              removeSemanticLabel: 'Remove filter',
            ),
            const SossoldiFilterChip(value: 'Text only'),
          ],
        ),
      ],
    );
  }
}

class TagUseCase extends StatelessWidget {
  const TagUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        for (final stroke in [false, true])
          FoundationSection(
            title: stroke ? 'With stroke' : 'Without stroke',
            children: [
              for (final type in SossoldiTagType.values)
                SossoldiTag(
                  label: 'Your label',
                  type: type,
                  hasStroke: stroke,
                  iconLeft: _icon,
                ),
            ],
          ),
      ],
    );
  }
}
