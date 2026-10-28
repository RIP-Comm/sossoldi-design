// Single tab, from Figma component "Tabs" (node 3:3926).
// Usually placed inside a SossoldiTabNavigation.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiTab extends StatelessWidget {
  /// Text tab (Figma Type=Default), with optional icon and counter.
  const SossoldiTab({
    super.key,
    required String this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.counter,
  }) : semanticLabel = null;

  /// Icon-only tab (Figma Type=Icon).
  const SossoldiTab.icon({
    super.key,
    required IconData this.icon,
    required this.active,
    required this.onTap,
    required String this.semanticLabel,
  }) : label = null,
       counter = null;

  final String? label;
  final IconData? icon;
  final bool active;
  final VoidCallback? onTap;

  /// Small badge after the label (e.g. a count).
  final String? counter;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final iconOnly = label == null;

    return SossoldiTappable(
      onTap: onTap,
      selected: active,
      semanticLabel: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        padding: const EdgeInsets.all(SossoldiSpacing.xs),
        decoration: ShapeDecoration(
          color: active ? colors.surfaceHigh : null,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(SossoldiRadius.s),
          ),
        ),
        child: Row(
          mainAxisSize: iconOnly ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: SossoldiSpacing.xs,
          children: [
            if (icon != null) Icon(icon, size: 16, color: colors.textHigh),
            if (!iconOnly)
              Flexible(
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (active
                              ? typography.labelBoldMedium
                              : typography.labelMedium)
                          .copyWith(color: colors.textHigh),
                ),
              ),
            if (counter != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SossoldiSpacing.xs,
                  vertical: SossoldiSpacing.xs / 2,
                ),
                decoration: ShapeDecoration(
                  color: colors.surfaceMed,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(SossoldiRadius.xs),
                    side: BorderSide(color: colors.strokeDefault, width: 0.5),
                  ),
                ),
                child: Text(
                  counter!,
                  style: typography.labelSmall.copyWith(color: colors.textHigh),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
