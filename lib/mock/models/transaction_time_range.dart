import 'package:flutter/foundation.dart';

import '../date_utils.dart';

/// The time ranges offered by Finance > Transactions > Charts.
enum TransactionTimeRange {
  currentMonth,
  lastMonth,
  last3Months,
  last6Months,
  yearToDate,
  last12Months;

  /// The days this range covers as of [today]. "Last N months" is the
  /// current month so far plus the N-1 full months before it.
  DateRange resolve(DateTime today) {
    final t = dateOnly(today);
    return switch (this) {
      currentMonth => DateRange(DateTime(t.year, t.month), t),
      lastMonth => DateRange(
        DateTime(t.year, t.month - 1),
        DateTime(t.year, t.month, 0),
      ),
      last3Months => DateRange(DateTime(t.year, t.month - 2), t),
      last6Months => DateRange(DateTime(t.year, t.month - 5), t),
      yearToDate => DateRange(DateTime(t.year), t),
      last12Months => DateRange(DateTime(t.year, t.month - 11), t),
    };
  }
}

/// Expenses or income: the segmented control of the charts.
enum TransactionKind { expense, income }

/// How the breakdown over time is bucketed.
enum TransactionGranularity { weekly, monthly }

/// A span of days, both ends included.
@immutable
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  /// Counted in UTC: a local difference loses a day across a daylight
  /// saving change.
  int get days =>
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;

  /// Calendar months touched by the range.
  int get monthsSpanned =>
      (end.year - start.year) * 12 + end.month - start.month + 1;

  /// The range of the same length that ends the day before [start].
  DateRange get previous {
    final previousEnd = DateTime(start.year, start.month, start.day - 1);
    return DateRange(
      DateTime(previousEnd.year, previousEnd.month, previousEnd.day - days + 1),
      previousEnd,
    );
  }

  bool contains(DateTime day) {
    final d = dateOnly(day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// Weekly always makes sense; monthly needs at least two calendar months.
  List<TransactionGranularity> get allowedGranularities => [
    TransactionGranularity.weekly,
    if (monthsSpanned >= 2) TransactionGranularity.monthly,
  ];

  /// Weekly, or monthly when the range covers 6 months or more.
  TransactionGranularity get defaultGranularity => monthsSpanned >= 6
      ? TransactionGranularity.monthly
      : TransactionGranularity.weekly;

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start..$end)';
}
