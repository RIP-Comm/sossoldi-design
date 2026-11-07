/// Every threshold and window of the insight rules, in one place. Days are
/// counted back from today, inclusive: "7 days" reaches the day 7 days ago.
/// Percentages are fractions (0.02 = 2%). Amounts are in the main currency.
abstract final class InsightConstants {
  /// Level 1: a budget exceeded this many days ago or less is recent news;
  /// older overruns drop to level 5.
  static const int exceededRecentDays = 7;

  /// Level 2: a recurring expense due today or within this many days.
  static const int recurringDueDays = 1;

  /// Level 4: an expense of the last [unusualWindowDays] days is unusual when
  /// it is at least [unusualRatio] times the average expense of its
  /// category (over the [unusualBaselineDays] days before the window) and at
  /// least [unusualMinimumAmount]; the category needs at least
  /// [unusualMinimumHistory] expenses in that baseline.
  static const int unusualWindowDays = 3;
  static const int unusualBaselineDays = 90;
  static const int unusualMinimumHistory = 5;
  static const double unusualRatio = 3;
  static const double unusualMinimumAmount = 50;

  /// Level 5: daily change of the portfolio at or below this.
  static const double portfolioDropDaily = -0.02;

  /// Level 6: from this local hour a day with no transaction gets a nudge;
  /// and whatever the hour when the last one is more than
  /// [reminderStaleDays] days old.
  static const int reminderHour = 18;
  static const int reminderStaleDays = 2;

  /// Level 7: daily change of the portfolio at or above this; net worth
  /// above every value of the previous [netWorthHighDays] days.
  static const double portfolioGainDaily = 0.02;
  static const int netWorthHighDays = 30;
}
