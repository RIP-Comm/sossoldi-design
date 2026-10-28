// The monogram of Sossoldi, put together from the five pieces of the Figma
// "Monogramma dark" (node 13:3325): the two bars of the dollar, their ends and
// the S. It is dark blue; on a dark surface it takes the color it is given.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SossoldiLogo extends StatelessWidget {
  const SossoldiLogo({
    super.key,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
  });

  /// Paints the logo in this color (on dark surfaces); null keeps the blue of
  /// the design.
  final Color? color;

  /// The color of the surface behind: the pieces are cut out of each other
  /// with a thin line of it. Null keeps the light grey of the design.
  final Color? backgroundColor;
  final String? semanticLabel;

  /// The two colors of the drawing.
  static const _ink = Color(0xFF002855);
  static const _cutout = Color(0xFFF1F5F9);

  /// Size of the monogram in Figma.
  static const double width = 72.891;
  static const double height = 110;

  // Where each piece goes in the 72.891 x 110 box (left, top, right, bottom).
  static const _pieces = [
    ('part_1', 0.0, 5.85, 0.0, 5.5805),
    ('part_2', 25.447, 0.0, 39.088, 99.56),
    ('part_3', 25.447, 18.964, 39.088, 0.0),
    ('part_4', 38.814, 0.0, 25.72, 18.99),
    ('part_5', 38.814, 99.594, 25.72, -0.011),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (name, left, top, right, bottom) in _pieces)
              Positioned(
                left: left,
                top: top,
                right: right,
                bottom: bottom,
                child: SvgPicture.asset(
                  'assets/images/logo/$name.svg',
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                  colorMapper: _LogoColors(
                    ink: color ?? _ink,
                    cutout: backgroundColor ?? _cutout,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Swaps the two colors of the drawing.
class _LogoColors extends ColorMapper {
  const _LogoColors({required this.ink, required this.cutout});

  final Color ink;
  final Color cutout;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == SossoldiLogo._ink) return ink;
    if (color == SossoldiLogo._cutout) return cutout;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _LogoColors && other.ink == ink && other.cutout == cutout;

  @override
  int get hashCode => Object.hash(ink, cutout);
}
