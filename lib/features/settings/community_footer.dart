// Footer of App settings: "Open source, built by the community" with the icons
// of GitHub, LinkedIn, YouTube and Discord, each opening its page.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_info.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

class CommunityFooter extends StatelessWidget {
  const CommunityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    Widget link(IconData icon, String label, String url) => SossoldiTappable(
      onTap: () => openExternalLink(url),
      semanticLabel: label,
      child: Padding(
        padding: const EdgeInsets.all(SossoldiSpacing.s),
        child: Icon(icon, size: 32, color: colors.textHigh),
      ),
    );
    return Column(
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          l10n.communityFooter,
          textAlign: TextAlign.center,
          style: context.typography.labelLarge.copyWith(color: colors.textMed),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: SossoldiSpacing.m,
          children: [
            link(PhosphorIconsFill.githubLogo, l10n.linkGithub, AppInfo.github),
            link(
              PhosphorIconsFill.linkedinLogo,
              l10n.linkLinkedin,
              AppInfo.linkedin,
            ),
            link(
              PhosphorIconsFill.youtubeLogo,
              l10n.linkYoutube,
              AppInfo.youtube,
            ),
            link(
              PhosphorIconsFill.discordLogo,
              l10n.linkDiscord,
              AppInfo.discord,
            ),
          ],
        ),
      ],
    );
  }
}
