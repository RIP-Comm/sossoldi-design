// Finance > Budget, from Figma "2.2.0 - Finance - Budget" (node 13:4743):
// the period, the overall budget, and the breakdown by category with the
// segmented bar. All the numbers come from MockRepository.budgetOverview.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/budget.dart';
import '../../../mock/models/budget_overview.dart';
import '../../../mock/models/budget_status.dart';
import '../finance_controller.dart';
import 'budget_detail_screen.dart';
import 'budget_texts.dart';

class BudgetTabView extends StatelessWidget {
  const BudgetTabView({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final overview = repo.budgetOverview(controller.budgetPeriod);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiSelect<BudgetPeriod>(
          value: controller.budgetPeriod,
          onChanged: controller.selectBudgetPeriod,
          items: [
            for (final p in BudgetPeriod.values)
              SossoldiSelectItem(
                value: p,
                label: budgetPeriodLabel(context, p),
              ),
          ],
        ),
        if (overview.isEmpty)
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.target,
              title: l10n.budgetEmptyTitle,
              message: l10n.budgetEmptyHint,
            ),
          )
        else ...[
          if (overview.hasOverall) _Overall(overview: overview),
          _Breakdown(overview: overview),
        ],
      ],
    );
  }
}

class _Overall extends StatelessWidget {
  const _Overall({required this.overview});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    final bar = overallBarColors(context, overview.overallState);
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(SossoldiRadius.s),
      child: SossoldiBudgetItem(
        prominent: true,
        title: context.l10n.budgetOverall,
        percent: budgetPercent(context, overview.overallUsage),
        remaining: budgetRemainingText(
          context,
          remaining: overview.overallRemaining,
          overBy: overview.overallOverBy,
          currency: overview.currency,
          masked: context.hideAmounts,
        ),
        tone: budgetTone(overview.overallState),
        bar: SossoldiBudgetBar(
          value: overview.overallUsage,
          color: bar.fill,
          trackColor: bar.track,
          exceeded: overview.overallState == BudgetState.exceeded,
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.overview});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final brightness = Theme.of(context).brightness;
    final masked = context.hideAmounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          l10n.budgetCategoriesBreakdown,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.titleMedium.copyWith(
            color: colors.textHigh,
          ),
        ),
        // The segmented bar of the total is hidden for now. It is the
        // whole bar = the total budget, with one colored part per
        // category for what it spent and a neutral rest (the data
        // comes from BudgetOverview.segments / emptyShare, and the bar
        // from SossoldiSegmentedBar; both are kept). To bring it back,
        // uncomment this:
        //
        // SossoldiSegmentedBar(
        //   semanticLabel: l10n.budgetsBarSemantics,
        //   segments: [
        //     for (final seg in overview.segments)
        //       SossoldiBarSegment(
        //         share: seg.share,
        //         color: repo.category(seg.categoryId).color.main,
        //         exceeded: seg.exceeded,
        //       ),
        //   ],
        // ),
        SossoldiList(
          children: [
            for (final (i, s) in overview.items.indexed)
              SossoldiBudgetItem(
                title: repo.category(s.budget.categoryId).name,
                percent: budgetPercent(context, s.usage),
                remaining: budgetRemainingText(
                  context,
                  remaining: s.remaining,
                  overBy: s.overBy,
                  currency: s.currency,
                  masked: masked,
                ),
                tone: budgetTone(s.state),
                showDivider: i < overview.items.length - 1,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BudgetDetailScreen(budgetId: s.budget.id),
                  ),
                ),
                bar: SossoldiBudgetBar(
                  value: s.usage,
                  color: repo.category(s.budget.categoryId).color.main,
                  trackColor: repo
                      .category(s.budget.categoryId)
                      .color
                      .tintFor(brightness),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
