// Finance > Overview, from Figma "2.0.0 - Finance - Overview" (node
// 13:4514): the digest, the accounts with their change this month, the
// recurring transactions still to come, the cash flow of the month and the
// budget status. A fixed period: the current month, up to today. Every
// number comes from the repository; nothing is computed here.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/placeholder_screen.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../budget/budget_detail_screen.dart';
import '../budget/budget_texts.dart';
import '../recurring/recurring_detail_screen.dart';
import '../recurring/recurring_item.dart';
import 'digest_texts.dart';

class OverviewTabView extends StatelessWidget {
  const OverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.repository;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiAlertCarousel(
          alerts: [
            for (final m in repo.financeDigest())
              SossoldiAlert(
                tone: digestAlertTone(m.tone),
                title: digestText(context, m).title,
                message: digestText(context, m).message,
              ),
          ],
        ),
        const _Accounts(),
        const _Upcoming(),
        const _CashFlow(),
        const _Budgets(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.manageLabel, this.onManage});

  final String title;
  final String? manageLabel;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.titleMedium.copyWith(
            color: context.colors.textHigh,
          ),
        ),
      ),
      if (manageLabel != null)
        SossoldiButton(
          label: manageLabel!,
          type: SossoldiButtonType.ghost,
          onPressed: onManage,
        ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.onManage});

  final String title;
  final Widget child;

  /// Shows the "Manage" button.
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: SossoldiSpacing.s,
    children: [
      _SectionTitle(
        title,
        manageLabel: onManage == null ? null : context.l10n.overviewManage,
        onManage: onManage,
      ),
      child,
    ],
  );
}

void _openPlaceholder(BuildContext context, String title) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceholderScreen(title: title, showBack: true),
      ),
    );

class _Accounts extends StatelessWidget {
  const _Accounts();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final masked = context.hideAmounts;
    return _Section(
      title: l10n.overviewAccounts,
      onManage: () => _openPlaceholder(context, l10n.overviewAccountsTitle),
      child: SossoldiList(
        children: [
          for (final a in repo.accountsWithChange())
            SossoldiAccountItem(
              name: a.account.name,
              balance: a.balance,
              currencyCode: a.account.currency,
              variation: a.change,
              masked: masked,
              leading: Icon(
                a.account.icon,
                size: 24,
                color: a.account.color.main,
              ),
            ),
        ],
      ),
    );
  }
}

class _Upcoming extends StatelessWidget {
  const _Upcoming();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final upcoming = repo.upcomingRecurrencesThisMonth();
    return _Section(
      title: l10n.overviewUpcoming,
      child: upcoming.isEmpty
          ? Container(
              padding: const EdgeInsets.all(SossoldiSpacing.m),
              decoration: ShapeDecoration(
                color: context.colors.surfaceHigh,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(SossoldiRadius.m),
                ),
              ),
              child: Text(
                l10n.overviewNoUpcoming,
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.textMed,
                ),
              ),
            )
          : SossoldiList(
              children: [
                for (final (i, o) in upcoming.indexed)
                  RecurringItem(
                    key: ValueKey('${o.recurringId}-${o.date}-$i'),
                    type: o.type,
                    description: repo.recurring(o.recurringId).description,
                    accountId: repo.recurring(o.recurringId).accountId,
                    toAccountId: repo.recurring(o.recurringId).toAccountId,
                    categoryId: repo.recurring(o.recurringId).categoryId,
                    amount: o.amount,
                    currency: o.currency,
                    date: o.date,
                    planned: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RecurringDetailScreen(recurringId: o.recurringId),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CashFlow extends StatelessWidget {
  const _CashFlow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final flow = repo.cashFlow();
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.MMMd(locale);
    final compact = NumberFormat.compact(locale: locale);
    return _Section(
      title: l10n.overviewCashFlow,
      child: Container(
        padding: const EdgeInsets.all(SossoldiSpacing.m),
        decoration: ShapeDecoration(
          color: colors.surfaceHigh,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(SossoldiRadius.m),
          ),
        ),
        child:
            flow.income.every((v) => v == 0) &&
                flow.expenses.every((v) => v == 0)
            // Nothing to draw yet: a flat chart between -1 and +1 says nothing.
            ? Text(
                l10n.overviewCashFlowEmpty,
                style: context.typography.labelLarge.copyWith(
                  color: colors.textMed,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SossoldiSpacing.m,
                children: [
                  SossoldiCashFlowChart(
                    income: flow.income,
                    expenses: flow.expenses,
                    balance: flow.balance,
                    length: flow.daysInPeriod,
                    xLabels: [
                      for (var d = 0; d < flow.daysInPeriod; d++)
                        day.format(
                          DateTime(
                            flow.periodStart.year,
                            flow.periodStart.month,
                            d + 1,
                          ),
                        ),
                    ],
                    formatAxis: (v) =>
                        '${v > 0 ? '+' : ''}${compact.format(v)}',
                    pointTitles: [
                      for (var d = 0; d < flow.daysInPeriod; d++)
                        DateFormat.MMMd(locale).format(
                          DateTime(
                            flow.periodStart.year,
                            flow.periodStart.month,
                            d + 1,
                          ),
                        ),
                    ],
                    formatValue: (v) => SossoldiAmountFormat.money(
                      context,
                      v,
                      currencyCode: flow.currency,
                    ),
                    incomeLabel: l10n.legendIncome,
                    expenseLabel: l10n.legendExpense,
                    balanceLabel: l10n.legendBalance,
                    masked: context.hideAmounts,
                    semanticLabel: l10n.cashFlowSemantics,
                  ),
                  SossoldiChartLegend(
                    items: [
                      SossoldiLegendItem(
                        color: colors.income.onSurface,
                        label: l10n.legendIncome,
                      ),
                      SossoldiLegendItem(
                        color: colors.expense.onSurface,
                        label: l10n.legendExpense,
                      ),
                      SossoldiLegendItem(
                        color: colors.shapeMed,
                        label: l10n.legendBalance,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _Budgets extends StatelessWidget {
  const _Budgets();

  /// Figma: 140. A little wider so the figures of an exceeded budget fit.
  static const double cardWidth = 160;
  static const double cardHeight = 116;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final brightness = Theme.of(context).brightness;
    final budgets = repo.monthBudgets();
    return _Section(
      title: l10n.overviewBudgetStatus,
      onManage: () => _openPlaceholder(context, l10n.overviewBudgetsTitle),
      child: budgets.isEmpty
          ? Container(
              padding: const EdgeInsets.all(SossoldiSpacing.m),
              decoration: ShapeDecoration(
                color: context.colors.surfaceHigh,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(SossoldiRadius.m),
                ),
              ),
              child: Text(
                l10n.overviewNoBudgets,
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.textMed,
                ),
              ),
            )
          : SizedBox(
              height: cardHeight,
              child: LayoutBuilder(
                builder: (context, constraints) => OverflowBox(
                  // The row of cards runs to the edge of the screen.
                  alignment: Alignment.centerLeft,
                  minWidth: constraints.maxWidth + SossoldiSpacing.l,
                  maxWidth: constraints.maxWidth + SossoldiSpacing.l,
                  child: SizedBox(
                    height: cardHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: SossoldiSpacing.l),
                      itemCount: budgets.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: SossoldiSpacing.m),
                      itemBuilder: (context, i) {
                        final s = budgets[i];
                        final category = repo.category(s.budget.categoryId);
                        return SizedBox(
                          width: cardWidth,
                          child: SossoldiBudgetItem(
                            card: true,
                            title: category.name,
                            periodLabel: budgetPeriodLabel(
                              context,
                              s.budget.period,
                            ),
                            percent: budgetPercent(context, s.usage),
                            remaining: budgetRemainingText(
                              context,
                              remaining: s.remaining,
                              overBy: s.overBy,
                              currency: s.currency,
                              masked: context.hideAmounts,
                            ),
                            tone: budgetTone(s.state),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    BudgetDetailScreen(budgetId: s.budget.id),
                              ),
                            ),
                            bar: SossoldiBudgetBar(
                              value: s.usage,
                              color: category.color.main,
                              trackColor: category.color.tintFor(brightness),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
