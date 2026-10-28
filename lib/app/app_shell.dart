// Main structure of the app: the three tabs (Dashboard, Finance,
// Investments) with the bottom bar and its "+" button.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../design_system/design_system.dart';
import '../features/add_transaction/add_transaction_placeholder_screen.dart';
import '../features/dashboard/dashboard_controller.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/finance/finance_controller.dart';
import '../features/finance/finance_screen.dart';
import '../features/investments/investments_controller.dart';
import '../features/investments/investments_screen.dart';
import '../features/investments/movements/movement_form_sheet.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/l10n.dart';
import 'app_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final DashboardController _dashboard = DashboardController();

  /// Created on first use: it needs the repository from the app scope.
  late final FinanceController _finance = FinanceController(
    AppScope.read(context).repository,
  );

  late final InvestmentsController _investments = InvestmentsController(
    AppScope.read(context).repository,
  );

  @override
  void dispose() {
    _dashboard.dispose();
    _finance.dispose();
    _investments.dispose();
    super.dispose();
  }

  /// What the "+" of the bar does in each section. Investments opens the form
  /// of a movement (a buy to start with); the other sections still open the
  /// placeholder of Add transaction. A selector of what to add (expense,
  /// income, transfer, investment) will take this place.
  VoidCallback _actionFor(int section) => switch (section) {
    2 => () => showMovementFormSheet(context),
    _ => () => _push(
      const AddTransactionPlaceholderScreen(),
      fullscreenDialog: true,
    ),
  };

  void _push(Widget screen, {bool fullscreenDialog = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The bottom bar is hidden while the Dashboard is being edited.
    return ListenableBuilder(
      listenable: _dashboard,
      builder: (context, _) => _buildShell(context, _dashboard.isEditing),
    );
  }

  Widget _buildShell(BuildContext context, bool editing) {
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    // Margin under the bar: the device safe area (home indicator), with a
    // minimum on devices that have none.
    final barBottom = math.max(media.padding.bottom, SossoldiSpacing.l);
    final barArea = editing
        ? barBottom
        : barBottom + SossoldiNavbar.height + SossoldiSpacing.l;

    // Android back leaves edit mode instead of the app.
    return PopScope(
      canPop: !editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _dashboard.exitEditMode();
      },
      child: Scaffold(
        backgroundColor: context.colors.surfaceMed,
        body: Stack(
          children: [
            // Tell the tabs how much the bottom bar covers.
            MediaQuery(
              data: media.copyWith(
                padding: media.padding.copyWith(bottom: barArea),
              ),
              child: IndexedStack(
                index: _index,
                children: [
                  DashboardScreen(
                    controller: _dashboard,
                    onOpenSettings: () => _push(const SettingsScreen()),
                  ),
                  FinanceScreen(controller: _finance),
                  InvestmentsScreen(controller: _investments),
                ],
              ),
            ),
            Positioned(
              left: SossoldiSpacing.l,
              right: SossoldiSpacing.l,
              bottom: barBottom,
              child: IgnorePointer(
                ignoring: editing,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  offset: editing ? const Offset(0, 1.6) : Offset.zero,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: editing ? 0 : 1,
                    child: SossoldiNavbar(
                      items: [
                        SossoldiNavbarItem(
                          label: l10n.navHome,
                          icon: PhosphorIconsRegular.house,
                          activeIcon: PhosphorIconsFill.house,
                        ),
                        SossoldiNavbarItem(
                          label: l10n.navFinance,
                          icon: PhosphorIconsRegular.moneyWavy,
                          activeIcon: PhosphorIconsFill.moneyWavy,
                        ),
                        SossoldiNavbarItem(
                          label: l10n.navInvestments,
                          icon: PhosphorIconsRegular.chartLineUp,
                          activeIcon: PhosphorIconsFill.chartLineUp,
                        ),
                      ],
                      selectedIndex: _index,
                      onChanged: (i) => setState(() => _index = i),
                      onAction: _actionFor(_index),
                      actionSemanticLabel: l10n.addTransaction,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
