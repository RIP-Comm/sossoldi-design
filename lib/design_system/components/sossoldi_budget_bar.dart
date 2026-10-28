// Budget bar, from the "Progress" of the Figma "Budget" component (node
// 13:4293): 8px high, fully rounded, a colored fill over a tint track.
// An exceeded budget is a full bar with an error-colored outline.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';

class SossoldiBudgetBar extends StatelessWidget {
  const SossoldiBudgetBar({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.exceeded = false,
  });

  /// How much of the bar is filled, 0 to 1 (more is the same as full).
  final double value;
  final Color color;

  /// The empty part.
  final Color trackColor;

  /// Marks the bar with the error outline.
  final bool exceeded;

  static const double height = 8;

  /// Width of the error outline.
  static const double outline = 1.5;

  @override
  Widget build(BuildContext context) {
    final error = context.colors.error.stroke;
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: CustomPaint(
          painter: _BarPainter(
            value: v,
            color: color,
            track: trackColor,
            outline: exceeded ? error : null,
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.outline,
  });

  final double value;
  final Color color;
  final Color track;
  final Color? outline;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(SossoldiRadius.max),
    );
    canvas.drawRRect(shape, Paint()..color = track);
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * value, size.height),
      Paint()..color = color,
    );
    canvas.restore();
    if (outline != null) {
      canvas.drawRRect(
        shape.deflate(SossoldiBudgetBar.outline / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = SossoldiBudgetBar.outline
          ..color = outline!,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.outline != outline;
}
