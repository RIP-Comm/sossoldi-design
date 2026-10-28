import 'package:flutter/foundation.dart';

import 'transaction_time_range.dart';

/// What one top-level category adds up to.
@immutable
class CategoryAmount {
  const CategoryAmount(this.categoryId, this.amount);

  final String categoryId;

  /// In the main currency, positive.
  final double amount;
}

/// One step of the breakdown over time (a week or a month, cut to the
/// range at both ends) with the amount of each category in it.
@immutable
class BreakdownBucket {
  const BreakdownBucket({
    required this.start,
    required this.end,
    required this.amounts,
  });

  final DateTime start;
  final DateTime end;

  /// Category id to amount (main currency); categories with nothing in
  /// this bucket are absent.
  final Map<String, double> amounts;

  double get total => amounts.values.fold(0.0, (a, b) => a + b);
}

/// Everything the Charts view shows, computed by
/// MockRepository.transactionBreakdown. Transfers are excluded, amounts
/// are in the main currency and subcategories count in their parent.
/// [total], the sum of [categories] and the sum of [buckets] are the same
/// number.
@immutable
class TransactionBreakdown {
  const TransactionBreakdown({
    required this.range,
    required this.previousRange,
    required this.kind,
    required this.granularity,
    required this.total,
    required this.previousTotal,
    required this.categories,
    required this.buckets,
  });

  final DateRange range;

  /// Same length as [range], ending the day before it starts.
  final DateRange previousRange;
  final TransactionKind kind;
  final TransactionGranularity granularity;
  final double total;
  final double previousTotal;

  /// Largest first, only categories with something in the range.
  final List<CategoryAmount> categories;

  /// In date order, covering the whole range (empty ones included).
  final List<BreakdownBucket> buckets;

  /// No transaction matches the range and filters.
  bool get isEmpty => categories.isEmpty;

  /// Change against the previous period as a fraction (0.12 = +12%), or
  /// null when the previous period has nothing to compare with.
  double? get changeVsPrevious =>
      previousTotal <= 0 ? null : (total - previousTotal) / previousTotal;
}
