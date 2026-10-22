// Shows a SossoldiTooltip above [child] on tap, long press or hover, and
// hides it after a few seconds, on a tap outside or when the mouse leaves. Near the screen edges
// the tooltip aligns to that side (with a corner arrow) so it stays visible.

import 'dart:async';

import 'package:flutter/material.dart';

import 'sossoldi_tooltip.dart';

class SossoldiTooltipTarget extends StatefulWidget {
  const SossoldiTooltipTarget({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  /// Maximum tooltip width.
  static const double maxWidth = 280;

  @override
  State<SossoldiTooltipTarget> createState() => _SossoldiTooltipTargetState();
}

class _SossoldiTooltipTargetState extends State<SossoldiTooltipTarget> {
  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _targetKey = GlobalKey();
  final _tapRegionGroup = Object();
  Timer? _hideTimer;

  void _show() {
    _hideTimer?.cancel();
    setState(_overlay.show);
    _hideTimer = Timer(const Duration(seconds: 3), _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (mounted && _overlay.isShowing) setState(_overlay.hide);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Which side the tooltip aligns to, based on where the target sits.
  (Alignment target, Alignment follower, SossoldiTooltipArrow arrow) _placement(
    BuildContext overlayContext,
  ) {
    const middle = (
      Alignment.topCenter,
      Alignment.bottomCenter,
      SossoldiTooltipArrow.bottomMiddle,
    );
    final box = _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return middle;
    final center = box.localToGlobal(box.size.center(Offset.zero)).dx;
    final screenWidth = MediaQuery.sizeOf(overlayContext).width;
    const half = SossoldiTooltipTarget.maxWidth / 2;
    if (center < half) {
      return (
        Alignment.topLeft,
        Alignment.bottomLeft,
        SossoldiTooltipArrow.bottomLeft,
      );
    }
    if (center > screenWidth - half) {
      return (
        Alignment.topRight,
        Alignment.bottomRight,
        SossoldiTooltipArrow.bottomRight,
      );
    }
    return middle;
  }

  Widget _buildTooltip(BuildContext context) {
    final (target, follower, arrow) = _placement(context);
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: target,
      followerAnchor: follower,
      offset: const Offset(0, -4),
      // Sized to the bubble: a full-screen box anchored by its bottom
      // would start above the screen and may not be painted.
      child: Align(
        alignment: follower,
        widthFactor: 1,
        heightFactor: 1,
        child: TapRegion(
          groupId: _tapRegionGroup,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SossoldiTooltipTarget.maxWidth,
            ),
            child: SossoldiTooltip(message: widget.message, arrow: arrow),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: TapRegion(
        groupId: _tapRegionGroup,
        onTapOutside: (_) => _hide(),
        child: CompositedTransformTarget(
          key: _targetKey,
          link: _link,
          child: OverlayPortal(
            controller: _overlay,
            overlayChildBuilder: _buildTooltip,
            child: MouseRegion(
              onEnter: (_) => _show(),
              onExit: (_) => _hide(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Tap only opens: with a mouse the pointer has just entered
                // and opened it, so toggling here would close it again.
                onTap: _show,
                onLongPress: _show,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
