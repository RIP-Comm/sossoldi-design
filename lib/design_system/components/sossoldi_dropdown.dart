// Dropdown panel, from Figma component "Dropdown" (node 3:4125): the
// elevated surface that opens under Select, Search and similar triggers.
// Type Single holds a list of options; Custom holds any content.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_list.dart';

class SossoldiDropdown extends StatelessWidget {
  /// Options list (Figma Custom=False), usually SossoldiMenuItem rows.
  const SossoldiDropdown({
    super.key,
    required List<Widget> this.options,
    this.maxHeight,
  }) : child = null;

  /// Free content (Figma Custom=True).
  const SossoldiDropdown.custom({
    super.key,
    required Widget this.child,
    this.maxHeight,
  }) : options = null;

  final List<Widget>? options;
  final Widget? child;

  /// Not in Figma: the most the panel can be tall; the content scrolls inside.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final content = options != null ? SossoldiList(children: options!) : child;
    return Container(
      padding: options != null
          ? const EdgeInsets.all(SossoldiSpacing.s)
          : const EdgeInsets.all(SossoldiSpacing.xs),
      decoration: ShapeDecoration(
        color: context.colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
        shadows: SossoldiShadows.lg,
      ),
      constraints: maxHeight == null
          ? null
          : BoxConstraints(maxHeight: maxHeight!),
      child: maxHeight == null
          ? content
          : SingleChildScrollView(child: content),
    );
  }
}
