// Reads the render tree of the app shown in the device: what is under the
// pointer, its widget, its box on the screen and the component it belongs to.
// Works in release builds too: no debug-only API (debugCreator) is used.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../catalog/widget_names.g.dart';

/// One element of the app picked by the inspector.
class InspectedNode {
  InspectedNode(this.box, this.element);

  final RenderBox box;

  /// The widget that made [box] (its element), when found.
  final Element? element;

  @override
  bool operator ==(Object other) => other is InspectedNode && other.box == box;

  @override
  int get hashCode => box.hashCode;
}

class Inspection {
  /// [screen] is the element of the device screen: everything the app draws
  /// (pages, sheets, dialogs) is below it.
  Inspection(this.screen);

  final Element screen;

  RenderBox get screenBox => screen.renderObject! as RenderBox;

  Map<RenderObject, Element>? _elements;

  /// Which element made each render object; built on demand and thrown away
  /// with [invalidate], since the app tree changes all the time.
  Map<RenderObject, Element> get _byRenderObject {
    final map = _elements;
    if (map != null) return map;
    final built = <RenderObject, Element>{};
    void visit(Element e) {
      if (e is RenderObjectElement) built[e.renderObject] = e;
      e.visitChildren(visit);
    }

    screen.visitChildren(visit);
    return _elements = built;
  }

  void invalidate() => _elements = null;

  Element? elementOf(RenderObject o) => _byRenderObject[o];

  /// The deepest visible box under [position] (screen coordinates); with
  /// [component] the design system component (or screen) it belongs to.
  InspectedNode? pick(Offset position, {bool component = false}) {
    final result = BoxHitTestResult();
    screenBox.hitTest(result, position: position);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is! RenderBox || !target.hasSize || target == screenBox) {
        continue;
      }
      if (target.size.isEmpty) continue;
      final node = InspectedNode(target, elementOf(target));
      return component ? (componentOf(node) ?? node) : node;
    }
    return null;
  }

  /// The box of [node] on the screen.
  Rect rectOf(InspectedNode node) {
    final box = node.box;
    if (!box.attached || !box.hasSize) return Rect.zero;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: screenBox);
    final bottomRight = box.localToGlobal(
      box.size.bottomRight(Offset.zero),
      ancestor: screenBox,
    );
    return Rect.fromPoints(topLeft, bottomRight);
  }

  /// The named widgets that contain [node], innermost first: design system
  /// components and feature widgets (screens, tabs, cards).
  List<InspectedNode> namedAncestors(InspectedNode node) {
    final element = node.element;
    if (element == null) return const [];
    final found = <InspectedNode>[];
    void add(Element e) {
      final box = e.renderObject;
      if (box is RenderBox && box.hasSize) found.add(InspectedNode(box, e));
    }

    if (widgetName(element.widget) != null) add(element);
    element.visitAncestorElements((e) {
      if (e == screen) return false;
      if (widgetName(e.widget) != null) add(e);
      return true;
    });
    return found;
  }

  /// The closest design system component containing [node].
  InspectedNode? componentOf(InspectedNode node) {
    for (final a in namedAncestors(node)) {
      if (designSystemName(a.element!.widget) != null) return a;
    }
    return null;
  }

  /// The box around [node] (a bigger one: same-size wrappers are skipped).
  InspectedNode? parentOf(InspectedNode node) {
    final rect = rectOf(node);
    RenderObject? p = node.box.parent;
    while (p is RenderBox && p != screenBox) {
      final candidate = InspectedNode(p, elementOf(p));
      if (rectOf(candidate) != rect) return candidate;
      p = p.parent;
    }
    return null;
  }
}

/// The name of a widget of the app: its component or feature class.
String? widgetName(Widget widget) =>
    designSystemName(widget) ?? featureName(widget);

/// What [node] is, for the panel title: the class of a named widget, else
/// the kind of box ("Text", "Row", "Box"...).
String describeNode(InspectedNode node) {
  final element = node.element;
  if (element != null) {
    final named = widgetName(element.widget);
    if (named != null) return named;
    Element? icon;
    element.visitAncestorElements((e) {
      if (e.widget is Icon) icon = e;
      return icon == null && e.renderObject == node.box;
    });
    if (icon != null) return 'Icon';
  }
  return switch (node.box) {
    RenderParagraph() => 'Text',
    RenderFlex(:final direction) =>
      direction == Axis.horizontal ? 'Row' : 'Column',
    RenderDecoratedBox() => 'Box',
    RenderPadding() => 'Padding',
    RenderImage() => 'Image',
    RenderClipRRect() || RenderClipRect() || RenderClipOval() => 'Clip',
    RenderPhysicalModel() || RenderPhysicalShape() => 'Surface',
    RenderCustomPaint() => 'Custom paint',
    RenderStack() => 'Stack',
    RenderEditable() => 'Text field',
    RenderViewportBase() => 'Scroll view',
    RenderWrap() => 'Wrap',
    _ => 'Box',
  };
}
