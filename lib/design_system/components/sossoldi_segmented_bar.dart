// Segmented bar, from the Figma "Categories total" bar (node 13:4755): the
// whole bar is the total budget; the colored part is what has been spent,
// split in one stretch per category in the category's color; what is not
// spent is left in one neutral color. A stretch of a category that went
// over its own limit has the error outline.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';

class SossoldiBarSegment {
  const SossoldiBarSegment({
    required this.share,
    required this.color,
    this.exceeded = false,
  });

  /// Width of the stretch as a fraction of the whole bar, 0 to 1. The
  /// shares add up to at most 1; the rest is the neutral part.
  final double share;
  final Color color;
  final bool exceeded;
}

class SossoldiSegmentedBar extends StatelessWidget {
  const SossoldiSegmentedBar({
    super.key,
    required this.segments,
    this.semanticLabel,
  });

  final List<SossoldiBarSegment> segments;
  final String? semanticLabel;

  static const double height = 8;
  static const double outline = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bar = SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SegmentedPainter(
          segments: segments,
          track: colors.surfaceLow,
          error: colors.error.stroke,
        ),
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: bar)
        : Semantics(label: semanticLabel, image: true, child: bar);
  }
}

class _SegmentedPainter extends CustomPainter {
  _SegmentedPainter({
    required this.segments,
    required this.track,
    required this.error,
  });

  final List<SossoldiBarSegment> segments;
  final Color track;
  final Color error;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(SossoldiRadius.max),
    );
    canvas.drawRRect(shape, Paint()..color = track);
    canvas.save();
    canvas.clipRRect(shape);
    var x = 0.0;
    for (final s in segments) {
      final width = (size.width * (s.share.isNaN ? 0.0 : s.share)).clamp(
        0.0,
        size.width - x,
      );
      if (width <= 0) continue;
      final part = Rect.fromLTWH(x, 0, width, size.height);
      canvas.drawRect(part, Paint()..color = s.color);
      if (s.exceeded) {
        canvas.drawRect(
          part.deflate(SossoldiSegmentedBar.outline / 2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = SossoldiSegmentedBar.outline
            ..color = error,
        );
      }
      x += width;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SegmentedPainter old) => true;
}
