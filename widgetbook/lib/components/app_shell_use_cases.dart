import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/dashboard_screen.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/widgets/latest_transaction_entry.dart';
import 'package:sossoldi/features/dashboard/widgets/latest_transactions_card.dart';
import 'package:sossoldi/features/dashboard/widgets/monthly_balance_card.dart';
import 'package:sossoldi/mock/models/balance_trend.dart';

import '../foundations/foundation_page.dart';

class HeaderButtonUseCase extends StatelessWidget {
  const HeaderButtonUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Eye / Eye slashed / Settings / Disabled',
          children: [
            SossoldiHeaderButton(
              icon: PhosphorIconsRegular.eye,
              semanticLabel: 'Hide amounts',
              onPressed: () {},
            ),
            SossoldiHeaderButton(
              icon: PhosphorIconsRegular.eyeSlash,
              semanticLabel: 'Show amounts',
              onPressed: () {},
            ),
            SossoldiHeaderButton(
              icon: PhosphorIconsRegular.gearSix,
              semanticLabel: 'Settings',
              onPressed: () {},
            ),
            const SossoldiHeaderButton(
              icon: PhosphorIconsRegular.gearSix,
              semanticLabel: 'Settings',
              onPressed: null,
            ),
          ],
        ),
        FoundationSection(
          title: 'Edit mode: Plus / Check (filled)',
          children: [
            SossoldiHeaderButton(
              icon: PhosphorIconsRegular.plus,
              semanticLabel: 'Add widget',
              onPressed: () {},
            ),
            SossoldiHeaderButton(
              icon: PhosphorIconsRegular.check,
              semanticLabel: 'Done',
              filled: true,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class NavbarUseCase extends StatefulWidget {
  const NavbarUseCase({super.key});

  @override
  State<NavbarUseCase> createState() => _NavbarUseCaseState();
}

class _NavbarUseCaseState extends State<NavbarUseCase> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Interactive (tap the tabs)',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiNavbar(
                items: const [
                  SossoldiNavbarItem(
                    label: 'Home',
                    icon: PhosphorIconsRegular.house,
                    activeIcon: PhosphorIconsFill.house,
                  ),
                  SossoldiNavbarItem(
                    label: 'Finance',
                    icon: PhosphorIconsRegular.moneyWavy,
                    activeIcon: PhosphorIconsFill.moneyWavy,
                  ),
                  SossoldiNavbarItem(
                    label: 'Investments',
                    icon: PhosphorIconsRegular.chartLineUp,
                    activeIcon: PhosphorIconsFill.chartLineUp,
                  ),
                ],
                selectedIndex: _index,
                onChanged: (i) => setState(() => _index = i),
                onAction: () {},
                actionSemanticLabel: 'Add transaction',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WidgetCardUseCase extends StatelessWidget {
  const WidgetCardUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(double width, int rows, String label) => SizedBox(
      width: width,
      height: SossoldiWidgetGrid.heightFor(rows),
      child: SossoldiWidgetCard(
        child: Center(
          child: Text(
            label,
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textMed,
            ),
          ),
        ),
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Sizes on a 358 wide grid: S 171x170, M 358x170, L 358x356',
          children: [card(171, 1, 'S'), card(358, 1, 'M'), card(358, 2, 'L')],
        ),
      ],
    );
  }
}

/// Cumulative net of [days] days, with a simple deterministic wiggle.
List<double> _series(int days, double total, {double wiggle = 0.25}) => [
  for (var i = 1; i <= days; i++)
    total * i / days +
        (i.isEven ? 1 : -1) * total.abs() * wiggle * (i % 5) / 10,
];

BalanceTrend _trend(double net, {int elapsed = 22}) => BalanceTrend(
  periodStart: DateTime(2026, 10),
  daysInPeriod: 31,
  currency: 'EUR',
  current: _series(elapsed, net),
  previous: _series(30, 900),
  income: net > 0 ? net + 680.2 : 680.2,
  expenses: net > 0 ? 680.2 : 680.2 - net,
);

class TrendChartUseCase extends StatelessWidget {
  const TrendChartUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget chart(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SossoldiSpacing.xs,
      children: [
        Text(
          label,
          style: context.typography.labelSmall.copyWith(
            color: context.colors.textMed,
          ),
        ),
        SizedBox(
          width: 171,
          height: 98,
          child: DecoratedBox(
            decoration: BoxDecoration(color: context.colors.surfaceHigh),
            child: child,
          ),
        ),
      ],
    );
    final up = _series(22, 1000);
    final down = _series(22, -1300);
    final ref = _series(30, 900);
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Tones, reference line, short history',
          children: [
            chart(
              'positive + reference',
              SossoldiTrendChart(current: up, length: 31, reference: ref),
            ),
            chart(
              'negative + reference',
              SossoldiTrendChart(
                current: down,
                length: 31,
                reference: ref,
                tone: SossoldiTrendTone.negative,
              ),
            ),
            chart('no reference', SossoldiTrendChart(current: up, length: 31)),
            chart(
              'first day only',
              SossoldiTrendChart(
                current: const [-40],
                length: 31,
                reference: ref,
                tone: SossoldiTrendTone.negative,
              ),
            ),
            chart(
              'month almost over',
              SossoldiTrendChart(
                current: _series(30, 600),
                length: 31,
                reference: ref,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MonthlyBalanceUseCase extends StatelessWidget {
  const MonthlyBalanceUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(
      BalanceTrend trend, {
      DashboardWidgetSize size = DashboardWidgetSize.s,
      bool masked = false,
    }) => SizedBox(
      width: size.columns == 1 ? 171 : 358,
      height: SossoldiWidgetGrid.heightFor(size.rows),
      child: MonthlyBalanceCard(
        size: size,
        title: 'Monthly balance',
        trend: trend,
        masked: masked,
        comparisonLabel: 'Compared to last month on the same day',
        incomeLabel: 'Income',
        expenseLabel: 'Expense',
        thisMonthLabel: 'This month',
        lastMonthLabel: 'Last month',
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Size S: positive / negative / large / hidden',
          children: [
            card(_trend(1000.2)),
            card(_trend(-1325.35)),
            card(_trend(-123456789.12)),
            card(_trend(1000.2), masked: true),
          ],
        ),
        FoundationSection(
          title: 'Size M: positive / negative / hidden',
          children: [
            card(_trend(1000.2), size: DashboardWidgetSize.m),
            card(_trend(-1325.35), size: DashboardWidgetSize.m),
            card(_trend(1000.2), size: DashboardWidgetSize.m, masked: true),
          ],
        ),
        FoundationSection(
          title: 'Size L: positive / negative / hidden',
          children: [
            card(_trend(1000.2), size: DashboardWidgetSize.l),
            card(_trend(-1325.35), size: DashboardWidgetSize.l),
            card(_trend(1000.2), size: DashboardWidgetSize.l, masked: true),
          ],
        ),
      ],
    );
  }
}

const _entries = [
  LatestTransactionEntry(
    type: SossoldiTransactionType.expense,
    icon: PhosphorIconsRegular.forkKnife,
    description: 'Cena fuori',
    account: 'N26',
    amount: 39.12,
    currency: 'EUR',
  ),
  LatestTransactionEntry(
    type: SossoldiTransactionType.income,
    icon: PhosphorIconsRegular.briefcase,
    description: 'Paycheck',
    account: 'Buddybank',
    amount: 1800,
    currency: 'EUR',
  ),
  LatestTransactionEntry(
    type: SossoldiTransactionType.transfer,
    icon: PhosphorIconsRegular.arrowsLeftRight,
    description: 'Risparmi',
    account: 'N26',
    toAccount: 'Buddybank',
    amount: 100,
    currency: 'EUR',
  ),
  LatestTransactionEntry(
    type: SossoldiTransactionType.expense,
    icon: PhosphorIconsRegular.shoppingCart,
    description: 'Spesa',
    account: 'N26',
    amount: 23.98,
    currency: 'EUR',
  ),
  LatestTransactionEntry(
    type: SossoldiTransactionType.expense,
    icon: PhosphorIconsRegular.gift,
    description: 'Regalo',
    account: 'N26',
    amount: 78.9,
    currency: 'EUR',
  ),
  LatestTransactionEntry(
    type: SossoldiTransactionType.expense,
    icon: PhosphorIconsRegular.house,
    description: 'Affitto',
    account: 'N26',
    amount: 650,
    currency: 'EUR',
  ),
];

class LatestTransactionsUseCase extends StatelessWidget {
  const LatestTransactionsUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(
      DashboardWidgetSize size, {
      List<LatestTransactionEntry> entries = _entries,
      bool masked = false,
    }) => SizedBox(
      width: size.columns == 1 ? 171 : 358,
      height: SossoldiWidgetGrid.heightFor(size.rows),
      child: LatestTransactionsCard(
        size: size,
        entries: entries,
        masked: masked,
        title: 'Latest transactions',
        selector: const SizedBox.shrink(),
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Size S: expense / income / transfer / hidden',
          children: [
            card(DashboardWidgetSize.s),
            card(DashboardWidgetSize.s, entries: _entries.sublist(1)),
            card(DashboardWidgetSize.s, entries: _entries.sublist(2)),
            card(DashboardWidgetSize.s, masked: true),
          ],
        ),
        FoundationSection(
          title: 'Size M (3 rows) / hidden',
          children: [
            card(DashboardWidgetSize.m),
            card(DashboardWidgetSize.m, masked: true),
          ],
        ),
        FoundationSection(
          title: 'Size L (as many rows as fit) / few transactions',
          children: [
            card(DashboardWidgetSize.l),
            card(DashboardWidgetSize.l, entries: _entries.sublist(0, 2)),
          ],
        ),
      ],
    );
  }
}

class EditControlsUseCase extends StatelessWidget {
  const EditControlsUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Remove badge / Resize handle',
          children: [
            SossoldiRemoveBadge(onPressed: () {}, semanticLabel: 'Remove'),
            const SossoldiResizeHandle(),
          ],
        ),
        const FoundationSection(
          title: 'Page indicator: first / second / third',
          children: [
            SossoldiPageIndicator(count: 3, index: 0),
            SossoldiPageIndicator(count: 3, index: 1),
            SossoldiPageIndicator(count: 3, index: 2),
          ],
        ),
        const FoundationSection(
          title: 'Trend legend: positive / negative',
          children: [
            SossoldiTrendLegend(
              currentLabel: 'This month',
              referenceLabel: 'Last month',
            ),
            SossoldiTrendLegend(
              currentLabel: 'This month',
              referenceLabel: 'Last month',
              tone: SossoldiTrendTone.negative,
            ),
          ],
        ),
      ],
    );
  }
}

/// The whole Dashboard with its own state: long press a widget to edit,
/// drag the handle to resize, + to add. Not saved anywhere.
class DashboardEditDemoUseCase extends StatefulWidget {
  const DashboardEditDemoUseCase({super.key});

  @override
  State<DashboardEditDemoUseCase> createState() =>
      _DashboardEditDemoUseCaseState();
}

class _DashboardEditDemoUseCaseState extends State<DashboardEditDemoUseCase> {
  final AppState _state = AppState();
  final DashboardController _controller = DashboardController();

  @override
  void dispose() {
    _controller.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 390,
        child: ColoredBox(
          color: context.colors.surfaceMed,
          child: AppScope(
            state: _state,
            child: DashboardScreen(
              controller: _controller,
              onOpenSettings: () {},
            ),
          ),
        ),
      ),
    );
  }
}
