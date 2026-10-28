import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

/// The two sliders of the color picker, a live preview, and the colors they
/// give for 12 hues at both ends of the saturation slider, in light and dark.
class ColorPickerUseCase extends StatefulWidget {
  const ColorPickerUseCase({super.key});

  @override
  State<ColorPickerUseCase> createState() => _ColorPickerUseCaseState();
}

class _ColorPickerUseCaseState extends State<ColorPickerUseCase> {
  CategoryColor _color = CategoryColors.all.first;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Picker (the first color of the palette to start with)',
          children: [
            SizedBox(
              width: 358,
              child: Column(
                spacing: SossoldiSpacing.xl,
                children: [
                  _Preview(color: _color, size: 64),
                  SossoldiColorPicker(
                    color: _color.main,
                    hueSemanticLabel: 'Hue',
                    saturationSemanticLabel: 'Saturation',
                    onChanged: (c) =>
                        setState(() => _color = CategoryColor.fromColor(c)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const _Extremes(
          title: 'Light: 12 hues, top = most saturated',
          dark: false,
        ),
        const _Extremes(
          title: 'Dark: 12 hues, top = most saturated',
          dark: true,
        ),
      ],
    );
  }
}

/// The preview of "Icon and color": the tint behind the icon in the color.
class _Preview extends StatelessWidget {
  const _Preview({required this.color, required this.size});

  final CategoryColor color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.tintFor(Theme.of(context).brightness),
        border: Border.all(color: context.colors.strokeDefault),
      ),
      child: Icon(PhosphorIconsRegular.bank, size: size / 2, color: color.main),
    );
  }
}

class _Extremes extends StatelessWidget {
  const _Extremes({required this.title, required this.dark});

  final String title;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = dark ? SossoldiTheme.dark : SossoldiTheme.light;
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.only(bottom: SossoldiSpacing.xl),
          padding: const EdgeInsets.all(SossoldiSpacing.l),
          decoration: ShapeDecoration(
            color: context.colors.surfaceMed,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(SossoldiRadius.m),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SossoldiSpacing.m,
            children: [
              Text(
                title,
                style: context.typography.titleMedium.copyWith(
                  color: context.colors.textHigh,
                ),
              ),
              Wrap(
                spacing: SossoldiSpacing.m,
                runSpacing: SossoldiSpacing.m,
                children: [
                  for (var i = 0; i < 12; i++)
                    Column(
                      spacing: SossoldiSpacing.s,
                      children: [
                        _Preview(
                          size: 48,
                          color: CategoryColor.fromColor(
                            CategoryColorSpace.colorAt(i / 11, 1),
                          ),
                        ),
                        _Preview(
                          size: 48,
                          color: CategoryColor.fromColor(
                            CategoryColorSpace.colorAt(i / 11, 0),
                          ),
                        ),
                        Text(
                          '${CategoryColorSpace.hueAt(i / 11).round()}°',
                          style: context.typography.captionSmall.copyWith(
                            color: context.colors.textMed,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The grid of icons, alone and in its bottom sheet.
class IconPickerUseCase extends StatefulWidget {
  const IconPickerUseCase({super.key});

  @override
  State<IconPickerUseCase> createState() => _IconPickerUseCaseState();
}

class _IconPickerUseCaseState extends State<IconPickerUseCase> {
  IconData _icon = PhosphorIconsRegular.bank;
  final CategoryColor _color = CategoryColors.all[25];

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title:
              'Tabs by group, grid of the group (${CategoryIcons.all.length} icons in all)',
          children: [
            SizedBox(
              width: 358,
              height: 520,
              child: SossoldiIconPicker(
                selected: _icon,
                color: _color,
                onSelected: (i) => setState(() => _icon = i),
                groupLabel: (id) => id.name,
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'In a bottom sheet',
          children: [
            SossoldiButton(
              label: 'Choose an icon',
              onPressed: () async {
                final icon = await showSossoldiIconPicker(
                  context: context,
                  title: 'Choose an icon',
                  closeSemanticLabel: 'Close',
                  selected: _icon,
                  color: _color,
                  groupLabel: (id) => id.name,
                );
                if (icon != null) setState(() => _icon = icon);
              },
            ),
          ],
        ),
      ],
    );
  }
}
