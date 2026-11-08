// Settings > Prototype settings: the actions that only make sense in the
// prototype. They move between the demo data and the onboarding.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'settings_page.dart';
import 'widget_showcase_screen.dart';

class PrototypeSettingsScreen extends StatelessWidget {
  const PrototypeSettingsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const PrototypeSettingsScreen());

  /// Closes Settings (and anything above the app) and changes the data the
  /// app runs on: the app is built again on it.
  static void _switchData(
    BuildContext context,
    void Function(AppState) change,
  ) {
    final state = AppScope.read(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    change(state);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return SettingsPage(
      title: l10n.settingsPrototypeSettings,
      children: [
        SossoldiList(
          children: [
            SossoldiMenuItem(
              label: l10n.settingsRestartOnboarding,
              leading: Icon(
                PhosphorIconsRegular.arrowCounterClockwise,
                size: 24,
                color: colors.textHigh,
              ),
              onTap: () => _switchData(context, (s) => s.startOnboarding()),
            ),
            SossoldiMenuItem(
              label: l10n.settingsWidgetShowcase,
              leading: Icon(
                PhosphorIconsRegular.lightbulb,
                size: 24,
                color: colors.textHigh,
              ),
              hasSubitems: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WidgetShowcaseScreen(),
                ),
              ),
            ),
            SossoldiMenuItem(
              label: l10n.settingsLoadDemo,
              leading: Icon(
                PhosphorIconsRegular.database,
                size: 24,
                color: colors.textHigh,
              ),
              onTap: () => _switchData(context, (s) => s.loadDemoData()),
            ),
          ],
        ),
      ],
    );
  }
}
