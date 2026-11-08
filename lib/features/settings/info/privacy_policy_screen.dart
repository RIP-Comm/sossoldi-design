// Settings > Info > Privacy policy: plain text, left aligned, a title per
// section. Not in Figma: the text of the Alpha 1.0 policy, with the hierarchy
// of the design system's typography.

import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../settings_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    Widget title(String text) => Text(
      text,
      style: typography.titleMedium.copyWith(color: colors.textHigh),
    );
    Widget body(String text) => Text(
      text,
      style: typography.bodyLarge.copyWith(color: colors.textHigh),
    );
    // A title and its text stay closer than the sections are to each other.
    Widget section(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SossoldiSpacing.s,
      children: children,
    );
    return SettingsPage(
      title: l10n.infoPrivacyPolicy,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SossoldiSpacing.l,
          children: [
            body(l10n.privacyIntro),
            section([
              title(l10n.privacyCollectTitle),
              body(l10n.privacyCollectBody),
            ]),
            section([
              title(l10n.privacyChangesTitle),
              body(l10n.privacyChangesBody),
              body(l10n.privacyEffective),
            ]),
            section([
              title(l10n.privacyContactTitle),
              body(l10n.privacyContactBody),
              SossoldiTappable(
                onTap: () => openExternalLink('mailto:${AppInfo.contactEmail}'),
                semanticLabel: AppInfo.contactEmail,
                child: Text(
                  AppInfo.contactEmail,
                  style: typography.bodyLarge.copyWith(
                    color: colors.primary.text,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.primary.text,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
