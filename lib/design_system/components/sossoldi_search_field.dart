// Search field, from Figma component "Search" (States Default and Open,
// node 3:3782): a 40px input with a magnifying glass; while focused and
// with [results], the results open in a dropdown under the field.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_dropdown.dart';
import 'sossoldi_field_frame.dart';
import 'sossoldi_icon_button.dart';
import 'sossoldi_menu_item.dart';

class SossoldiSearchField extends StatefulWidget {
  const SossoldiSearchField({
    super.key,
    required this.placeholder,
    required this.clearSemanticLabel,
    this.controller,
    this.results = const [],
    this.onChanged,
    this.onResultTap,
  });

  final String placeholder;
  final String clearSemanticLabel;
  final TextEditingController? controller;

  /// Results for the current query, shown while the field is focused.
  final List<String> results;
  final ValueChanged<String>? onChanged;
  final ValueChanged<int>? onResultTap;

  @override
  State<SossoldiSearchField> createState() => _SossoldiSearchFieldState();
}

class _SossoldiSearchFieldState extends State<SossoldiSearchField> {
  TextEditingController? _ownController;
  final _focusNode = FocusNode();
  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _fieldKey = GlobalKey();
  final _tapRegionGroup = Object();

  /// A pointer is down on the results. On the web the field loses focus at
  /// that moment, and the results must not vanish before the tap ends.
  bool _pressingResults = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_sync);
    _controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(SossoldiSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_sync);
      _controller.addListener(_sync);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    if (!mounted) return;
    final show =
        (_focusNode.hasFocus || _pressingResults) && widget.results.isNotEmpty;
    if (show != _overlay.isShowing) {
      show ? _overlay.show() : _overlay.hide();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _focusNode.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final focused = _focusNode.hasFocus;

    final field = Container(
      key: _fieldKey,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.m),
      decoration: SossoldiFieldFrame.decoration(
        context,
        SossoldiFieldFrame.borderColor(
          context,
          enabled: true,
          focused: focused,
          hasValue: false,
          isError: false,
        ),
        shadows: _overlay.isShowing ? SossoldiShadows.m : null,
      ),
      child: Row(
        spacing: SossoldiSpacing.s,
        children: [
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 20,
            color: colors.textHigh,
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                style: typography.labelLarge.copyWith(color: colors.textHigh),
                cursorColor: colors.shapeHigh,
                cursorWidth: 1,
                decoration: InputDecoration.collapsed(
                  hintText: widget.placeholder,
                  hintStyle: typography.labelLarge.copyWith(
                    color: colors.textMed,
                  ),
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            SossoldiIconButton(
              icon: PhosphorIconsRegular.x,
              size: SossoldiIconButtonSize.xs,
              variant: SossoldiIconButtonVariant.neutral,
              semanticLabel: widget.clearSemanticLabel,
              onPressed: _clear,
            ),
        ],
      ),
    );

    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) => _focusNode.unfocus(),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: _buildResults,
          child: field,
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomLeft,
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapRegionGroup,
          child: Listener(
            onPointerDown: (_) => _pressingResults = true,
            onPointerUp: (_) => _releaseResults(),
            onPointerCancel: (_) => _releaseResults(),
            child: SizedBox(
              width: box?.size.width,
              child: SossoldiDropdown(
                options: [
                  for (final (i, result) in widget.results.indexed)
                    SossoldiMenuItem(
                      label: result,
                      onTap: () {
                        widget.onResultTap?.call(i);
                        _focusNode.unfocus();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _releaseResults() {
    // After the tap has been handled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pressingResults = false;
      _sync();
    });
  }
}
