import 'package:flutter/material.dart';

/// Shared tap behaviour for design system controls: pointer cursor,
/// keyboard focus, a subtle pressed state and button semantics.
/// The visual design lives in the child; this adds no decoration.
class SossoldiTappable extends StatefulWidget {
  const SossoldiTappable({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.selected,
    this.toggled,
  });

  /// Null disables the control.
  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;

  @override
  State<SossoldiTappable> createState() => _SossoldiTappableState();
}

class _SossoldiTappableState extends State<SossoldiTappable> {
  /// Opacity applied while pressed. Not in Figma: kept subtle on purpose.
  static const _pressedOpacity = 0.7;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: widget.toggled == null,
      enabled: enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onTap?.call(),
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: AnimatedOpacity(
            opacity: _pressed ? _pressedOpacity : 1,
            duration: const Duration(milliseconds: 100),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
