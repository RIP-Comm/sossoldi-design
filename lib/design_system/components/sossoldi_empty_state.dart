// Empty state: an icon, a title, a short hint and an optional action.
// Not in Figma (proposed): built from the app's own tokens.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_button.dart';

class SossoldiEmptyState extends StatelessWidget {
  const SossoldiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// The button is shown only when both [actionLabel] and [onAction] are set.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SossoldiSpacing.xl,
        vertical: SossoldiSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.s,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: colors.textMed),
          ),
          const SizedBox(height: SossoldiSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: typography.titleMedium.copyWith(color: colors.textHigh),
          ),
          if (message != null)
            Text(
              message!,
              textAlign: TextAlign.center,
              style: typography.labelMedium.copyWith(color: colors.textMed),
            ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: SossoldiSpacing.s),
            SossoldiButton(
              label: actionLabel!,
              type: SossoldiButtonType.outline,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
