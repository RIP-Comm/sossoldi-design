// Frame of a Settings page: back button, centered title and the content below.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.title, required this.children});

  final String title;
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
