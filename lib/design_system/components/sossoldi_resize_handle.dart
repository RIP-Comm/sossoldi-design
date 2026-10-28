// Resize handle shown on a widget in edit mode, from Figma "Edit handle"
// (node 13:3925): a 32px curved grip with a half-transparent fill and a
// light stroke, bottom-right of the widget. Dragging it is handled by the
// parent; this is only the drawing.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

class SossoldiResizeHandle extends StatelessWidget {
  const SossoldiResizeHandle({super.key});

  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      size: const Size.square(size),
      painter: _HandlePainter(
        fill: colors.surfaceMed.withValues(alpha: 0.5),
        // The light stroke disappears on the dark background, where a
        // lighter grey (grey 40) is used instead.
        stroke: Theme.of(context).brightness == Brightness.dark
            ? colors.shapeLow
            : colors.strokeMinus1,
      ),
    );
  }
}

class _HandlePainter extends CustomPainter {
  _HandlePainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  // The 32x32 outline from the Figma vector.
  static final Path _outline = Path()
    ..moveTo(20, 10)
    ..lineTo(20, 6)
    ..cubicTo(20, 2.68629, 22.6863, 0, 26, 0)
    ..cubicTo(29.3137, 0, 32, 2.68629, 32, 6)
    ..lineTo(32, 10)
    ..cubicTo(32, 22.1503, 22.1503, 32, 10, 32)
    ..lineTo(6, 32)
    ..cubicTo(2.68629, 32, 0, 29.3137, 0, 26)
    ..cubicTo(0, 22.6863, 2.68629, 20, 6, 20)
    ..lineTo(10, 20)
    ..cubicTo(15.5228, 20, 20, 15.5228, 20, 10)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    canvas.drawPath(_outline, Paint()..color = fill);
    canvas.drawPath(
      _outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(_HandlePainter old) =>
      old.fill != fill || old.stroke != stroke;
}
