import 'package:flutter/widgets.dart';

import '../features/finance/finance_controller.dart';
import '../features/investments/investments_controller.dart';

/// The three sections of the bottom bar.
enum AppSection { home, finance, investments }

/// Where the app opens. The app itself always opens on Home; the Inspector
/// (`inspector/`) opens it straight on a screen, without navigating to it.
@immutable
class AppEntry {
  const AppEntry({
    this.section = AppSection.home,
    this.financeTab,
    this.transactionsView,
    this.investmentsTab,
    this.afterOpen,
  });

  final AppSection section;
  final FinanceTab? financeTab;
  final TransactionsView? transactionsView;
  final InvestmentsTab? investmentsTab;

  /// Runs once after the first frame of the shell, with a context below its
  /// navigator: to push a page or open a sheet on top of the section.
  final void Function(BuildContext context)? afterOpen;
}
