import 'package:flutter/foundation.dart';

import 'portfolio.dart';

/// Market performance of the portfolio between two moments: what the
/// positions gained or lost, net of the money put in or taken out in between
/// (buys and sells). Main currency.
@immutable
class InvestmentChange {
  const InvestmentChange({required this.amount, required this.percent});

  final double amount;

  /// Over the value at the start plus what was invested meanwhile; null when
  /// that base is zero or less.
  final double? percent;
}

/// What the Dashboard "Investments" widget shows for one [period].
@immutable
class InvestmentsSnapshot {
  const InvestmentsSnapshot({
    required this.period,
    required this.currency,
    required this.hasPositions,
    required this.totalValue,
    required this.daily,
    required this.yearToDate,
    required this.periodChange,
    required this.series,
  });

  final ValuePeriod period;
  final String currency;

  /// There is at least one position (otherwise nothing else is meaningful).
  final bool hasPositions;

  /// Positions plus liquidity, as in the Investments Overview.
  final double totalValue;

  /// Against the previous close; null with fewer than two days of history.
  final InvestmentChange? daily;

  /// Against the last close of the previous year (or the first purchase when
  /// the portfolio is younger); null with no history.
  final InvestmentChange? yearToDate;

  /// Over [period]: first to last point of [series] (the daily change for 1D,
  /// the year-to-date one for YTD); null with fewer than two points.
  final InvestmentChange? periodChange;

  /// The market value chart of the Overview for [period] (same points).
  final ValueSeries series;
}
