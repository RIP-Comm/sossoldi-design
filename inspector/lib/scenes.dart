// The screens the left menu opens directly, without navigating the app.
// To add one: an entry in [sceneGroups] with the AppEntry that opens it.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app_entry.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/features/add_transaction/add_sheet.dart';
import 'package:sossoldi/features/add_transaction/add_sheet_draft.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/investments/investments_controller.dart';
import 'package:sossoldi/features/settings/settings_screen.dart';

class Scene {
  const Scene({
    required this.id,
    required this.title,
    this.entry = const AppEntry(),
    this.onboarding = false,
  });

  final String id;
  final String title;
  final AppEntry entry;

  /// Opens the onboarding (on the empty data of a new user) instead of the app.
  final bool onboarding;

  /// Prepares the state the app starts on.
  void prepare(AppState state) {
    if (onboarding) state.startOnboarding();
  }
}

class SceneGroup {
  const SceneGroup(this.title, this.icon, this.scenes);

  final String title;
  final IconData icon;
  final List<Scene> scenes;
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

final sceneGroups = <SceneGroup>[
  SceneGroup('Home', PhosphorIconsRegular.house, [
    const Scene(id: 'home', title: 'Dashboard'),
    Scene(
      id: 'settings',
      title: 'Settings',
      entry: AppEntry(afterOpen: (c) => _push(c, const SettingsScreen())),
    ),
  ]),
  const SceneGroup('Finance', PhosphorIconsRegular.moneyWavy, [
    Scene(
      id: 'finance-overview',
      title: 'Overview',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.overview,
      ),
    ),
    Scene(
      id: 'finance-transactions',
      title: 'Transactions · List',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.transactions,
        transactionsView: TransactionsView.list,
      ),
    ),
    Scene(
      id: 'finance-charts',
      title: 'Transactions · Charts',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.transactions,
        transactionsView: TransactionsView.charts,
      ),
    ),
    Scene(
      id: 'finance-budget',
      title: 'Budget',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.budget,
      ),
    ),
    Scene(
      id: 'finance-recurring',
      title: 'Recurring',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.recurring,
      ),
    ),
  ]),
  const SceneGroup('Investments', PhosphorIconsRegular.chartLineUp, [
    Scene(
      id: 'investments-overview',
      title: 'Overview',
      entry: AppEntry(
        section: AppSection.investments,
        investmentsTab: InvestmentsTab.overview,
      ),
    ),
    Scene(
      id: 'investments-positions',
      title: 'Positions',
      entry: AppEntry(
        section: AppSection.investments,
        investmentsTab: InvestmentsTab.positions,
      ),
    ),
    Scene(
      id: 'investments-movements',
      title: 'Movements',
      entry: AppEntry(
        section: AppSection.investments,
        investmentsTab: InvestmentsTab.movements,
      ),
    ),
  ]),
  SceneGroup('Add', PhosphorIconsRegular.plusCircle, [
    Scene(
      id: 'add-transaction',
      title: 'New transaction',
      entry: AppEntry(afterOpen: (c) => showAddSheet(c)),
    ),
    Scene(
      id: 'add-recurring',
      title: 'New recurring transaction',
      entry: AppEntry(
        section: AppSection.finance,
        financeTab: FinanceTab.recurring,
        afterOpen: (c) => showAddSheet(
          c,
          draft: const AddSheetDraft.transaction(recurring: true),
        ),
      ),
    ),
    Scene(
      id: 'add-movement',
      title: 'New movement',
      entry: AppEntry(
        section: AppSection.investments,
        afterOpen: (c) =>
            showAddSheet(c, draft: const AddSheetDraft.movement()),
      ),
    ),
  ]),
  const SceneGroup('Onboarding', PhosphorIconsRegular.flagBanner, [
    Scene(id: 'onboarding', title: 'Splash and welcome', onboarding: true),
  ]),
];

Scene sceneById(String id) => sceneGroups
    .expand((g) => g.scenes)
    .firstWhere(
      (s) => s.id == id,
      orElse: () => sceneGroups.first.scenes.first,
    );
