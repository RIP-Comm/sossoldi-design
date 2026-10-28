// Auth code (PIN), from Figma component "Auth_code" (node 3:3706):
// 4 or 6 boxes; typed digits are shown masked as dots.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class SossoldiAuthCode extends StatefulWidget {
  const SossoldiAuthCode({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autofocus = false,
    this.semanticLabel,
  }) : assert(length == 4 || length == 6, 'Figma has 4 or 6 fields');

  final int length;

  /// Called with the full code once every box is filled.
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  /// E.g. "PIN code".
  final String? semanticLabel;

  @override
  State<SossoldiAuthCode> createState() => _SossoldiAuthCodeState();
}

class _SossoldiAuthCodeState extends State<SossoldiAuthCode> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static const _mask = '•';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.typography.labelUppercaseBoldLarge.copyWith(
      color: colors.textHigh,
    );
    final filled = _controller.text.length;
    final focused = _focusNode.hasFocus;

    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusNode.requestFocus,
        child: Stack(
          children: [
            // Invisible field that receives the keyboard input.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.number,
                    maxLength: widget.length,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onChanged,
                    decoration: const InputDecoration.collapsed(hintText: null)
                        .copyWith(counterText: ''),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: SossoldiSpacing.s,
                children: [
                  for (var i = 0; i < widget.length; i++)
                    Container(
                      width: 46,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: colors.surfaceHigh,
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(SossoldiRadius.s),
                          side: BorderSide(
                            // The box waiting for input is highlighted while
                            // focused (not in Figma).
                            color: focused && i == filled
                                ? colors.primary.stroke
                                : colors.strokeMinus1,
                          ),
                        ),
                      ),
                      child: Text(i < filled ? _mask : '', style: style),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
