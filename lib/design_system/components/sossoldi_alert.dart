// Alert (banner), from Figma component "Alert" (node 3:4304): a non-modal
// message with optional icon, title and close button.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';

/// The color of an alert. Neutral is the Figma component (white); the other
/// ones tint it with the state color (fill, border and text), as in the
/// Finance Overview digest.
enum SossoldiAlertTone { neutral, info, success, warning, error }

class SossoldiAlert extends StatelessWidget {
  const SossoldiAlert({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.tone = SossoldiAlertTone.neutral,
    this.onClose,
    this.closeSemanticLabel,
  });

  /// The text; what is between "**" marks is bold.
  final String message;
  final String? title;
  final IconData? icon;
  final SossoldiAlertTone tone;

  /// Shows the close (X) button when not null.
  final VoidCallback? onClose;
  final String? closeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final role = switch (tone) {
      SossoldiAlertTone.neutral => null,
      SossoldiAlertTone.info => colors.info,
      SossoldiAlertTone.success => colors.success,
      SossoldiAlertTone.warning => colors.warning,
      SossoldiAlertTone.error => colors.error,
    };
    final titleColor = role?.text ?? colors.textHigh;
    // The text of the body always takes the semantic color.
    final bodyColor = role?.text ?? colors.textHigh;
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: 24, color: titleColor);
    final close = onClose == null
        ? null
        : SossoldiIconButton(
            icon: PhosphorIconsRegular.x,
            size: SossoldiIconButtonSize.xs,
            variant: SossoldiIconButtonVariant.neutral,
            semanticLabel: closeSemanticLabel ?? '',
            onPressed: onClose,
          );
    final bodyStyle = typography.bodyMedium.copyWith(color: bodyColor);
    // "**text**" in the message is shown in bold (the numbers of a digest).
    final parts = message.split('**');
    final body = Text.rich(
      TextSpan(
        style: bodyStyle,
        children: [
          for (final (i, part) in parts.indexed)
            if (part.isNotEmpty)
              TextSpan(
                text: part,
                style: i.isOdd
                    ? bodyStyle.copyWith(fontWeight: FontWeight.w700)
                    : null,
              ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.m,
        vertical: SossoldiSpacing.s,
      ),
      decoration: ShapeDecoration(
        color: role?.surface ?? colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
          side: role == null ? BorderSide.none : BorderSide(color: role.stroke),
        ),
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
                    children: [
                      Row(
                        spacing: SossoldiSpacing.s,
                        children: [
                          ?iconWidget,
                          Expanded(
                            child: Text(
                              title!,
                              style: typography.labelBoldLarge.copyWith(
                                color: titleColor,
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
