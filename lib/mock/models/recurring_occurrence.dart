import 'package:flutter/foundation.dart';

import 'transaction.dart';

/// One date of a recurring transaction: a transaction that already
/// happened, or one that is planned.
@immutable
class RecurringOccurrence {
  const RecurringOccurrence({
    required this.recurringId,
    required this.date,
    required this.type,
    required this.amount,
    required this.currency,
    this.transactionId,
  });

  final String recurringId;

  /// Day only.
  final DateTime date;
  final TransactionType type;

  /// Positive; the sign comes from [type].
  final double amount;
  final String currency;

  /// The real transaction, for an occurrence that already happened.
  final String? transactionId;

  /// Not happened yet: projected from the frequency.
  bool get isPlanned => transactionId == null;
}

/// The old transactions of a recurring one in one year, with the year's
/// total in the main currency (expenses negative, income positive,
/// transfers positive).
@immutable
class RecurringYearGroup {
  const RecurringYearGroup({
    required this.year,
    required this.total,
    required this.transactions,
  });

  final int year;
  final double total;

  /// Newest first.
  final List<Transaction> transactions;
}

/// How far back the old transactions of a recurring one go.
enum RecurringHistoryRange {
  last3Months(3),
  last6Months(6),
  last12Months(12),
  all(null);

  const RecurringHistoryRange(this.months);

  /// Null: no limit.
  final int? months;
}
