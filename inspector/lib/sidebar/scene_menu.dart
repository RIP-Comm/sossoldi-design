// The left menu: the main screens of the app, grouped by section. A tap
// opens the screen directly, from its first state.

import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../inspector_controller.dart';
import '../scenes.dart';

class SceneMenu extends StatelessWidget {
  const SceneMenu({super.key, required this.controller});

  final InspectorController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SossoldiSpacing.m,
        0,
        SossoldiSpacing.m,
        SossoldiSpacing.l,
      ),
      children: [
        for (final group in sceneGroups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SossoldiSpacing.s,
              SossoldiSpacing.xl,
              SossoldiSpacing.s,
              SossoldiSpacing.xs,
            ),
            child: Row(
              spacing: SossoldiSpacing.s,
              children: [
                Icon(group.icon, size: 20, color: colors.textMed),
                Text(
                  group.title,
                  style: typography.labelBoldLarge.copyWith(
                    color: colors.textMed,
                  ),
                ),
              ],
            ),
          ),
          for (final scene in group.scenes)
            SossoldiMenuItem(
              label: scene.title,
              dense: true,
              selected: scene == controller.scene,
              onTap: () => controller.openScene(scene),
            ),
        ],
      ],
    );
  }
}
