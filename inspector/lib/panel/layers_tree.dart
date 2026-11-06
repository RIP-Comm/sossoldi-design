// The layers of the selection, as a tree: the components and screens around
// it, outermost first, and the selected layer last. Every row has the icon of
// its kind (a component is purple, as in Figma); the whole row, icon and name,
// selects the layer, and the name is underlined on hover.

import 'package:flutter/material.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../inspect/inspection.dart';
import '../inspector_controller.dart';

class LayersTree extends StatelessWidget {
  const LayersTree({
    super.key,
    required this.controller,
    required this.inspection,
    required this.node,
  });

  final InspectorController controller;
  final Inspection inspection;
  final InspectedNode node;

  /// Rows shown before the tree scrolls.
  static const maxRows = 8;

  @override
  Widget build(BuildContext context) {
    // Outermost first; the app itself is only the wrapper of the phone.
    final ancestors = inspection
        .namedAncestors(node)
        // By element, not by box: a screen and the component it wraps can
        // share the same box and are still two layers.
        .where(
          (a) => a.element != node.element && a.element!.widget is! SossoldiApp,
        )
        .toList()
        .reversed
        .toList();
    final layers = [...ancestors, node];
    final rows = [
      for (final (depth, layer) in layers.indexed)
        _LayerRow(
          depth: depth,
          layer: layer,
          selected: depth == layers.length - 1,
          onTap: () => controller.select(layer),
        ),
    ];
    final tree = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
    if (rows.length <= maxRows) return tree;
    // Long: the tree scrolls, from the selected layer (the last one).
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _LayerRow.height * maxRows),
      child: SingleChildScrollView(reverse: true, child: tree),
    );
  }
}

class _LayerRow extends StatefulWidget {
  const _LayerRow({
    required this.depth,
    required this.layer,
    required this.selected,
    required this.onTap,
  });

  final int depth;
  final InspectedNode layer;
  final bool selected;
  final VoidCallback onTap;

  static const height = 28.0;

  @override
  State<_LayerRow> createState() => _LayerRowState();
}

class _LayerRowState extends State<_LayerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final kind = kindOf(widget.layer);
    final name = describeNode(widget.layer);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          selected: widget.selected,
          label: '${kind.label} $name',
          excludeSemantics: true,
          child: Container(
            height: _LayerRow.height,
            padding: EdgeInsets.only(
              left: SossoldiSpacing.xs + widget.depth * SossoldiSpacing.m,
              right: SossoldiSpacing.s,
            ),
            decoration: BoxDecoration(
              color: widget.selected ? colors.selectedPrimarySurface : null,
              borderRadius: BorderRadius.circular(SossoldiRadius.xs),
            ),
            child: Row(
              spacing: SossoldiSpacing.s,
              children: [
                Icon(kind.glyph, size: 16, color: kind.color(colors)),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.labelMedium.copyWith(
                      color: widget.selected
                          ? colors.primary.text
                          : colors.textHigh,
                      decoration: _hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: widget.selected
                          ? colors.primary.text
                          : colors.textHigh,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
