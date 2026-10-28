import 'package:flutter/foundation.dart';

import '../date_utils.dart';
import 'transaction.dart';

enum RecurrenceFrequency {
  weekly,
  biweekly,
  monthly,
  bimonthly,
  quarterly,
  semiannual,
  yearly,
}

extension RecurrenceStep on RecurrenceFrequency {
  /// [from] moved by [steps] occurrences (negative goes back in time).
  /// Monthly-based frequencies keep [anchorDay], clamped to the month.
  DateTime step(DateTime from, int steps, {int? anchorDay}) {
    final day = anchorDay ?? from.day;
    return switch (this) {
      RecurrenceFrequency.weekly => addDays(from, 7 * steps),
      RecurrenceFrequency.biweekly => addDays(from, 14 * steps),
      RecurrenceFrequency.monthly => addMonths(from, steps, day: day),
      RecurrenceFrequency.bimonthly => addMonths(from, 2 * steps, day: day),
      RecurrenceFrequency.quarterly => addMonths(from, 3 * steps, day: day),
      RecurrenceFrequency.semiannual => addMonths(from, 6 * steps, day: day),
      RecurrenceFrequency.yearly => addMonths(from, 12 * steps, day: day),
    };
  }
}

enum RecurringStatus { active, paused }

@immutable
class RecurringTransaction {
  RecurringTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.frequency,
    required this.nextDate,
    required this.status,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    this.subcategoryId,
    int? anchorDay,
  }) : anchorDay = anchorDay ?? nextDate.day;

  final String id;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final RecurrenceFrequency frequency;

  /// Next occurrence, always after today.
  final DateTime nextDate;

  /// Day of the month the monthly-based frequencies keep (a recurrence on
  /// the 31st falls on the last day of shorter months, but stays on the 31st
  /// the rest of the time). Defaults to the day of [nextDate].
  final int anchorDay;
  final RecurringStatus status;
  final String accountId;

  /// Transfers only.
  final String? toAccountId;
  final String? categoryId;
  final String? subcategoryId;

  RecurringTransaction copyWith({
    double? amount,
    RecurrenceFrequency? frequency,
    DateTime? nextDate,
    RecurringStatus? status,
    int? anchorDay,
  }) => RecurringTransaction(
    id: id,
    type: type,
    amount: amount ?? this.amount,
    currency: currency,
    description: description,
    frequency: frequency ?? this.frequency,
    nextDate: nextDate ?? this.nextDate,
    status: status ?? this.status,
    accountId: accountId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    anchorDay: anchorDay ?? this.anchorDay,
  );
}
