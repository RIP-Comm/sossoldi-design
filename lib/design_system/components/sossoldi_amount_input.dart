// Amount input: the big number at the top of the form of a transaction. A
// fixed prefix (the "−" of an expense, which cannot be deleted), the number
// and the currency, with the system numeric keyboard. Not in Figma: built
// from the tokens of the text input and the headline type.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';

class SossoldiAmountInput extends StatelessWidget {
  const SossoldiAmountInput({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.focusNode,
    this.prefix,
    this.color,
    this.errorText,
    this.autofocus = false,
    this.placeholder = '0',
    this.semanticLabel,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Currency shown after the number.
  final String currencySymbol;

  /// Fixed text before the number (e.g. "−"); null for none.
  final String? prefix;

  /// Color of the prefix and the number; defaults to the high text color.
  final Color? color;
  final String? errorText;
  final bool autofocus;
  final String placeholder;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.typography.headlineLarge.copyWith(
      color: errorText != null ? colors.error.text : (color ?? colors.textHigh),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xs,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (prefix != null) Text(prefix!, style: style),
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: Material(
                  type: MaterialType.transparency,
                  child: Semantics(
                    label: semanticLabel,
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      textAlign: TextAlign.center,
                      style: style,
                      cursorColor: colors.shapeHigh,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration.collapsed(
                        hintText: placeholder,
                        hintStyle: style.copyWith(color: colors.textLow),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: SossoldiSpacing.xs),
            Text(currencySymbol, style: style.copyWith(color: colors.textMed)),
          ],
        ),
        if (errorText != null)
          Text(
            errorText!,
            textAlign: TextAlign.center,
            style: context.typography.labelMedium.copyWith(
              color: colors.error.text,
            ),
          ),
      ],
    );
  }
}
