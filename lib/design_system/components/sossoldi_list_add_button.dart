// "Add ..." row closing a list, from the Type=Button variant of the Figma
// components Account, Category, Asset and Transaction item.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_button.dart';

class SossoldiListAddButton extends StatelessWidget {
  const SossoldiListAddButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// E.g. "Add account".
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      alignment: Alignment.centerLeft,
      decoration: ShapeDecoration(
        color: context.colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
        ),
      ),
      child: SossoldiButton(
        label: label,
        onPressed: onPressed,
        type: SossoldiButtonType.ghost,
        size: SossoldiButtonSize.large,
        iconRight: PhosphorIconsRegular.plus,
      ),
    );
  }
}
