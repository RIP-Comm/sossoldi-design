import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../design_system/design_system.dart';
import '../l10n/l10n.dart';

/// Stand-in for screens that are not built yet: a title and "Coming soon".
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.showBack = false,
  });

  final String title;

  /// Shows a back button, for screens pushed on top of the shell.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SossoldiSpacing.l,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SossoldiHeaderButton(
                    icon: PhosphorIconsRegular.arrowLeft,
                    semanticLabel: context.l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: SossoldiSpacing.xs,
                  children: [
                    Text(
                      title,
                      style: typography.headlineSmall.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                    Text(
                      context.l10n.comingSoon,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
