// Settings > Authentication: not designed yet. A screen of its own, so it can be opened
// from anywhere with AuthenticationSettingsScreen.route() and replaced by the real page later.

import 'package:flutter/material.dart';

import '../../app/placeholder_screen.dart';
import '../../l10n/l10n.dart';

class AuthenticationSettingsScreen extends StatelessWidget {
  const AuthenticationSettingsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() => MaterialPageRoute<void>(
    builder: (_) => const AuthenticationSettingsScreen(),
  );

  @override
  Widget build(BuildContext context) => PlaceholderScreen(
    title: context.l10n.settingsAuthentication,
    showBack: true,
  );
}
