// Alert (banner), from Figma component "Alert" (node 3:4304): a non-modal
// message with optional icon, title and close button.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';

class SossoldiAlert extends StatelessWidget {
  const SossoldiAlert({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onClose,
    this.closeSemanticLabel,
  });

  final String message;
  final String? title;
  final IconData? icon;

  /// Shows the close (X) button when not null.
  final VoidCallback? onClose;
  final String? closeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: 24, color: colors.textHigh);
    final close = onClose == null
        ? null
        : SossoldiIconButton(
            icon: PhosphorIconsRegular.x,
            size: SossoldiIconButtonSize.xs,
            variant: SossoldiIconButtonVariant.neutral,
            semanticLabel: closeSemanticLabel ?? '',
            onPressed: onClose,
          );
    final body = Text(
      message,
      style: typography.bodyMedium.copyWith(color: colors.textHigh),
    );

    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiRadius.s),
      ),
      child: title == null
          ? Row(
              spacing: SossoldiSpacing.m,
              children: [
                ?iconWidget,
                Expanded(child: body),
                ?close,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SossoldiSpacing.m,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: SossoldiSpacing.s,
                    children: [
                      Row(
                        spacing: SossoldiSpacing.s,
                        children: [
                          ?iconWidget,
                          Expanded(
                            child: Text(
                              title!,
                              style: typography.titleSmall.copyWith(
                                color: colors.textHigh,
                              ),
                            ),
                          ),
                        ],
                      ),
                      body,
                    ],
                  ),
                ),
                ?close,
              ],
            ),
    );
  }
}
