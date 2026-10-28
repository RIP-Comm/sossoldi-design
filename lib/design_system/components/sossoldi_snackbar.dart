// Snackbar, from Figma component "Snackbar" (node 3:3902).
// Figma shows the Info type; the other types reuse the semantic roles.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_colors.dart';
import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';

enum SossoldiSnackbarType { info, success, warning, error }

class SossoldiSnackbar extends StatelessWidget {
  const SossoldiSnackbar({
    super.key,
    required this.title,
    this.description,
    this.type = SossoldiSnackbarType.info,
    this.icon,
    this.onClose,
    this.closeSemanticLabel,
  });

  final String title;
  final String? description;
  final SossoldiSnackbarType type;

  /// Defaults to an icon matching [type].
  final IconData? icon;

  /// Shows the close (X) button when not null.
  final VoidCallback? onClose;
  final String? closeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final (SossoldiColorRole role, IconData defaultIcon) = switch (type) {
      SossoldiSnackbarType.info => (colors.info, PhosphorIconsFill.info),
      SossoldiSnackbarType.success => (
        colors.success,
        PhosphorIconsFill.checkCircle,
      ),
      SossoldiSnackbarType.warning => (
        colors.warning,
        PhosphorIconsFill.warning,
      ),
      SossoldiSnackbarType.error => (colors.error, PhosphorIconsFill.xCircle),
    };

    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.s),
        ),
        shadows: SossoldiShadows.lg,
      ),
      child: Row(
        spacing: SossoldiSpacing.m,
        children: [
          Expanded(
            child: Row(
              spacing: SossoldiSpacing.s,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: ShapeDecoration(
                    color: role.surface,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(SossoldiRadius.s),
                    ),
                  ),
                  child: Icon(
                    icon ?? defaultIcon,
                    size: 24,
                    color: role.onSurface,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: typography.bodyBoldMedium.copyWith(
                          color: colors.textHigh,
                        ),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.labelSmall.copyWith(
                            color: colors.textMed,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            SossoldiIconButton(
              icon: PhosphorIconsRegular.x,
              variant: SossoldiIconButtonVariant.neutral,
              semanticLabel: closeSemanticLabel ?? '',
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

/// Shows a floating [SossoldiSnackbar] at the bottom of the screen.
void showSossoldiSnackbar(
  BuildContext context, {
  required String title,
  String? description,
  SossoldiSnackbarType type = SossoldiSnackbarType.info,
  String? closeSemanticLabel,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: SossoldiSnackbar(
        title: title,
        description: description,
        type: type,
        closeSemanticLabel: closeSemanticLabel,
        onClose: closeSemanticLabel == null
            ? null
            : messenger.hideCurrentSnackBar,
      ),
    ),
  );
}
