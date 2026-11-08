// Frame of a Settings page: back button, centered title and the content below.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;

  /// A header button at the right (e.g. "+"); without it the title stays
  /// centered by an empty space of the same size.
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SossoldiSpacing.l),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.l,
              children: [
                Row(
                  children: [
                    SossoldiHeaderButton(
                      icon: PhosphorIconsRegular.arrowLeft,
                      semanticLabel: context.l10n.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.typography.titleMedium.copyWith(
                          color: colors.textHigh,
                        ),
                      ),
                    ),
                    // Keeps the title centered.
                    trailing ??
                        const SizedBox(width: SossoldiHeaderButton.size),
                  ],
                ),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The blue "+" of the header of a management page (Accounts), for the pages
/// whose "+" does one thing. Categories asks for a type first (a popover).
class SettingsAddButton extends StatelessWidget {
  const SettingsAddButton({
    super.key,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SossoldiHeaderButton(
    icon: PhosphorIconsRegular.plus,
    filled: true,
    semanticLabel: semanticLabel,
    onPressed: onPressed,
  );
}
