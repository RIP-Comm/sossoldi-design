// Draws over the device screen, as in Figma Dev Mode: the box under the
// pointer, the selected one with its size and padding, and the distances
// from the selected box to the one under the pointer.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../catalog/tokens.dart';

class MeasurePainter extends CustomPainter {
  MeasurePainter({
    required this.colors,
    required this.labelStyle,
    required this.selected,
    required this.hovered,
    required this.padding,
    super.repaint,
  });

  final SossoldiColors colors;
  final TextStyle labelStyle;
  final Rect? Function() selected;
  final Rect? Function() hovered;
  final EdgeInsets? Function() padding;

  Color get _select => colors.primary.surface;
  Color get _measure => colors.expense.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final sel = selected();
    final hov = hovered();

    if (sel != null) {
      final insets = padding();
      if (insets != null) _paintPadding(canvas, sel, insets);
    }
    if (hov != null && hov != sel) {
      canvas.drawRect(
        hov,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _select.withValues(alpha: 0.7),
      );
    }
    if (sel != null) {
      canvas.drawRect(
        sel,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _select,
      );
      _label(
        canvas,
        size,
        '${px(sel.width)} × ${px(sel.height)}',
        Offset(sel.center.dx, sel.bottom + 4),
        _select,
        below: true,
      );
      if (hov != null && hov != sel) _paintDistances(canvas, size, sel, hov);
    }
  }

  void _paintPadding(Canvas canvas, Rect r, EdgeInsets p) {
    final paint = Paint()..color = colors.success.text.withValues(alpha: 0.22);
    final inner = p.deflateRect(r);
    canvas.drawRect(Rect.fromLTRB(r.left, r.top, r.right, inner.top), paint);
    canvas.drawRect(
      Rect.fromLTRB(r.left, inner.bottom, r.right, r.bottom),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(r.left, inner.top, inner.left, inner.bottom),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(inner.right, inner.top, r.right, inner.bottom),
      paint,
    );
  }

  /// Figma's rule: from the inner box to the edges of the outer one when one
  /// contains the other, else the gaps between them on each axis.
  void _paintDistances(Canvas canvas, Size size, Rect a, Rect b) {
    final contains = _contains(b, a) || _contains(a, b);
    if (contains) {
      final inner = _contains(b, a) ? a : b;
      final outer = inner == a ? b : a;
      final x = inner.center.dx;
      final y = inner.center.dy;
      _line(canvas, size, Offset(x, outer.top), Offset(x, inner.top));
      _line(canvas, size, Offset(x, inner.bottom), Offset(x, outer.bottom));
      _line(canvas, size, Offset(outer.left, y), Offset(inner.left, y));
      _line(canvas, size, Offset(inner.right, y), Offset(outer.right, y));
      return;
    }
    // Horizontal gap, at the middle of the vertical overlap (or of a).
    final overlapTop = math.max(a.top, b.top);
    final overlapBottom = math.min(a.bottom, b.bottom);
    final y = overlapTop < overlapBottom
        ? (overlapTop + overlapBottom) / 2
        : a.center.dy;
    if (b.left >= a.right) {
      _line(canvas, size, Offset(a.right, y), Offset(b.left, y));
    } else if (a.left >= b.right) {
      _line(canvas, size, Offset(b.right, y), Offset(a.left, y));
    }
    final overlapLeft = math.max(a.left, b.left);
    final overlapRight = math.min(a.right, b.right);
    final x = overlapLeft < overlapRight
        ? (overlapLeft + overlapRight) / 2
        : a.center.dx;
    if (b.top >= a.bottom) {
      _line(canvas, size, Offset(x, a.bottom), Offset(x, b.top));
    } else if (a.top >= b.bottom) {
      _line(canvas, size, Offset(x, b.bottom), Offset(x, a.top));
    }
  }

  bool _contains(Rect outer, Rect inner) =>
      outer.left <= inner.left &&
      outer.top <= inner.top &&
      outer.right >= inner.right &&
      outer.bottom >= inner.bottom;

  void _line(Canvas canvas, Size size, Offset from, Offset to) {
    final length = (to - from).distance;
    if (length < 0.5) return;
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = _measure
        ..strokeWidth = 1,
    );
    _label(canvas, size, px(length), (from + to) / 2, _measure);
  }

  /// A pill with [text] centered on [at] (or just below it), kept on screen.
  void _label(
    Canvas canvas,
    Size size,
    String text,
    Offset at,
    Color background, {
    bool below = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: labelStyle.copyWith(color: colors.primary.onSurface),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const pad = EdgeInsets.symmetric(
      horizontal: SossoldiSpacing.xs,
      vertical: 2,
    );
    final w = painter.width + pad.horizontal;
    final h = painter.height + pad.vertical;
    var left = at.dx - w / 2;
    var top = below ? at.dy : at.dy - h / 2;
    if (below && top + h > size.height) top = at.dy - h - 8;
    left = left.clamp(0, math.max(0, size.width - w));
    top = top.clamp(0, math.max(0, size.height - h));
    final rect = Rect.fromLTWH(left, top, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(SossoldiRadius.xs)),
      Paint()..color = background,
    );
    painter.paint(canvas, rect.topLeft + pad.topLeft);
  }

  @override
  bool shouldRepaint(MeasurePainter old) => true;
}
