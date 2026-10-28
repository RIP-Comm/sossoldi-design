import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../../mock/models/transaction_breakdown.dart';
import '../../../mock/models/transaction_time_range.dart';

/// Texts of the breakdown over time: axis labels, indicator titles and the
/// compact numbers on the Y axis.
class ChartFormatters {
  ChartFormatters(BuildContext context, this.breakdown)
    : locale = Localizations.localeOf(context).toString();

  final TransactionBreakdown breakdown;
  final String locale;

  bool get _monthly => breakdown.granularity == TransactionGranularity.monthly;

  bool get _crossesYears =>
      breakdown.range.start.year != breakdown.range.end.year;

  /// Short label under the axis: "30 Oct" for a week, "Oct" for a month
  /// (with the year when the range spans two).
  String axisLabel(BreakdownBucket bucket) {
    if (_monthly) {
      return (_crossesYears ? DateFormat.yMMM(locale) : DateFormat.MMM(locale))
          .format(bucket.start);
    }
    return DateFormat.MMMd(locale).format(bucket.start);
  }

  /// Heading of the indicator: the week's days, or the month and year.
  String title(BreakdownBucket bucket) {
    if (_monthly) {
      return toBeginningOfSentenceCase(
            DateFormat.yMMMM(locale).format(bucket.start),
            locale,
          ) ??
          '';
    }
    final day = DateFormat.MMMd(locale);
    return bucket.start == bucket.end
        ? day.format(bucket.start)
        : '${day.format(bucket.start)} – ${day.format(bucket.end)}';
  }

  String axisNumber(double value) =>
      NumberFormat.compact(locale: locale).format(value);
}

String timeRangeLabel(BuildContext context, TransactionTimeRange range) {
  final l10n = context.l10n;
  return switch (range) {
    TransactionTimeRange.currentMonth => l10n.rangeCurrentMonth,
    TransactionTimeRange.lastMonth => l10n.rangeLastMonth,
    TransactionTimeRange.last3Months => l10n.rangeLast3Months,
    TransactionTimeRange.last6Months => l10n.rangeLast6Months,
    TransactionTimeRange.yearToDate => l10n.rangeYearToDate,
    TransactionTimeRange.last12Months => l10n.rangeLast12Months,
  };
}
