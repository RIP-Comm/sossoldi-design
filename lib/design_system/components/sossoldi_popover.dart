// Popover, from Figma component "Popover" (node 3:3751): free content in
// an elevated panel (same surface as Dropdown Custom), opened by tapping
// [child] and closed by tapping outside.

import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import 'sossoldi_dropdown.dart';
import 'sossoldi_tappable.dart';

class SossoldiPopover extends StatefulWidget {
  const SossoldiPopover({
    super.key,
    required this.content,
    required this.child,
    this.width = 304,
    this.above = false,
    this.alignEnd = false,
    this.flipBelow = 0,
  });

  /// Shown in the panel.
  final Widget content;

  /// The trigger.
  final Widget child;
  final double width;

  /// Opens above the trigger instead of below (for a trigger at the bottom
  /// of the screen, e.g. a floating toolbar). Not in Figma.
  final bool above;

  /// Aligns the panel to the right edge of the trigger instead of the left
  /// (for a trigger at the right of the screen). Not in Figma.
  final bool alignEnd;

  /// When the trigger has less than this much room below it (in logical
  /// pixels), the panel opens above instead. 0 turns it off. Not in Figma.
  final double flipBelow;

  /// Closes the popover that [context] (its content) is inside, if any.
  static void close(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PopoverScope>()?.close();

  @override
  State<SossoldiPopover> createState() => _SossoldiPopoverState();
}

/// Lets the content of a [SossoldiPopover] close it (e.g. after a choice).
class _PopoverScope extends InheritedWidget {
  const _PopoverScope({required this.close, required super.child});

  final VoidCallback close;

  @override
  bool updateShouldNotify(_PopoverScope old) => false;
}

class _SossoldiPopoverState extends State<SossoldiPopover> {
  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _tapRegionGroup = Object();
  bool _flipped = false;

  void _toggle() {
    if (!_overlay.isShowing && widget.flipBelow > 0) {
      final box = context.findRenderObject() as RenderBox;
      final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      _flipped = MediaQuery.sizeOf(context).height - bottom < widget.flipBelow;
    }
    setState(_overlay.toggle);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) => setState(_overlay.hide),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: (_) => CompositedTransformFollower(
            link: _link,
            targetAnchor: (widget.above || _flipped)
                ? (widget.alignEnd ? Alignment.topRight : Alignment.topLeft)
                : (widget.alignEnd
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft),
            followerAnchor: (widget.above || _flipped)
                ? (widget.alignEnd
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft)
                : (widget.alignEnd ? Alignment.topRight : Alignment.topLeft),
            offset: Offset(
              0,
              (widget.above || _flipped)
                  ? -SossoldiSpacing.s
                  : SossoldiSpacing.s,
            ),
            child: Align(
              alignment: (widget.above || _flipped)
                  ? (widget.alignEnd
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft)
                  : (widget.alignEnd ? Alignment.topRight : Alignment.topLeft),
              child: TapRegion(
                groupId: _tapRegionGroup,
                child: SizedBox(
                  width: widget.width,
                  child: _PopoverScope(
                    close: () => setState(_overlay.hide),
                    child: SossoldiDropdown.custom(child: widget.content),
                  ),
                ),
              ),
            ),
          ),
          child: SossoldiTappable(onTap: _toggle, child: widget.child),
        ),
      ),
    );
  }
}
