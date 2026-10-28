// List container, from Figma component "List" (node 3:4123): a rounded
// white surface grouping rows such as SossoldiMenuItem.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';

class SossoldiList extends StatelessWidget {
  const SossoldiList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.m),
      child: ColoredBox(
        color: context.colors.surfaceHigh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
