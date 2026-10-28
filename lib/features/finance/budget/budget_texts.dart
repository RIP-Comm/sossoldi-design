import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/budget.dart';
import '../../../mock/models/budget_status.dart';

/// Texts and colors of the budget screens, from the numbers the repository
/// computed. Nothing is calculated here: percentages are only rounded and
/// amounts formatted.
String budgetPeriodLabel(BuildContext context, BudgetPeriod period) {
  final l10n = context.l10n;
  return switch (period) {
    BudgetPeriod.weekly => l10n.periodWeekly,
    BudgetPeriod.monthly => l10n.periodMonthly,
    BudgetPeriod.quarterly => l10n.periodQuarterly,
    BudgetPeriod.semiannual => l10n.periodSemiannual,
    BudgetPeriod.yearly => l10n.periodYearly,
  };
}

/// "50%": the share spent, whole numbers; it can go over 100%.
String budgetPercent(BuildContext context, double usage) =>
    SossoldiAmountFormat.percent(
      context,
      usage,
      showPlusSign: false,
      decimalDigits: 0,
    );

/// "120,00 € left", or "35,00 € over" when the limit was exceeded; the
/// amount is hidden with Hidden Mode.
String budgetRemainingText(
  BuildContext context, {
  required double remaining,
  required double overBy,
  required String currency,
  required bool masked,
}) {
  final l10n = context.l10n;
  String amount(double v) => masked
      ? '••••'
      : SossoldiAmountFormat.money(context, v, currencyCode: currency);
  return overBy > 0
      ? l10n.budgetOver(amount(overBy))
      : l10n.budgetLeft(amount(remaining));
}

SossoldiBudgetTone budgetTone(BudgetState state) => switch (state) {
  BudgetState.ok => SossoldiBudgetTone.ok,
  BudgetState.warning => SossoldiBudgetTone.warning,
  BudgetState.exceeded => SossoldiBudgetTone.exceeded,
};

/// Fill and empty-part colors of the overall bar: the primary blue, then the
/// warning and error tokens as the budget gets close to or over its limit.
({Color fill, Color track}) overallBarColors(
  BuildContext context,
  BudgetState state,
) {
  final colors = context.colors;
  return switch (state) {
    BudgetState.ok => (
      fill: colors.primary.surface,
      track: colors.primary.surface.withValues(alpha: 0.2),
    ),
    BudgetState.warning => (
      fill: colors.warning.stroke,
      track: colors.warning.surface,
    ),
    BudgetState.exceeded => (
      fill: colors.error.stroke,
      track: colors.error.surface,
    ),
  };
}
