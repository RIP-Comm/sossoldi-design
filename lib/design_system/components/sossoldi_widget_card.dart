// Dashboard widget container, from Figma component "Widget" (node 13:3847):
// a white card with large rounded corners. Its size comes from the grid
// (SossoldiWidgetGrid); the content is supplied by the caller.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';

class SossoldiWidgetCard extends StatelessWidget {
  const SossoldiWidgetCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.l),
      child: ColoredBox(color: context.colors.surfaceHigh, child: child),
    );
  }
}
