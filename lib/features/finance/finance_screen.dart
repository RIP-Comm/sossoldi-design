// Finance page, from Figma "2.1.0 - Finance - Transactions" (node 13:4556):
// title, the four sections as a segmented control, and the selected one.
// Only Transactions > List is built; the rest are placeholders.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'budget/budget_tab_view.dart';
import 'charts/transaction_charts_view.dart';
import 'finance_controller.dart';
import 'overview/overview_tab_view.dart';
import 'recurring/recurring_tab_view.dart';
import 'transactions/transactions_list_view.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _selectPage(int page) {
    widget.controller.goToPage(page);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The shell adds the height of the bottom bar to the bottom padding.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final controller = widget.controller;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => SingleChildScrollView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(
            SossoldiSpacing.l,
            // Figma: the title starts 15px below the status bar.
            15,
            SossoldiSpacing.l,
            bottomInset + SossoldiSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.l,
            children: [
              Text(
                l10n.financeTitle,
                style: context.typography.headlineMedium.copyWith(
                  color: context.colors.textHigh,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SossoldiSpacing.m,
                children: [
                  SossoldiTabNavigation(
                    tabs: [
                      SossoldiTabData.text(l10n.financeTabOverview),
                      SossoldiTabData.text(l10n.financeTabTransactions),
                      SossoldiTabData.text(l10n.financeTabBudget),
                      SossoldiTabData.text(l10n.financeTabRecurring),
                    ],
                    selectedIndex: controller.tab.index,
                    onChanged: (i) =>
                        controller.selectTab(FinanceTab.values[i]),
                  ),
                  ..._content(context, controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, FinanceController controller) {
    final l10n = context.l10n;
    if (controller.tab == FinanceTab.budget) {
      return [BudgetTabView(controller: controller)];
    }
    if (controller.tab == FinanceTab.overview) {
      return [const OverviewTabView()];
    }
    if (controller.tab == FinanceTab.recurring) {
      return [RecurringTabView(controller: controller.recurring)];
    }
    if (controller.tab != FinanceTab.transactions) {
      return [const _ComingSoon()];
    }
    return [
      Row(
        spacing: SossoldiSpacing.s,
        children: [
          SossoldiUnitNavigator(
            label: l10n.transactionsViewList,
            icon: PhosphorIconsRegular.listBullets,
            selected: controller.view == TransactionsView.list,
            onTap: () => controller.selectView(TransactionsView.list),
          ),
          SossoldiUnitNavigator(
            label: l10n.transactionsViewCharts,
            icon: PhosphorIconsRegular.chartLine,
            selected: controller.view == TransactionsView.charts,
            onTap: () => controller.selectView(TransactionsView.charts),
          ),
        ],
      ),
      if (controller.view == TransactionsView.list)
        TransactionsListView(
          controller: controller,
          onPageSelected: _selectPage,
        )
      else
        TransactionChartsView(controller: controller.charts),
    ];
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SossoldiSpacing.xxxl),
      child: Center(
        child: Text(
          context.l10n.comingSoon,
          style: context.typography.bodyMedium.copyWith(
            color: context.colors.textMed,
          ),
        ),
      ),
    );
  }
}
