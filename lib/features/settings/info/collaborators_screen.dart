// Settings > Info > Collaborators: the people who contributed, one row each
// with the kind of link on the right (GitHub, personal site, LinkedIn). Not in
// Figma: built from the menu item and the Settings page.

import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../settings_page.dart';
import 'collaborator.dart';

class CollaboratorsScreen extends StatelessWidget {
  const CollaboratorsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CollaboratorsScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return SettingsPage(
      title: l10n.infoCollaborators,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SossoldiSpacing.xs,
          children: [
            Text(
              l10n.collaboratorsIntroTitle,
              style: typography.titleMedium.copyWith(color: colors.textHigh),
            ),
            Text(
              l10n.collaboratorsIntro,
              style: typography.bodyMedium.copyWith(color: colors.textMed),
            ),
          ],
        ),
        SossoldiList(
          children: [
            for (final person in collaborators)
              SossoldiMenuItem(
                label: person.name,
                subtitle: person.role,
                trailing: Icon(
                  person.type.icon,
                  size: 24,
                  color: colors.textHigh,
                ),
                onTap: () => openExternalLink(person.url),
              ),
          ],
        ),
      ],
    );
  }
}
