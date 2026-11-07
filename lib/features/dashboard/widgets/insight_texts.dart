import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../insights/insight.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/budget_status.dart';
import '../../finance/budget/budget_texts.dart';
import 'budget_status_card.dart';
import 'budget_status_row.dart';

/// What the Insight widget (S) draws for an [Insight]: the engine only says
/// what it is and with which numbers, the words, the figures and the design
/// system components are here. The detail at the bottom reuses what the other
/// widgets use for the same thing: the budget figures and bar of Budget
/// status, the change indicator of Investments and Net worth, the amount.
/// Amounts follow Hidden Mode ([masked]); percentages stay.
class InsightTexts {
  const InsightTexts({
    required this.icon,
    required this.title,
    this.bottom,
    this.attachedDetail,
  });

  final IconData icon;
  final String title;

  /// The detail, anchored to the bottom of the card.
  final Widget? bottom;

  /// A detail that stays attached to the title instead (the neutral state).
  final String? attachedDetail;

  factory InsightTexts.of(
    BuildContext context,
    Insight insight, {
    required bool masked,
  }) {
    final l10n = context.l10n;
    final repo = context.repository;
    final typography = context.typography;
    final colors = context.colors;
    final main = repo.mainCurrency;

    Widget detailText(String text) => Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: typography.labelLarge.copyWith(color: colors.textMed),
    );

    Widget budget({required bool exceeded}) {
      final category = repo.category(insight.categoryId!);
      final brightness = Theme.of(context).brightness;
      final usage = insight.percent!;
      final row = BudgetStatusRow(
        title: category.name,
        periodLabel: '',
        percent: budgetPercent(context, usage),
        remaining: budgetRemainingText(
          context,
          remaining: exceeded ? -insight.amount! : insight.amount!,
          overBy: exceeded ? insight.amount! : 0,
          currency: main,
          masked: masked,
        ),
        tone: budgetTone(BudgetStatus.stateForUsage(usage)),
        usage: usage,
        color: category.color.main,
        trackColor: category.color.tintFor(brightness),
      );
      // As the S size of Budget status: the percentage big (an error chip
      // when exceeded) over the amount, then the bar.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BudgetPercentBadge(
              text: row.percent,
              tone: row.tone,
              style: typography.titleLarge,
            ),
          ),
          Text(
            row.remaining,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.labelLarge.copyWith(
              color: exceeded ? colors.error.text : colors.textMed,
            ),
          ),
          SossoldiBudgetBar(
            value: row.usage,
            color: row.color,
            trackColor: row.trackColor,
          ),
        ],
      );
    }

    Widget change(double amount, double? percent) => SossoldiChangeIndicator(
      amount: amount,
      currencyCode: main,
      percent: percent,
      masked: masked,
    );

    // A value in title large over its change indicator.
    Widget valueWithChange(double value, double amount, double? percent) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: SossoldiSpacing.xs,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SossoldiAmount(
                value: value,
                currencyCode: main,
                style: typography.titleLarge,
                masked: masked,
              ),
            ),
            change(amount, percent),
          ],
        );

    switch (insight.type) {
      case InsightType.budgetExceeded:
        return InsightTexts(
          icon: PhosphorIconsRegular.warningOctagon,
          title: l10n.insightBudgetExceededTitle(
            repo.category(insight.categoryId!).name,
          ),
          bottom: budget(exceeded: true),
        );
      case InsightType.budgetAtRisk:
        return InsightTexts(
          icon: PhosphorIconsRegular.warning,
          title: l10n.insightBudgetAtRiskTitle(
            repo.category(insight.categoryId!).name,
          ),
          bottom: budget(exceeded: false),
        );
      case InsightType.recurringDue:
        final r = repo.recurring(insight.recurringId!);
        return InsightTexts(
          icon: PhosphorIconsRegular.calendarCheck,
          title: insight.days == 0
              ? l10n.insightRecurringDueToday
              : l10n.insightRecurringDueTomorrow,
          bottom: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.labelLarge.copyWith(color: colors.textHigh),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SossoldiAmount(
                  value: -insight.amount!,
                  currencyCode: insight.currency ?? main,
                  tone: SossoldiAmountTone.signed,
                  style: typography.titleLarge,
                  masked: masked,
                ),
              ),
            ],
          ),
        );
      case InsightType.unusualExpense:
        return InsightTexts(
          icon: PhosphorIconsRegular.magnifyingGlass,
          title: l10n.insightUnusualTitle(
            repo.category(insight.categoryId!).name,
          ),
          bottom: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SossoldiAmount(
                  value: -insight.amount!,
                  currencyCode: main,
                  tone: SossoldiAmountTone.signed,
                  style: typography.titleLarge,
                  masked: masked,
                ),
              ),
              detailText(
                l10n.insightUnusualDetail(insight.ratio!.round().toString()),
              ),
            ],
          ),
        );
      case InsightType.portfolioDrop:
        return InsightTexts(
          icon: PhosphorIconsRegular.trendDown,
          title: l10n.insightPortfolioDropTitle,
          bottom: valueWithChange(
            insight.value ?? 0,
            insight.amount!,
            insight.percent,
          ),
        );
      case InsightType.portfolioGain:
        return InsightTexts(
          icon: PhosphorIconsRegular.trendUp,
          title: l10n.insightPortfolioGainTitle,
          bottom: valueWithChange(
            insight.value ?? 0,
            insight.amount!,
            insight.percent,
          ),
        );
      case InsightType.netWorthHigh:
        return InsightTexts(
          icon: PhosphorIconsRegular.chartLineUp,
          title: l10n.insightNetWorthHighTitle,
          bottom: valueWithChange(
            insight.amount!,
            insight.change ?? 0,
            insight.percent,
          ),
        );
      case InsightType.noTransactionToday:
        return InsightTexts(
          icon: PhosphorIconsRegular.pencilSimpleLine,
          title: l10n.insightNoTransactionTodayTitle,
          bottom: detailText(l10n.insightNoTransactionTodayDetail),
        );
      case InsightType.noRecentTransactions:
        return InsightTexts(
          icon: PhosphorIconsRegular.pencilSimpleLine,
          title: l10n.insightNoRecentTitle,
          bottom: detailText(l10n.insightNoRecentDetail(insight.days!)),
        );
      case InsightType.firstTransaction:
        return InsightTexts(
          icon: PhosphorIconsRegular.plusCircle,
          title: l10n.insightFirstTransactionTitle,
          bottom: detailText(l10n.insightFirstTransactionDetail),
        );
      case InsightType.allGood:
        return InsightTexts(
          icon: PhosphorIconsRegular.checkCircle,
          title: l10n.insightAllGoodTitle,
          attachedDetail: l10n.insightAllGoodDetail,
        );
    }
  }
}
