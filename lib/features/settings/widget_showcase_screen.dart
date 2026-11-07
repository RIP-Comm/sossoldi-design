// Prototype page (Settings > Prototype): every Dashboard widget, in every
// size and every case it has, on demo data (and on the empty data of a new
// user). Not in Figma. The widgets are the real ones, not interactive here.
//
// Hierarchy: the page title, then one cluster per widget (its name, a rule
// above), inside it one block per case (a subtitle) and under it the sizes
// (S, M, L) with a small label. The Insight cluster has one block per kind of
// insight (size S only, with fixed example numbers).

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../design_system/design_system.dart';
import '../../insights/insight.dart';
import '../../l10n/l10n.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/budget.dart';
import '../../mock/models/net_worth.dart';
import '../../mock/models/portfolio.dart';
import '../../mock/models/transaction.dart';
import '../dashboard/model/dashboard_layout.dart';
import '../dashboard/registry/dashboard_widget_definition.dart';
import '../dashboard/registry/dashboard_widget_ids.dart';
import '../dashboard/registry/dashboard_widget_registry.dart';
import '../dashboard/widgets/allocation_widget.dart';
import '../dashboard/widgets/budget_status_widget.dart';
import '../dashboard/widgets/insight_card.dart';
import '../dashboard/widgets/insight_texts.dart';
import '../dashboard/widgets/investments_widget.dart';
import '../dashboard/widgets/net_worth_widget.dart';
import '../dashboard/widgets/transaction_type_setting.dart';
import '../finance/budget/budget_texts.dart';
import '../investments/investments_texts.dart';

class WidgetShowcaseScreen extends StatefulWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  State<WidgetShowcaseScreen> createState() => _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends State<WidgetShowcaseScreen> {
  AppState? _demo;
  AppState? _empty;

  @override
  void dispose() {
    _demo?.dispose();
    _empty?.dispose();
    super.dispose();
  }

  /// One case of a widget: its settings and the data it runs on.
  _Case _case(
    String label,
    String id,
    Map<String, String> settings, {
    bool empty = false,
  }) => _Case(
    label: label,
    widgetId: id,
    settings: settings,
    state: empty ? _empty! : _demo!,
  );

  @override
  Widget build(BuildContext context) {
    final outer = AppScope.read(context).repository;
    final demo = _demo ??= AppState(repository: MockRepository(now: outer.now));
    _empty ??= AppState(repository: MockRepository.newUser(now: outer.now));
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = demo.repository;
    final withData = l10n.showcaseWithData;
    final newUser = l10n.showcaseNewUser;

    String typeLabel(TransactionType? t) =>
        TransactionTypeSetting.label(context, t);
    Map<String, String> type(TransactionType? t) =>
        t == null ? const {} : {TransactionTypeSetting.key: t.name};

    // The widgets with a case per setting, in the order of the Dashboard.
    final clusters = <(String, List<_Case>, Set<DashboardWidgetSize>)>[
      (
        l10n.widgetMonthlyBalanceName,
        [
          _case(withData, DashboardWidgetIds.monthlyBalance, const {}),
          _case(
            newUser,
            DashboardWidgetIds.monthlyBalance,
            const {},
            empty: true,
          ),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetLatestTransactionsName,
        [
          for (final t in [null, ...TransactionType.values])
            _case(typeLabel(t), DashboardWidgetIds.latestTransactions, type(t)),
          _case(
            newUser,
            DashboardWidgetIds.latestTransactions,
            const {},
            empty: true,
          ),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetUpcomingRecurringName,
        [
          for (final t in [null, ...TransactionType.values])
            _case(typeLabel(t), DashboardWidgetIds.upcomingRecurring, type(t)),
          _case(
            newUser,
            DashboardWidgetIds.upcomingRecurring,
            const {},
            empty: true,
          ),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetBudgetStatusName,
        [
          _case(l10n.budgetTypeAll, DashboardWidgetIds.budgetStatus, const {}),
          for (final p in [BudgetPeriod.monthly, BudgetPeriod.weekly])
            _case(
              budgetPeriodLabel(context, p),
              DashboardWidgetIds.budgetStatus,
              {BudgetStatusWidget.periodSetting: p.name},
            ),
          _case(
            newUser,
            DashboardWidgetIds.budgetStatus,
            const {},
            empty: true,
          ),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetNetWorthName,
        [
          for (final p in [
            NetWorthPeriod.yearToDate,
            NetWorthPeriod.year,
            NetWorthPeriod.all,
          ])
            _case(
              NetWorthWidget.periodLabel(l10n, p),
              DashboardWidgetIds.netWorth,
              {NetWorthWidget.periodSetting: p.name},
            ),
          _case(newUser, DashboardWidgetIds.netWorth, const {}, empty: true),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetInvestmentsName,
        [
          for (final p in [
            ValuePeriod.yearToDate,
            ValuePeriod.month,
            ValuePeriod.fiveYears,
          ])
            _case(periodLabel(context, p), DashboardWidgetIds.investments, {
              InvestmentsWidget.periodSetting: p.name,
            }),
          _case(newUser, DashboardWidgetIds.investments, const {}, empty: true),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
      (
        l10n.widgetAllocationName,
        [
          _case(l10n.allocationAssetClass, DashboardWidgetIds.allocation, {
            AllocationWidget.modeSetting: AllocationMode.assetClass.name,
          }),
          _case(l10n.allocationSingleAsset, DashboardWidgetIds.allocation, {
            AllocationWidget.modeSetting: AllocationMode.singleAsset.name,
          }),
          _case(newUser, DashboardWidgetIds.allocation, const {}, empty: true),
        ],
        DashboardWidgetSize.values.toSet(),
      ),
    ];

    final budget = repo.budgets.first;
    final atRisk = repo.budgets.last;
    final recurring = repo.recurringTransactions().firstWhere(
      (r) => r.type == TransactionType.expense,
    );
    final expense = repo.transactions.firstWhere(
      (t) => t.type == TransactionType.expense && t.categoryId != null,
    );
    final today = repo.today;

    Insight budgetExceeded() => Insight(
      type: InsightType.budgetExceeded,
      tone: InsightTone.negative,
      action: InsightAction.viewBudget,
      level: 1,
      budgetId: budget.id,
      categoryId: budget.categoryId,
      amount: 34,
      limit: 300,
      percent: 1.12,
    );

    final groups = <(String, List<Insight>)>[
      (l10n.showcaseBudgetExceeded, [budgetExceeded()]),
      (
        l10n.showcaseRecurringDue,
        [
          for (final days in [0, 1])
            Insight(
              type: InsightType.recurringDue,
              tone: InsightTone.attention,
              action: InsightAction.viewRecurring,
              level: 2,
              recurringId: recurring.id,
              amount: recurring.amount,
              currency: recurring.currency,
              date: DateTime(today.year, today.month, today.day + days),
              days: days,
            ),
        ],
      ),
      (
        l10n.showcaseBudgetAtRisk,
        [
          Insight(
            type: InsightType.budgetAtRisk,
            tone: InsightTone.attention,
            action: InsightAction.viewBudget,
            level: 3,
            budgetId: atRisk.id,
            categoryId: atRisk.categoryId,
            amount: 60,
            limit: 300,
            percent: 0.8,
            days: 9,
          ),
        ],
      ),
      (
        l10n.showcaseUnusualExpense,
        [
          Insight(
            type: InsightType.unusualExpense,
            tone: InsightTone.attention,
            action: InsightAction.viewTransactions,
            level: 4,
            transactionId: expense.id,
            categoryId: expense.categoryId,
            amount: 180,
            limit: 45,
            ratio: 4,
            date: today,
          ),
        ],
      ),
      (
        l10n.showcasePortfolioDrop,
        [
          const Insight(
            type: InsightType.portfolioDrop,
            tone: InsightTone.negative,
            action: InsightAction.viewInvestments,
            level: 5,
            amount: -120,
            percent: -0.024,
            value: 4880,
          ),
        ],
      ),
      (
        l10n.showcaseReminder,
        const [
          Insight(
            type: InsightType.noTransactionToday,
            tone: InsightTone.neutral,
            action: InsightAction.addTransaction,
            level: 6,
          ),
          Insight(
            type: InsightType.noRecentTransactions,
            tone: InsightTone.neutral,
            action: InsightAction.addTransaction,
            level: 6,
            days: 3,
          ),
          Insight(
            type: InsightType.firstTransaction,
            tone: InsightTone.neutral,
            action: InsightAction.addTransaction,
            level: 6,
          ),
        ],
      ),
      (
        l10n.showcasePositive,
        const [
          Insight(
            type: InsightType.portfolioGain,
            tone: InsightTone.positive,
            action: InsightAction.viewInvestments,
            level: 7,
            amount: 150,
            percent: 0.024,
            value: 6400,
          ),
          Insight(
            type: InsightType.netWorthHigh,
            tone: InsightTone.positive,
            action: InsightAction.none,
            level: 7,
            amount: 48250,
            limit: 47900,
            change: 1250,
            percent: 0.0266,
            days: 30,
          ),
        ],
      ),
      (l10n.showcaseAllGood, const [Insight.allGood()]),
    ];

    final items = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: SossoldiSpacing.s),
        child: Text(
          l10n.showcaseIntro,
          textAlign: TextAlign.center,
          style: typography.labelMedium.copyWith(color: colors.textMed),
        ),
      ),
      for (final (name, cases, sizes) in clusters) ...[
        _ClusterHeader(title: name),
        for (final c in cases) ...[
          _CaseTitle(title: c.label),
          for (final size in DashboardWidgetSize.values)
            if (sizes.contains(size)) _SizedWidget(case_: c, size: size),
        ],
      ],
      _ClusterHeader(title: l10n.widgetInsightName),
      for (final (title, insights) in groups) ...[
        _CaseTitle(title: title),
        _InsightRow(state: demo, insights: insights),
      ],
    ];

    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SossoldiSpacing.l),
              child: Row(
                children: [
                  SossoldiHeaderButton(
                    icon: PhosphorIconsRegular.arrowLeft,
                    semanticLabel: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.settingsWidgetShowcase,
                      textAlign: TextAlign.center,
                      style: typography.titleMedium.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                  ),
                  const SizedBox(width: SossoldiHeaderButton.size),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  SossoldiSpacing.l,
                  0,
                  SossoldiSpacing.l,
                  MediaQuery.paddingOf(context).bottom + SossoldiSpacing.xl,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => items[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Case {
  const _Case({
    required this.label,
    required this.widgetId,
    required this.settings,
    required this.state,
  });

  final String label;
  final String widgetId;
  final Map<String, String> settings;
  final AppState state;
}

/// The name of a widget: the biggest heading, with a rule above.
class _ClusterHeader extends StatelessWidget {
  const _ClusterHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: SossoldiSpacing.xl,
      bottom: SossoldiSpacing.m,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        Divider(height: 1, thickness: 1, color: context.colors.strokeDefault),
        Text(
          title,
          style: context.typography.titleLarge.copyWith(
            color: context.colors.textHigh,
          ),
        ),
      ],
    ),
  );
}

/// A case of a widget (a setting, the empty state, a kind of insight).
class _CaseTitle extends StatelessWidget {
  const _CaseTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: SossoldiSpacing.m,
      bottom: SossoldiSpacing.s,
    ),
    child: Text(
      title,
      style: context.typography.labelBoldLarge.copyWith(
        color: context.colors.textHigh,
      ),
    ),
  );
}

/// The label of a size, small, over the widget.
class _SizeLabel extends StatelessWidget {
  const _SizeLabel(this.size);

  final DashboardWidgetSize size;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SossoldiSpacing.xs),
    child: Text(
      size.name.toUpperCase(),
      style: context.typography.labelSmall.copyWith(
        color: context.colors.textMed,
      ),
    ),
  );
}

/// The real widget of a case in one size, as the Dashboard sizes it, with
/// no touch (the selectors show as in edit mode).
class _SizedWidget extends StatelessWidget {
  const _SizedWidget({required this.case_, required this.size});

  final _Case case_;
  final DashboardWidgetSize size;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 2 * SossoldiSpacing.l;
    final cell = (width - SossoldiWidgetGrid.gap) / SossoldiWidgetGrid.columns;
    final w = size == DashboardWidgetSize.s ? cell : width;
    final h = SossoldiWidgetGrid.heightFor(size.rows);
    final definition = dashboardWidgetRegistry.byId(case_.widgetId)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SossoldiSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SizeLabel(size),
          AppScope(
            state: case_.state,
            child: IgnorePointer(
              child: SizedBox(
                width: w,
                height: h,
                child: definition.build(
                  context,
                  size,
                  instance: DashboardWidgetInstance(
                    settings: case_.settings,
                    editing: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The insights of one kind, size S, two to a row.
class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.state, required this.insights});

  final AppState state;
  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 2 * SossoldiSpacing.l;
    final cell = (width - SossoldiWidgetGrid.gap) / SossoldiWidgetGrid.columns;
    return Padding(
      padding: const EdgeInsets.only(bottom: SossoldiSpacing.m),
      child: AppScope(
        state: state,
        child: Wrap(
          spacing: SossoldiWidgetGrid.gap,
          runSpacing: SossoldiWidgetGrid.gap,
          children: [
            for (final insight in insights)
              Builder(
                builder: (context) {
                  final texts = InsightTexts.of(
                    context,
                    insight,
                    masked: false,
                  );
                  return SizedBox(
                    width: cell,
                    height: SossoldiWidgetGrid.rowHeight,
                    child: InsightCard(
                      tone: insight.tone,
                      icon: texts.icon,
                      title: texts.title,
                      bottom: texts.bottom,
                      attachedDetail: texts.attachedDetail,
                      onTap: insight.action == InsightAction.none
                          ? null
                          : () {},
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
