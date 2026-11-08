// Settings > Budgets: not designed yet. A screen of its own, so it can be opened
// from anywhere with BudgetsSettingsScreen.route() and replaced by the real page later.

import 'package:flutter/material.dart';

import '../../app/placeholder_screen.dart';
import '../../l10n/l10n.dart';

class BudgetsSettingsScreen extends StatelessWidget {
  const BudgetsSettingsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const BudgetsSettingsScreen());

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: context.l10n.settingsBudgets, showBack: true);
}
