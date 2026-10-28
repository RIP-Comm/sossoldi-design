// Row of alerts you swipe, from Figma "Slider" (node 13:4520): one to three
// alerts with the page indicator under them. Used by the digests of Finance
// and Investments. Not tappable.

import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import 'sossoldi_alert.dart';
import 'sossoldi_page_indicator.dart';

class SossoldiAlertCarousel extends StatefulWidget {
  const SossoldiAlertCarousel({super.key, required this.alerts});

  final List<SossoldiAlert> alerts;

  @override
  State<SossoldiAlertCarousel> createState() => _SossoldiAlertCarouselState();
}

class _SossoldiAlertCarouselState extends State<SossoldiAlertCarousel> {
  /// Space between two alerts while swiping.
  static const double gap = SossoldiSpacing.m;

  final PageController _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page ?? 0;
      if (page != _page) setState(() => _page = page);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = widget.alerts;
    return Column(
      spacing: SossoldiSpacing.s,
      children: [
        // The row is as tall as the tallest message, so nothing below
        // moves when swiping: invisible copies of every alert size it.
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: [
                for (final a in alerts)
                  ExcludeSemantics(
                    child: IgnorePointer(child: Opacity(opacity: 0, child: a)),
                  ),
                Positioned.fill(
                  // Each page is the alert plus the space before the next
                  // one, so the alerts do not touch while swiping: the view
                  // is that much wider than the column (the space at the
                  // end of the last page is the margin of the screen).
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: width + gap,
                    maxWidth: width + gap,
                    child: PageView(
                      controller: _controller,
                      clipBehavior: Clip.none,
                      children: [
                        for (final a in alerts)
                          Padding(
                            padding: const EdgeInsets.only(right: gap),
                            child: a,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (alerts.length > 1)
          SossoldiPageIndicator(count: alerts.length, index: _page),
      ],
    );
  }
}
