import 'package:flutter/foundation.dart';

import '../date_utils.dart';
import 'transaction.dart';

/// What the transaction list is filtered by. Every field is optional and
/// the fields combine with AND; empty sets and nulls mean "no restriction".
@immutable
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.from,
    this.to,
    this.types = const {},
    this.categoryIds = const {},
    this.minAmount,
    this.maxAmount,
    this.accountIds = const {},
  });

  /// The default view of the list: the whole month containing [today].
  factory TransactionFilter.forMonthOf(DateTime today) => TransactionFilter(
    from: DateTime(today.year, today.month),
    to: DateTime(today.year, today.month + 1, 0),
  );

  /// Text searched in description, category, subcategory and account names
  /// (case-insensitive).
  final String query;

  /// First and last day included. Both null: any date.
  final DateTime? from;
  final DateTime? to;

  final Set<TransactionType> types;

  /// Top-level categories. Transfers have none, so a category filter
  /// excludes them.
  final Set<String> categoryIds;

  /// Bounds on the amount in the main currency (converted), inclusive.
  final double? minAmount;
  final double? maxAmount;

  /// Matches both sides of a transfer.
  final Set<String> accountIds;

  bool get hasDateRange => from != null || to != null;
  bool get hasAmountRange => minAmount != null || maxAmount != null;

  /// Anything other than the plain default (search text included) that
  /// narrows the list, ignoring the date: used for "clear filters".
  bool get hasNonDateFilters =>
      query.trim().isNotEmpty ||
      types.isNotEmpty ||
      categoryIds.isNotEmpty ||
      hasAmountRange ||
      accountIds.isNotEmpty;

  /// Number of active filters, search text excluded (the pallino on the
  /// filter button). The date counts when it differs from the range of [defaults].
  int activeFilterCount(TransactionFilter defaults) =>
      (sameRange(defaults) ? 0 : 1) +
      (types.isEmpty ? 0 : 1) +
      (categoryIds.isEmpty ? 0 : 1) +
      (hasAmountRange ? 1 : 0) +
      (accountIds.isEmpty ? 0 : 1);

  bool sameRange(TransactionFilter other) =>
      _sameDay(from, other.from) && _sameDay(to, other.to);

  static bool _sameDay(DateTime? a, DateTime? b) =>
      a == null || b == null ? a == b : dateOnly(a) == dateOnly(b);

  TransactionFilter copyWith({
    String? query,
    Set<TransactionType>? types,
    Set<String>? categoryIds,
    Set<String>? accountIds,
  }) => TransactionFilter(
    query: query ?? this.query,
    from: from,
    to: to,
    types: types ?? this.types,
    categoryIds: categoryIds ?? this.categoryIds,
    minAmount: minAmount,
    maxAmount: maxAmount,
    accountIds: accountIds ?? this.accountIds,
  );

  /// Null values clear the bound (any date).
  TransactionFilter withDateRange(DateTime? from, DateTime? to) =>
      TransactionFilter(
        query: query,
        from: from,
        to: to,
        types: types,
        categoryIds: categoryIds,
        minAmount: minAmount,
        maxAmount: maxAmount,
        accountIds: accountIds,
      );

  /// Null values clear the bound.
  TransactionFilter withAmountRange(double? min, double? max) =>
      TransactionFilter(
        query: query,
        from: from,
        to: to,
        types: types,
        categoryIds: categoryIds,
        minAmount: min,
        maxAmount: max,
        accountIds: accountIds,
      );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.query == query &&
      _sameDay(other.from, from) &&
      _sameDay(other.to, to) &&
      setEquals(other.types, types) &&
      setEquals(other.categoryIds, categoryIds) &&
      other.minAmount == minAmount &&
      other.maxAmount == maxAmount &&
      setEquals(other.accountIds, accountIds);

  @override
  int get hashCode => Object.hash(
    query,
    from,
    to,
    Object.hashAllUnordered(types),
    Object.hashAllUnordered(categoryIds),
    minAmount,
    maxAmount,
    Object.hashAllUnordered(accountIds),
  );
}
