// What the panel shows about a box: padding, auto layout, fill, border,
// radius, shadow, opacity and text, read from the render objects that make
// it (a box is often a chain of same-size wrappers: decoration, clip,
// padding...).

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'inspection.dart';

class FlexInfo {
  const FlexInfo(this.flex);

  final RenderFlex flex;

  Axis get direction => flex.direction;
  MainAxisAlignment get mainAxisAlignment => flex.mainAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => flex.crossAxisAlignment;
  MainAxisSize get mainAxisSize => flex.mainAxisSize;
  double get spacing => flex.spacing;
}

class TextInfo {
  const TextInfo(this.text, this.style, this.maxLines, this.align);

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextAlign align;

  double? get lineHeight => style.height == null || style.fontSize == null
      ? null
      : style.height! * style.fontSize!;
}

class IconInfo {
  const IconInfo(this.size, this.color);

  final double? size;
  final Color? color;
}

class ShadowInfo {
  const ShadowInfo(this.shadows);

  final List<BoxShadow> shadows;
}

class NodeProperties {
  NodeProperties({
    required this.size,
    required this.position,
    this.padding,
    this.outerPadding,
    this.flex,
    this.fill,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.circle = false,
    this.corners,
    this.shadows = const [],
    this.elevation,
    this.opacity,
    this.text,
    this.icon,
  });

  final Size size;

  /// Top left corner on the screen.
  final Offset position;

  /// Inside the box (between its edge and its content).
  final EdgeInsets? padding;

  /// Around the box, from a Padding that wraps it.
  final EdgeInsets? outerPadding;
  final FlexInfo? flex;
  final Color? fill;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? radius;
  final bool circle;

  /// How the corners are drawn when not plain rounded: "superellipse"
  /// (smooth corners, as in iOS), "stadium", "circle".
  final String? corners;
  final List<BoxShadow> shadows;
  final double? elevation;
  final double? opacity;
  final TextInfo? text;
  final IconInfo? icon;
}

/// Radius, side and kind of corners of a shape border.
(BorderRadius?, BorderSide?, String?) _shape(ShapeBorder shape, Size size) =>
    switch (shape) {
      RoundedRectangleBorder(:final borderRadius, :final side) => (
        borderRadius.resolve(TextDirection.ltr),
        side,
        null,
      ),
      RoundedSuperellipseBorder(:final borderRadius, :final side) => (
        borderRadius.resolve(TextDirection.ltr),
        side,
        'superellipse',
      ),
      StadiumBorder(:final side) => (
        BorderRadius.circular(size.shortestSide / 2),
        side,
        'stadium',
      ),
      CircleBorder(:final side) => (null, side, 'circle'),
      _ => (null, null, null),
    };

RenderBox? _onlyChild(RenderObject o) {
  RenderBox? child;
  var count = 0;
  o.visitChildren((c) {
    count++;
    if (c is RenderBox) child = c;
  });
  return count == 1 ? child : null;
}

NodeProperties readProperties(Inspection inspection, InspectedNode node) {
  final box = node.box;
  final size = box.size;

  // The same-size chain: wrappers above and below the box.
  final chain = <RenderBox>[box];
  for (RenderBox? c = _onlyChild(box); c != null && c.hasSize;) {
    if (c is RenderPadding) {
      chain.add(c);
      // Its child is the content, smaller: a Row or Column there is the
      // auto layout of the box, as in Figma.
      if (_onlyChild(c) case final RenderFlex content) chain.add(content);
      break;
    }
    if (c.size != size) break;
    chain.add(c);
    c = _onlyChild(c);
  }
  EdgeInsets? outer;
  for (var p = box.parent; p is RenderBox && p.hasSize;) {
    if (p is RenderPadding) {
      final insets = p.padding.resolve(TextDirection.ltr);
      if (insets != EdgeInsets.zero) outer = insets;
      break;
    }
    if (p.size != size) break;
    chain.add(p);
    p = p.parent;
  }

  EdgeInsets? padding;
  FlexInfo? flex;
  Color? fill;
  Color? borderColor;
  double? borderWidth;
  BorderRadius? radius;
  var circle = false;
  String? corners;
  var shadows = const <BoxShadow>[];
  double? elevation;
  double? opacity;

  for (final r in chain) {
    // ColoredBox draws with a private render object: read its widget.
    if (inspection.elementOf(r)?.widget case ColoredBox(:final color)) {
      fill ??= color;
    }
    switch (r) {
      case RenderPadding():
        final insets = r.padding.resolve(TextDirection.ltr);
        if (insets != EdgeInsets.zero) padding ??= insets;
      case RenderFlex():
        flex ??= FlexInfo(r);
      case RenderDecoratedBox(:final decoration):
        if (decoration case BoxDecoration d) {
          fill ??= d.color;
          if (d.border case Border b when b.top.style != BorderStyle.none) {
            borderColor ??= b.top.color;
            borderWidth ??= b.top.width;
          }
          if (d.borderRadius != null) {
            radius ??= d.borderRadius!.resolve(TextDirection.ltr);
          }
          if (d.shape == BoxShape.circle) circle = true;
          if (d.boxShadow != null && d.boxShadow!.isNotEmpty) {
            shadows = d.boxShadow!;
          }
        } else if (decoration case ShapeDecoration d) {
          fill ??= d.color;
          final (shapeRadius, side, kind) = _shape(d.shape, size);
          if (shapeRadius != null) radius ??= shapeRadius;
          if (kind == 'circle') circle = true;
          if (kind != null) corners ??= kind;
          if (side != null && side.style != BorderStyle.none) {
            borderColor ??= side.color;
            borderWidth ??= side.width;
          }
          if (d.shadows != null && d.shadows!.isNotEmpty) shadows = d.shadows!;
        }
      case RenderPhysicalModel():
        fill ??= r.color;
        if (r.borderRadius != null) {
          radius ??= r.borderRadius!.resolve(TextDirection.ltr);
        }
        if (r.elevation > 0) elevation = r.elevation;
      case RenderPhysicalShape(:final clipper):
        fill ??= r.color;
        if (clipper case ShapeBorderClipper(:final shape)) {
          final (shapeRadius, _, kind) = _shape(shape, size);
          if (shapeRadius != null) radius ??= shapeRadius;
          if (kind != null) corners ??= kind;
        }
        if (r.elevation > 0) elevation = r.elevation;
      case RenderClipRRect(:final borderRadius):
        radius ??= borderRadius.resolve(TextDirection.ltr);
      case RenderClipRSuperellipse(:final borderRadius):
        radius ??= borderRadius.resolve(TextDirection.ltr);
        corners ??= 'superellipse';
      case RenderClipOval():
        circle = true;
      case RenderOpacity() when r.opacity < 1:
        opacity ??= r.opacity;
      default:
        break;
    }
  }

  TextInfo? text;
  if (box is RenderParagraph) {
    final span = box.text;
    text = TextInfo(
      span.toPlainText(),
      span.style ?? const TextStyle(),
      box.maxLines,
      box.textAlign,
    );
  }

  IconInfo? icon;
  node.element?.visitAncestorElements((e) {
    final w = e.widget;
    if (w is Icon) {
      icon = IconInfo(
        w.size ?? IconTheme.of(e).size,
        w.color ?? IconTheme.of(e).color,
      );
      return false;
    }
    return e.renderObject == box;
  });
  // An icon is a one-glyph text: the icon row says it all.
  if (icon != null) text = null;

  return NodeProperties(
    size: size,
    position: inspection.rectOf(node).topLeft,
    padding: padding,
    outerPadding: outer,
    flex: flex,
    fill: fill,
    borderColor: borderColor,
    borderWidth: borderWidth,
    radius: radius,
    circle: circle,
    corners: corners,
    shadows: shadows,
    elevation: elevation,
    opacity: opacity,
    text: text,
    icon: icon,
  );
}
