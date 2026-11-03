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
  });

  /// Shown in the panel.
  final Widget content;

  /// The trigger.
  final Widget child;
  final double width;

  /// Opens above the trigger instead of below (for a trigger at the bottom
  /// of the screen, e.g. a floating toolbar). Not in Figma.
  final bool above;

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
            targetAnchor: widget.above
                ? Alignment.topLeft
                : Alignment.bottomLeft,
            followerAnchor: widget.above
                ? Alignment.bottomLeft
                : Alignment.topLeft,
            offset: Offset(
              0,
              widget.above ? -SossoldiSpacing.s : SossoldiSpacing.s,
            ),
            child: Align(
              alignment: widget.above
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
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
          child: SossoldiTappable(
            onTap: () => setState(_overlay.toggle),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
