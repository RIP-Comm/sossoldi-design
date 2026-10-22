// Loader, from Figma component "Loader" (node 3:3726): a spinning arc for
// indeterminate waits.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

/// xs: 24px, md: 40px.
enum SossoldiLoaderSize { xs, md }

class SossoldiLoader extends StatefulWidget {
  const SossoldiLoader({
    super.key,
    this.size = SossoldiLoaderSize.xs,
    this.semanticLabel,
  });

  final SossoldiLoaderSize size;

  /// E.g. "Loading".
  final String? semanticLabel;

  @override
  State<SossoldiLoader> createState() => _SossoldiLoaderState();
}

class _SossoldiLoaderState extends State<SossoldiLoader>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (double box, double stroke) = switch (widget.size) {
      SossoldiLoaderSize.xs => (24, 2),
      SossoldiLoaderSize.md => (40, 4),
    };
    return Semantics(
      label: widget.semanticLabel,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          size: Size.square(box),
          painter: _ArcPainter(
            color: context.colors.primary.surface,
            strokeWidth: stroke,
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    // Figma: an arc of about a quarter turn on the left side.
    canvas.drawArc(
      rect,
      math.pi * 0.6,
      math.pi * 0.85,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
