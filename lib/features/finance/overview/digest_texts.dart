import 'package:flutter/widgets.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/finance_overview.dart';

/// The title and the sentence of a digest message, in the user's language.
/// The numbers come in the message; here they are only formatted (amounts
/// are hidden with Hidden Mode).
({String title, String message}) digestText(
  BuildContext context,
  DigestMessage m,
) {
  final l10n = context.l10n;
  final repo = context.repository;
  String amount(double v) => context.hideAmounts
      ? '••••'
      : SossoldiAmountFormat.money(context, v, currencyCode: repo.mainCurrency);
  String category() => repo.category(m.categoryId!).name;
  String percent(double v) => SossoldiAmountFormat.percent(
    context,
    v,
    showPlusSign: false,
    decimalDigits: 0,
  );
  return switch (m.rule) {
    DigestRule.budgetExceeded => (
      title: l10n.digestBudgetExceededTitle,
      message: l10n.digestBudgetExceeded(category(), amount(m.amount!)),
    ),
    DigestRule.budgetAtRisk => (
      title: l10n.digestBudgetAtRiskTitle,
      message: l10n.digestBudgetAtRisk(
        category(),
        percent(m.percent!),
        m.days!,
      ),
    ),
    DigestRule.spendingVsAverage when m.isBelow => (
      title: l10n.digestBelowTitle,
      message: l10n.digestBelow(amount(m.amount!)),
    ),
    DigestRule.spendingVsAverage => (
      title: l10n.digestAboveTitle,
      message: l10n.digestAbove(amount(m.amount!)),
    ),
    DigestRule.largeRecurrences => (
      title: l10n.digestRecurrencesTitle,
      message: m.count == 1
          ? l10n.digestRecurrencesOne(
              m.description ?? '',
              amount(m.amount!),
              m.days!,
            )
          : l10n.digestRecurrencesMany(m.count!, m.days!, amount(m.amount!)),
    ),
    DigestRule.categoryGrowth => (
      title: l10n.digestGrowthTitle,
      message: l10n.digestGrowth(category(), percent(m.percent!)),
    ),
    DigestRule.allGood => (
      title: l10n.digestAllGoodTitle,
      message: l10n.digestAllGood,
    ),
  };
}

SossoldiAlertTone digestAlertTone(DigestTone tone) => switch (tone) {
  DigestTone.error => SossoldiAlertTone.error,
  DigestTone.warning => SossoldiAlertTone.warning,
  DigestTone.success => SossoldiAlertTone.success,
  DigestTone.info => SossoldiAlertTone.info,
};
