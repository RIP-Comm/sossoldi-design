// Settings hub: two rows, App settings and Prototype settings. The entry point
// (the gear of the Dashboard) opens this screen; each page is a screen of its own.

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'app_settings_screen.dart';
import 'prototype_settings_screen.dart';
import 'settings_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsPage(
      title: l10n.settings,
      children: [
        SossoldiList(
          children: [
            SossoldiMenuItem(
              label: l10n.settingsAppSettings,
              hasSubitems: true,
              onTap: () =>
                  Navigator.of(context).push(AppSettingsScreen.route()),
            ),
            SossoldiMenuItem(
              label: l10n.settingsPrototypeSettings,
              hasSubitems: true,
              onTap: () =>
                  Navigator.of(context).push(PrototypeSettingsScreen.route()),
            ),
          ],
        ),
      ],
    );
  }
}
