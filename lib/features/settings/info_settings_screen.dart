// Settings > Info: version, the team, the link to contribute and the privacy
// policy. A screen of its own, so it can be opened from anywhere with
// InfoSettingsScreen.route().

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_info.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'info/collaborators_screen.dart';
import 'info/privacy_policy_screen.dart';
import 'settings_page.dart';

class InfoSettingsScreen extends StatelessWidget {
  const InfoSettingsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const InfoSettingsScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return SettingsPage(
      title: l10n.settingsInfo,
      children: [
        SossoldiList(
          children: [
            SossoldiMenuItem(
              label: l10n.infoAppVersion,
              subtitle: AppInfo.version,
            ),
            SossoldiMenuItem(
              label: l10n.infoCollaborators,
              subtitle: l10n.infoCollaboratorsSubtitle,
              hasSubitems: true,
              onTap: () =>
                  Navigator.of(context).push(CollaboratorsScreen.route()),
            ),
            SossoldiMenuItem(
              label: l10n.infoContribute,
              subtitle: l10n.infoContributeSubtitle,
              trailing: Icon(
                PhosphorIconsRegular.arrowSquareOut,
                size: 20,
                color: colors.textHigh,
              ),
              onTap: () => openExternalLink(AppInfo.github),
            ),
            SossoldiMenuItem(
              label: l10n.infoPrivacyPolicy,
              hasSubitems: true,
              onTap: () =>
                  Navigator.of(context).push(PrivacyPolicyScreen.route()),
            ),
          ],
        ),
      ],
    );
  }
}
