// Tooltip bubble, from Figma component "Tooltip" (node 3:4069): a short
// text with an optional pointer on one of 8 positions.
// To show it on a widget, use SossoldiTooltipTarget.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';

enum SossoldiTooltipArrow {
  none,
  topLeft,
  topMiddle,
  topRight,
  bottomLeft,
  bottomMiddle,
  bottomRight,
  left,
  right,
}

class SossoldiTooltip extends StatelessWidget {
  const SossoldiTooltip({
    super.key,
    required this.message,
    this.arrow = SossoldiTooltipArrow.none,
  });

  final String message;
  final SossoldiTooltipArrow arrow;

  static const double _arrowLength = 8;
  static const double _arrowWidth = 16;

  /// Distance of a corner arrow from the bubble edge.
  static const double _cornerInset = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bubble = Container(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiRadius.xs),
        boxShadow: SossoldiShadows.sm,
      ),
      child: Text(
        message,
        style: context.typography.bodySmall.copyWith(color: colors.textMed),
      ),
    );
    if (arrow == SossoldiTooltipArrow.none) return bubble;

    final (AxisDirection direction, Alignment align) = switch (arrow) {
      SossoldiTooltipArrow.topLeft => (AxisDirection.up, Alignment.centerLeft),
      SossoldiTooltipArrow.topMiddle => (AxisDirection.up, Alignment.center),
      SossoldiTooltipArrow.topRight => (
        AxisDirection.up,
        Alignment.centerRight,
      ),
      SossoldiTooltipArrow.bottomLeft => (
        AxisDirection.down,
        Alignment.centerLeft,
      ),
      SossoldiTooltipArrow.bottomMiddle => (
        AxisDirection.down,
        Alignment.center,
      ),
      SossoldiTooltipArrow.bottomRight => (
        AxisDirection.down,
        Alignment.centerRight,
      ),
      SossoldiTooltipArrow.left => (AxisDirection.left, Alignment.center),
      SossoldiTooltipArrow.right => (AxisDirection.right, Alignment.center),
      SossoldiTooltipArrow.none => throw StateError('unreachable'),
    };
    final vertical =
        direction == AxisDirection.up || direction == AxisDirection.down;
    final pointer = Padding(
      padding: vertical
          ? const EdgeInsets.symmetric(horizontal: _cornerInset)
          : EdgeInsets.zero,
      child: Align(
        alignment: align,
        widthFactor: vertical ? null : 1,
        heightFactor: vertical ? 1 : null,
        child: CustomPaint(
          size: vertical
              ? const Size(_arrowWidth, _arrowLength)
              : const Size(_arrowLength, _arrowWidth),
          painter: _ArrowPainter(
            color: colors.surfaceHigh,
            direction: direction,
          ),
        ),
      ),
    );

    return switch (direction) {
      AxisDirection.up => IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [pointer, bubble],
        ),
      ),
      AxisDirection.down => IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [bubble, pointer],
        ),
      ),
      AxisDirection.left => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pointer,
          Flexible(child: bubble),
        ],
      ),
      AxisDirection.right => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: bubble),
          pointer,
        ],
      ),
    };
  }
}

/// Triangle pointing in [direction].
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color, required this.direction});

  final Color color;
  final AxisDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = switch (direction) {
      AxisDirection.up =>
        Path()
          ..moveTo(0, h)
          ..lineTo(w / 2, 0)
          ..lineTo(w, h),
      AxisDirection.down =>
        Path()
          ..moveTo(0, 0)
          ..lineTo(w / 2, h)
          ..lineTo(w, 0),
      AxisDirection.left =>
        Path()
          ..moveTo(w, 0)
          ..lineTo(0, h / 2)
          ..lineTo(w, h),
      AxisDirection.right =>
        Path()
          ..moveTo(0, 0)
          ..lineTo(w, h / 2)
          ..lineTo(0, h),
    };
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.color != color || old.direction != direction;
}
