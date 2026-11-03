// A page whose content scrolls under the status bar (and, on the Dashboard,
// the top bar), blurred there (not in Figma). The blur is progressive: none at
// the lower edge, strongest at the top, with no hard cut. The page must add
// the height of the area to the top padding of its scrolling content, so
// nothing starts hidden.

import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

/// The blur itself: fills its box, nothing at the bottom edge, [sigma] at the
/// top. Built from thin bands, each blurred a little less than the one above,
/// so the change from one band to the next cannot be seen.
class ProgressiveBlur extends StatelessWidget {
  const ProgressiveBlur({super.key, this.sigma = 16});

  final double sigma;

  static const _bands = 16;

  // Eased, so the blur starts gently and the steps stay tiny.
  double _sigmaAt(int i) {
    final t = (_bands - i) / _bands;
    return sigma * t * t;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          for (var i = 0; i < _bands; i++)
            Expanded(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    // The first band is the strongest, the last almost none.
                    sigmaX: _sigmaAt(i),
                    sigmaY: _sigmaAt(i),
                    tileMode: TileMode.clamp,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TopBlur extends StatelessWidget {
  const TopBlur({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top,
          child: const ProgressiveBlur(),
        ),
      ],
    );
  }
}
