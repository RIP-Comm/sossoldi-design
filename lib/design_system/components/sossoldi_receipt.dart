// Receipt: a card with a zigzag bottom edge, like a till receipt, for the
// page of a transaction. Not in Figma: built from tokens (surfaceHigh with a
// soft shadow that follows the teeth). The child gets the padding.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class SossoldiReceipt extends StatelessWidget {
  const SossoldiReceipt({super.key, required this.child});

  final Widget child;

  /// Width of one tooth and its depth.
  static const double toothWidth = 14;
  static const double toothDepth = 7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      painter: _ReceiptPainter(
        color: colors.surfaceHigh,
        shadow: colors.textHigh.withValues(alpha: 0.12),
      ),
      child: ClipPath(
        clipper: const _ReceiptClipper(),
        child: Padding(
          padding: const EdgeInsets.only(
            left: SossoldiSpacing.l,
            right: SossoldiSpacing.l,
            top: SossoldiSpacing.xl,
            bottom: SossoldiSpacing.xl + toothDepth,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The outline: rounded top corners, straight sides, a zigzag at the bottom
/// with a whole number of teeth.
Path _receiptPath(Size size) {
  const depth = SossoldiReceipt.toothDepth;
  final radius = SossoldiRadius.l;
  final teeth = (size.width / SossoldiReceipt.toothWidth).round().clamp(2, 200);
  final tooth = size.width / teeth;
  final base = size.height - depth;
  final path = Path()
    ..moveTo(0, radius)
    ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
    ..lineTo(size.width - radius, 0)
    ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
    ..lineTo(size.width, base);
  for (var i = 0; i < teeth; i++) {
    final x = size.width - i * tooth;
    path
      ..lineTo(x - tooth / 2, size.height)
      ..lineTo(x - tooth, base);
  }
  return path..close();
}

class _ReceiptClipper extends CustomClipper<Path> {
  const _ReceiptClipper();

  @override
  Path getClip(Size size) => _receiptPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ReceiptPainter extends CustomPainter {
  _ReceiptPainter({required this.color, required this.shadow});

  final Color color;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _receiptPath(size);
    canvas.drawShadow(path, shadow, 3, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ReceiptPainter old) =>
      old.color != color || old.shadow != shadow;
}
