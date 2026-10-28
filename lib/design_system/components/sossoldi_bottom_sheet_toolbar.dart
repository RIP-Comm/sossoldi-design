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
    this.confirmEnabled = true,
  }) : closeLabel = null,
       confirmLabel = null,
       closeIcon = null;

  /// Type=text: "Cancel" on the left, "Done" on the right.
  const SossoldiBottomSheetToolbar.text({
    super.key,
    required this.title,
    required this.onClose,
    required String this.closeLabel,
    this.onConfirm,
    this.confirmLabel,
    this.closeIcon,
  }) : closeSemanticLabel = null,
       confirmSemanticLabel = null,
       confirmEnabled = true;

  final String title;
  final VoidCallback? onClose;

  /// Hides the right action when null.
  final VoidCallback? onConfirm;
  final String? closeLabel;
  final String? confirmLabel;

  /// Text variant only: icon before the left label (e.g. an arrow for
  /// "Back").
  final IconData? closeIcon;
  final String? closeSemanticLabel;
  final String? confirmSemanticLabel;

  /// Icon variant: false shows the check greyed out and does nothing (the
  /// Figma disabled state, for a form that is not valid yet).
  final bool confirmEnabled;

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
                confirmEnabled
                    ? colors.primary.surface
                    : colors.disabledSurface,
                confirmEnabled
                    ? colors.primary.onSurface
                    : colors.disabledOnSurface,
                confirmEnabled ? onConfirm : null,
                confirmSemanticLabel,
              )
            else
              const SizedBox(width: _height),
          ],
        ),
      );
    }

    Widget textAction(
      String label,
      Color color,
      VoidCallback? onTap, {
      IconData? icon,
    }) => SossoldiTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SossoldiSpacing.s,
          vertical: SossoldiSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SossoldiSpacing.xs,
          children: [
            if (icon != null) Icon(icon, size: 16, color: color),
            Text(
              label,
              style: typography.labelBoldLarge.copyWith(color: color),
            ),
          ],
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
            // Scales down a hair if the title leaves too little room.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: textAction(
                closeLabel!,
                colors.textMed,
                onClose,
                icon: closeIcon,
              ),
            ),
          ),
          // Left and right share the remaining width equally, so the
          // title stays centered.
          // With a leading icon the left action is wider, so the title gets
          // less room to stay centered.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: closeIcon == null ? 200 : 150,
            ),
            child: titleText,
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: onConfirm == null || confirmLabel == null
                  ? const SizedBox()
                  : textAction(confirmLabel!, colors.primary.text, onConfirm),
            ),
          ),
        ],
      ),
    );
  }
}
