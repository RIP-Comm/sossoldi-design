// Search button, from Figma component "Search" (State=Icon, node 3:3783):
// a round button that opens a search, e.g. in a page header.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import 'sossoldi_tappable.dart';

class SossoldiSearchButton extends StatelessWidget {
  const SossoldiSearchButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
  });

  final VoidCallback? onPressed;

  /// E.g. "Search".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SossoldiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          PhosphorIconsRegular.magnifyingGlass,
          size: 20,
          color: colors.textHigh,
        ),
      ),
    );
  }
}
