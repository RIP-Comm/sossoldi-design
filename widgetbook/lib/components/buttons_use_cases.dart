import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _icon = PhosphorIconsRegular.sticker;

class ButtonUseCase extends StatelessWidget {
  const ButtonUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        for (final type in SossoldiButtonType.values)
          FoundationSection(
            title: 'Type: ${type.name}',
            children: [
              for (final size in SossoldiButtonSize.values) ...[
                SossoldiButton(
                  label: 'Button text',
                  size: size,
                  type: type,
                  iconLeft: _icon,
                  iconRight: _icon,
                  onPressed: () {},
                ),
                SossoldiButton(
                  label: 'Disabled',
                  size: size,
                  type: type,
                  onPressed: null,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class IconButtonUseCase extends StatelessWidget {
  const IconButtonUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget b(
      SossoldiIconButtonSize size,
      SossoldiIconButtonType type,
      SossoldiIconButtonVariant variant, {
      bool enabled = true,
    }) => SossoldiIconButton(
      icon: _icon,
      size: size,
      type: type,
      variant: variant,
      semanticLabel: 'Icon button',
      onPressed: enabled ? () {} : null,
    );

    const xs = SossoldiIconButtonSize.xs;
    const small = SossoldiIconButtonSize.small;
    const large = SossoldiIconButtonSize.large;
    const fill = SossoldiIconButtonType.fill;
    const outline = SossoldiIconButtonType.outline;
    const ghost = SossoldiIconButtonType.ghost;
    const primary = SossoldiIconButtonVariant.primary;
    const neutral = SossoldiIconButtonVariant.neutral;
    const white = SossoldiIconButtonVariant.white;

    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Figma variants',
          children: [
            b(xs, ghost, primary),
            b(xs, ghost, neutral),
            b(xs, ghost, neutral, enabled: false),
            b(small, fill, primary),
            b(small, fill, white),
            b(large, fill, white),
            b(small, outline, primary),
            b(small, ghost, primary),
            b(large, fill, primary),
            b(large, ghost, neutral),
            b(large, fill, primary, enabled: false),
          ],
        ),
      ],
    );
  }
}
