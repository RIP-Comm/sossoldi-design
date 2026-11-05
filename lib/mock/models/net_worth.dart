import 'package:flutter/foundation.dart';

/// Periods of the Dashboard "Net worth" widget. [all] starts at the first
/// day with data.
enum NetWorthPeriod { threeMonths, sixMonths, year, threeYears, fiveYears, all }

@immutable
class NetWorthPoint {
  const NetWorthPoint({required this.time, required this.value});

  final DateTime time;

  /// Accounts plus positions at market value, main currency.
  final double value;
}

/// The net worth (accounts + investments) over a [NetWorthPeriod], in the
/// main currency. [points] are sampled to the period (daily up to 6 months,
/// then weekly or every two weeks); the first is the start of the period (or
/// of the history when this is shorter), the last is today and equals
/// [current]. With fewer than two points there is no history to compare:
/// [start] and [change] are null.
@immutable
class NetWorthSeries {
  const NetWorthSeries({
    required this.period,
    required this.currency,
    required this.current,
    required this.points,
  });

  final NetWorthPeriod period;
  final String currency;
  final double current;
  final List<NetWorthPoint> points;

  bool get hasHistory => points.length >= 2;

  /// Net worth at the start of the period; null without [hasHistory].
  double? get start => hasHistory ? points.first.value : null;

  /// [current] minus [start]; null without history.
  double? get change => hasHistory ? current - points.first.value : null;

  /// [change] over [start]; null without history or when [start] is not
  /// above zero.
  double? get changePercent {
    final s = start;
    final c = change;
    return s == null || c == null || s <= 0 ? null : c / s;
  }
}
