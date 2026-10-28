import 'package:flutter/foundation.dart';

import 'transaction.dart';

/// One page of a filtered transaction list.
@immutable
class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.netByDay,
  });

  /// Newest first.
  final List<Transaction> items;

  /// 1-based.
  final int page;
  final int pageSize;

  /// Transactions matching the filter, over all pages.
  final int total;

  /// For each day shown on this page (date only): income minus expenses in
  /// the main currency of **all** the filtered transactions of that day,
  /// transfers excluded. Days with only transfers are absent.
  final Map<DateTime, double> netByDay;

  int get pageCount => total == 0 ? 0 : (total + pageSize - 1) ~/ pageSize;
}
