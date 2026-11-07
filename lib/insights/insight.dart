import 'package:flutter/foundation.dart';

/// What an insight is about. The UI turns the type into text (l10n) with the
/// parameters of the [Insight]; nothing is written or calculated here.
enum InsightType {
  budgetExceeded,
  recurringDue,
  budgetAtRisk,
  unusualExpense,
  portfolioDrop,
  noTransactionToday,
  noRecentTransactions,
  firstTransaction,
  portfolioGain,
  netWorthHigh,

  /// No insight: the neutral state.
  allGood,
}

/// Semantic tone: decides the color.
enum InsightTone { negative, attention, neutral, positive }

/// What a tap on the insight leads to.
enum InsightAction {
  viewBudget,
  viewRecurring,
  viewTransactions,
  viewInvestments,
  addTransaction,
  none,
}

/// The one insight the engine picks, with the numbers the text needs.
@immutable
class Insight {
  const Insight({
    required this.type,
    required this.tone,
    required this.action,
    required this.level,
    this.budgetId,
    this.categoryId,
    this.recurringId,
    this.transactionId,
    this.amount,
    this.currency,
    this.limit,
    this.percent,
    this.change,
    this.value,
    this.ratio,
    this.days,
    this.date,
  });

  const Insight.allGood()
    : this(
        type: InsightType.allGood,
        tone: InsightTone.neutral,
        action: InsightAction.none,
        level: 8,
      );

  final InsightType type;
  final InsightTone tone;
  final InsightAction action;

  /// The priority level it came from (1 is the most urgent, 8 is "none").
  final int level;

  final String? budgetId;
  final String? categoryId;
  final String? recurringId;
  final String? transactionId;

  /// The main figure, positive, in the main currency: what a budget is over
  /// by or has left, a recurrence's or an expense's amount, the change of the
  /// portfolio (signed), the net worth (for [InsightType.netWorthHigh]).
  final double? amount;

  /// The currency of [amount] when it is not the main one (a recurrence).
  final String? currency;

  /// The limit of the budget, or the usual (average) expense of the category.
  final double? limit;

  /// Budget usage (1.12 = 112%) or the change of the portfolio or of the net
  /// worth (fraction, signed; null when the base is not above zero).
  final double? percent;

  /// Net worth: the change in money over the window (its percentage is
  /// [percent]).
  final double? change;

  /// Portfolio: its total value (positions + liquidity, main currency).
  final double? value;

  /// Times above the usual (unusual expense).
  final double? ratio;

  /// Days left in the budget period, days until the recurrence (0 today),
  /// days since the last transaction.
  final int? days;

  /// Date of the recurrence, of the expense.
  final DateTime? date;

  bool get isNone => type == InsightType.allGood;

  @override
  bool operator ==(Object other) =>
      other is Insight &&
      other.type == type &&
      other.tone == tone &&
      other.action == action &&
      other.level == level &&
      other.budgetId == budgetId &&
      other.categoryId == categoryId &&
      other.recurringId == recurringId &&
      other.transactionId == transactionId &&
      other.amount == amount &&
      other.currency == currency &&
      other.limit == limit &&
      other.percent == percent &&
      other.change == change &&
      other.value == value &&
      other.ratio == ratio &&
      other.days == days &&
      other.date == date;

  @override
  int get hashCode => Object.hash(
    type,
    tone,
    action,
    level,
    budgetId,
    categoryId,
    recurringId,
    transactionId,
    amount,
    currency,
    limit,
    percent,
    change,
    value,
    ratio,
    days,
    date,
  );
}
