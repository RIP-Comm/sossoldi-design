// Filter button, from Figma "Filter button" (node 13:4219): a 40px white
// round button with a funnel, and a small blue dot while filters are active.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/shadows.dart';
import 'sossoldi_tappable.dart';

class SossoldiFilterButton extends StatelessWidget {
  const SossoldiFilterButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    this.active = false,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;

  /// Shows the dot: some filter is applied.
  final bool active;

  static const double size = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SossoldiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors.surfaceHigh,
                shape: BoxShape.circle,
                boxShadow: SossoldiShadows.s,
              ),
              child: Icon(
                PhosphorIconsRegular.funnel,
                size: 20,
                color: colors.textHigh,
              ),
            ),
            if (active)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.primary.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surfaceMed, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
