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
  });

  /// Shown in the panel.
  final Widget content;

  /// The trigger.
  final Widget child;
  final double width;

  @override
  State<SossoldiPopover> createState() => _SossoldiPopoverState();
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
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, SossoldiSpacing.s),
            child: Align(
              alignment: Alignment.topLeft,
              child: TapRegion(
                groupId: _tapRegionGroup,
                child: SizedBox(
                  width: widget.width,
                  child: SossoldiDropdown.custom(child: widget.content),
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
