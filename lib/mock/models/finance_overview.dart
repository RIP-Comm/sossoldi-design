import 'package:flutter/foundation.dart';

import 'account.dart';

/// Which rule produced a message of the Finance Overview digest.
enum DigestRule {
  budgetExceeded,
  budgetAtRisk,
  spendingVsAverage,
  largeRecurrences,
  categoryGrowth,
  allGood,
}

/// How a digest message is shown: the color of its alert.
enum DigestTone { error, warning, success, info }

/// One message of the digest. Only data, no text: the screen writes it in
/// the user's language. Which fields are set depends on [rule]:
/// - budgetExceeded: [categoryId], [amount] (how much over the limit)
/// - budgetAtRisk: [categoryId], [percent] (usage, 0.85 = 85%), [days] left
/// - spendingVsAverage: [amount] (the difference from the average),
///   [isBelow] (spending is under the average: success; over: warning)
/// - largeRecurrences: [count], [amount] (their total), [days] (the window),
///   [description] when there is only one
/// - categoryGrowth: [categoryId], [percent] (growth), [amount] (increase)
/// Amounts are in the main currency.
@immutable
class DigestMessage {
  const DigestMessage({
    required this.rule,
    required this.tone,
    this.categoryId,
    this.amount,
    this.percent,
    this.days,
    this.count,
    this.description,
    this.isBelow = false,
  });

  final DigestRule rule;
  final DigestTone tone;
  final String? categoryId;
  final double? amount;
  final double? percent;
  final int? days;
  final int? count;
  final String? description;
  final bool isBelow;
}

/// An account with how its balance changed this month: today's balance minus
/// the balance at the start of the 1st. In the account's own currency.
@immutable
class AccountChange {
  const AccountChange({
    required this.account,
    required this.balance,
    required this.change,
  });

  final Account account;
  final double balance;
  final double change;
}

/// Cumulative income, expenses and balance of the current month day by day,
/// up to today (the lists have one value per elapsed day). In the main
/// currency, transfers excluded; [expenses] are positive numbers.
@immutable
class CashFlow {
  const CashFlow({
    required this.periodStart,
    required this.daysInPeriod,
    required this.currency,
    required this.income,
    required this.expenses,
    required this.balance,
  });

  final DateTime periodStart;

  /// Days of the whole month: the horizontal axis spans them all.
  final int daysInPeriod;
  final String currency;
  final List<double> income;
  final List<double> expenses;

  /// Income minus expenses, cumulative.
  final List<double> balance;
}
