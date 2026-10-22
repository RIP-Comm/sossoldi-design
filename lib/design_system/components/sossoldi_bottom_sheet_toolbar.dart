// Bottom sheet toolbar, from Figma component "Bottomsheet tollbar"
// (node 3:5651): title with close/confirm actions, as icons or as text.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

class SossoldiBottomSheetToolbar extends StatelessWidget {
  /// Type=Icon: round X on the left, round check on the right.
  const SossoldiBottomSheetToolbar.icon({
    super.key,
    required this.title,
    required this.onClose,
    required String this.closeSemanticLabel,
    this.onConfirm,
    this.confirmSemanticLabel,
  }) : closeLabel = null,
       confirmLabel = null;

  /// Type=text: "Cancel" on the left, "Done" on the right.
  const SossoldiBottomSheetToolbar.text({
    super.key,
    required this.title,
    required this.onClose,
    required String this.closeLabel,
    this.onConfirm,
    this.confirmLabel,
  }) : closeSemanticLabel = null,
       confirmSemanticLabel = null;

  final String title;
  final VoidCallback? onClose;

  /// Hides the right action when null.
  final VoidCallback? onConfirm;
  final String? closeLabel;
  final String? confirmLabel;
  final String? closeSemanticLabel;
  final String? confirmSemanticLabel;

  static const double _height = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: typography.titleMedium.copyWith(color: colors.textHigh),
    );

    if (closeLabel == null) {
      Widget circle(
        IconData icon,
        Color background,
        Color foreground,
        VoidCallback? onTap,
        String? label,
      ) => SossoldiTappable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          width: _height,
          height: _height,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 24, color: foreground),
        ),
      );
      return SizedBox(
        height: _height,
        child: Row(
          children: [
            circle(
              PhosphorIconsRegular.x,
              colors.surfaceLow,
              colors.textHigh,
              onClose,
              closeSemanticLabel,
            ),
            Expanded(child: titleText),
            if (onConfirm != null)
              circle(
                PhosphorIconsRegular.check,
                colors.primary.surface,
                colors.primary.onSurface,
                onConfirm,
                confirmSemanticLabel,
              )
            else
              const SizedBox(width: _height),
          ],
        ),
      );
    }

    Widget textAction(String label, Color color, VoidCallback? onTap) =>
        SossoldiTappable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SossoldiSpacing.s,
              vertical: SossoldiSpacing.xs,
            ),
            child: Text(
              label,
              style: typography.labelBoldLarge.copyWith(color: color),
            ),
          ),
        );

    return Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.s),
      child: Row(
        spacing: SossoldiSpacing.xs,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: textAction(closeLabel!, colors.textMed, onClose),
            ),
          ),
          // Left and right share the remaining width equally, so the
          // title stays centered.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: titleText,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: onConfirm == null || confirmLabel == null
                  ? null
                  : textAction(confirmLabel!, colors.primary.text, onConfirm),
            ),
          ),
        ],
      ),
    );
  }
}
