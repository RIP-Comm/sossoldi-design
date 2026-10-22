// Text input, from Figma component "Text input" (node 3:4002).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.
// Figma states map to: Default (empty), Active (focused), Filled (has text),
// Error ([errorText] set), Disabled ([enabled] false).

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_field_frame.dart';
import 'sossoldi_icon_button.dart';

class SossoldiTextInput extends StatefulWidget {
  const SossoldiTextInput({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.icon,
    this.clearSemanticLabel,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;

  /// Supporting text under the field.
  final String? helperText;

  /// Puts the field in the error state and replaces [helperText].
  final String? errorText;
  final IconData? icon;

  /// Shows the clear (X) button while the field has text.
  /// Also used as its screen reader label.
  final String? clearSemanticLabel;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SossoldiTextInput> createState() => _SossoldiTextInputState();
}

class _SossoldiTextInputState extends State<SossoldiTextInput> {
  TextEditingController? _ownController;
  final _focusNode = FocusNode();

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(SossoldiTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_rebuild);
      _controller.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
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
    final isError = widget.errorText != null;
    final hasText = _controller.text.isNotEmpty;
    final border = SossoldiFieldFrame.borderColor(
      context,
      enabled: widget.enabled,
      focused: _focusNode.hasFocus,
      hasValue: hasText,
      isError: isError,
    );
    final contentColor = widget.enabled ? colors.textHigh : colors.textLow;

    return SossoldiFieldFrame(
      label: widget.label,
      helperText: widget.errorText ?? widget.helperText,
      isError: isError,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SossoldiSpacing.m,
          vertical: SossoldiSpacing.l,
        ),
        decoration: SossoldiFieldFrame.decoration(context, border),
        child: Row(
          spacing: SossoldiSpacing.s,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, size: 20, color: contentColor),
            Expanded(
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: typography.labelLarge.copyWith(color: contentColor),
                  cursorColor: colors.shapeHigh,
                  cursorWidth: 1,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.placeholder,
                    hintStyle: typography.labelLarge.copyWith(
                      color: widget.enabled ? colors.textMed : colors.textLow,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.clearSemanticLabel != null && hasText)
              SossoldiIconButton(
                icon: PhosphorIconsRegular.x,
                size: SossoldiIconButtonSize.xs,
                variant: isError
                    ? SossoldiIconButtonVariant.primary
                    : SossoldiIconButtonVariant.neutral,
                semanticLabel: widget.clearSemanticLabel!,
                onPressed: widget.enabled ? _clear : null,
              ),
          ],
        ),
      ),
    );
  }
}
