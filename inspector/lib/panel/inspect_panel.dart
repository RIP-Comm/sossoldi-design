// The right panel, like Figma Dev Mode: what the selected box is, where it
// sits among the components, and its measures with the tokens they come from.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../catalog/tokens.dart';
import '../catalog/widget_names.g.dart';
import '../inspect/inspection.dart';
import '../inspect/node_kind.dart';
import '../inspect/node_properties.dart';
import '../inspector_controller.dart';
import 'component_section.dart';
import 'layers_tree.dart';
import 'panel_rows.dart';

class InspectPanel extends StatelessWidget {
  const InspectPanel({
    super.key,
    required this.controller,
    required this.inspection,
  });

  final InspectorController controller;
  final Inspection? Function() inspection;

  @override
  Widget build(BuildContext context) {
    final node = controller.selected;
    final i = inspection();
    if (node == null || i == null || !node.box.attached) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SossoldiSpacing.xl),
          child: SossoldiEmptyState(
            icon: PhosphorIconsRegular.cursorClick,
            title: controller.mode == InspectorMode.inspect
                ? 'Select an element'
                : 'Interact mode',
            message: controller.mode == InspectorMode.inspect
                ? 'Click anything on the phone to see its size, spacing, '
                      'colors and text style. Hover another element to '
                      'measure the distance.'
                : 'The app works as on the phone. Switch to Inspect to '
                      'measure it.',
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(SossoldiSpacing.l),
      children: [
        // The layers are outside the selectable area: there a press selects a
        // layer (and the pointer is a hand), not a piece of text.
        _Header(controller: controller, inspection: i, node: node),
        // The values below can be selected and copied.
        SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sections(context, i, node),
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(
    BuildContext context,
    Inspection inspection,
    InspectedNode node,
  ) {
    final p = readProperties(inspection, node);
    final colors = context.colors;
    // Tokens are looked up in the theme of the app, not of the Inspector.
    final appColors = controller.dark
        ? SossoldiColors.dark
        : SossoldiColors.light;
    final typography = context.typography;
    final widget = node.element?.widget;
    final component = widget == null ? null : designSystemName(widget);
    return [
      if (component != null) ComponentSection(name: component),
      PanelSection(
        title: 'Layout',
        children: [
          PanelGrid(
            cells: [
              ('W', px(p.size.width)),
              ('H', px(p.size.height)),
              ('X', px(p.position.dx)),
              ('Y', px(p.position.dy)),
            ],
          ),
        ],
      ),
      if (p.padding != null)
        PanelSection(
          title: 'Padding',
          children: [InsetsBox(insets: p.padding!)],
        ),
      if (p.outerPadding != null)
        PanelSection(
          title: 'Margin (padding around)',
          children: [InsetsBox(insets: p.outerPadding!)],
        ),
      if (p.flex case final flex?)
        PanelSection(
          title: 'Auto layout',
          children: [
            PanelRow(
              label: 'Direction',
              value: flex.direction == Axis.horizontal
                  ? 'Horizontal (Row)'
                  : 'Vertical (Column)',
            ),
            PanelRow(
              label: 'Gap',
              value: px(flex.spacing),
              tokens: [?spacingToken(flex.spacing)],
            ),
            PanelRow(label: 'Main axis', value: flex.mainAxisAlignment.name),
            PanelRow(label: 'Cross axis', value: flex.crossAxisAlignment.name),
            PanelRow(
              label: 'Size',
              value: flex.mainAxisSize == MainAxisSize.max ? 'Fill' : 'Hug',
            ),
          ],
        ),
      if (p.fill != null ||
          p.borderColor != null ||
          p.radius != null ||
          p.circle ||
          p.shadows.isNotEmpty ||
          p.elevation != null ||
          p.opacity != null)
        PanelSection(
          title: 'Appearance',
          children: [
            if (p.fill case final fill?)
              ColorRow(label: 'Fill', info: describeColor(fill, appColors)),
            if (p.borderColor case final border?) ...[
              ColorRow(label: 'Border', info: describeColor(border, appColors)),
              PanelRow(label: 'Border width', value: px(p.borderWidth ?? 0)),
            ],
            if (p.circle)
              const PanelRow(label: 'Shape', value: 'Circle')
            else if (p.radius case final r?)
              _radiusRow(r, p.corners),
            if (p.shadows.isNotEmpty)
              PanelRow(
                label: 'Shadow',
                value: _shadowCss(p.shadows),
                tokens: [?_shadowToken(p.shadows)],
              ),
            if (p.elevation case final e?)
              PanelRow(label: 'Elevation', value: px(e)),
            if (p.opacity case final o?)
              PanelRow(label: 'Opacity', value: '${(o * 100).round()}%'),
          ],
        ),
      if (p.text case final text?)
        PanelSection(
          title: 'Text',
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: SossoldiSpacing.s),
              child: Text(
                text.text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: typography.bodyMedium.copyWith(color: colors.textHigh),
              ),
            ),
            if (typographyToken(text.style, typography) case final styles?)
              PanelRow(label: 'Style', tokens: styles.split(' / '))
            else
              const PanelRow(label: 'Style', value: 'Custom'),
            PanelRow(label: 'Font', value: text.style.fontFamily ?? '-'),
            PanelRow(
              label: 'Weight',
              value: '${text.style.fontWeight?.value ?? 400}',
            ),
            PanelRow(label: 'Size', value: px(text.style.fontSize ?? 14)),
            if (text.lineHeight case final lh?)
              PanelRow(label: 'Line height', value: px(lh)),
            PanelRow(
              label: 'Letter spacing',
              value: px(text.style.letterSpacing ?? 0),
            ),
            if (text.style.color case final c?)
              ColorRow(label: 'Color', info: describeColor(c, appColors)),
            PanelRow(label: 'Align', value: text.align.name),
            if (text.maxLines case final lines?)
              PanelRow(label: 'Max lines', value: '$lines'),
          ],
        ),
      if (p.icon case final icon?)
        PanelSection(
          title: 'Icon',
          children: [
            const PanelRow(label: 'Set', value: 'Phosphor'),
            PanelRow(label: 'Size', value: px(icon.size ?? 24)),
            if (icon.color case final c?)
              ColorRow(label: 'Color', info: describeColor(c, appColors)),
          ],
        ),
    ];
  }

  Widget _radiusRow(BorderRadius r, String? corners) {
    final values = {r.topLeft.x, r.topRight.x, r.bottomRight.x, r.bottomLeft.x};
    final value = values.length == 1
        ? px(r.topLeft.x)
        : '${px(r.topLeft.x)} ${px(r.topRight.x)} '
              '${px(r.bottomRight.x)} ${px(r.bottomLeft.x)}';
    return PanelRow(
      label: corners == 'superellipse' ? 'Radius (smooth)' : 'Radius',
      value: value,
      tokens: [?(values.length == 1 ? radiusToken(r.topLeft.x) : null)],
    );
  }

  String _shadowCss(List<BoxShadow> shadows) => shadows
      .map(
        (s) =>
            '${px(s.offset.dx)} ${px(s.offset.dy)} ${px(s.blurRadius)}'
            '${s.spreadRadius != 0 ? ' ${px(s.spreadRadius)}' : ''} '
            '${describeColor(s.color, SossoldiColors.light).hex}',
      )
      .join(', ');

  String? _shadowToken(List<BoxShadow> shadows) {
    bool same(List<BoxShadow> a) =>
        a.length == shadows.length &&
        [for (var i = 0; i < a.length; i++) a[i] == shadows[i]].every((x) => x);
    if (same(SossoldiShadows.s)) return 'shadow s';
    if (same(SossoldiShadows.m)) return 'shadow m';
    if (same(SossoldiShadows.xl)) return 'shadow xl';
    if (same(SossoldiShadows.lg)) return 'shadow lg';
    if (same(SossoldiShadows.sm)) return 'shadow sm';
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.inspection,
    required this.node,
  });

  final InspectorController controller;
  final Inspection inspection;
  final InspectedNode node;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final name = describeNode(node);
    final kind = kindOf(node);
    final parent = inspection.parentOf(node);

    return Padding(
      padding: const EdgeInsets.only(bottom: SossoldiSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.s,
        children: [
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              Icon(kind.glyph, size: 20, color: kind.color(colors)),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.titleMedium.copyWith(
                    color: colors.textHigh,
                  ),
                ),
              ),
              SossoldiTag(
                label: switch (kind) {
                  NodeKind.component => 'Component',
                  NodeKind.feature => 'Feature',
                  _ => 'Element',
                },
                hasStroke: true,
              ),
              SossoldiIconButton(
                icon: PhosphorIconsRegular.arrowUp,
                semanticLabel: 'Select parent',
                onPressed: parent == null
                    ? null
                    : () => controller.select(parent),
              ),
            ],
          ),
          // Where it sits: the components and screens around it.
          LayersTree(
            controller: controller,
            inspection: inspection,
            node: node,
          ),
        ],
      ),
    );
  }
}
