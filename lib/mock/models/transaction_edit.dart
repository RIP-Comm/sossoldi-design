import 'package:flutter/foundation.dart';

import 'recurring_transaction.dart';
import 'transaction.dart';

/// How a recurrence ends.
enum RecurrenceEnd { never, onDate, afterCount }

/// The recurrence part of the form of a transaction.
@immutable
class RecurrenceDraft {
  const RecurrenceDraft({
    required this.frequency,
    required this.startDate,
    this.end = RecurrenceEnd.never,
    this.endDate,
    this.count,
  });

  final RecurrenceFrequency frequency;

  /// May be in the future. From today on backwards, the first transaction
  /// is created too.
  final DateTime startDate;
  final RecurrenceEnd end;

  /// [RecurrenceEnd.onDate]: the last date it can happen on.
  final DateTime? endDate;

  /// [RecurrenceEnd.afterCount]: how many times in all (the first included).
  final int? count;
}

/// What the form of a transaction collects.
@immutable
class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    this.toAccountId,
    this.toAmount,
    this.categoryId,
    this.subcategoryId,
    this.description = '',
    this.recurrence,
  });

  final TransactionType type;

  /// Positive, in the currency of [accountId].
  final double amount;
  final String accountId;
  final DateTime date;

  /// Transfers only.
  final String? toAccountId;

  /// Transfers between currencies: what arrives, in the currency of
  /// [toAccountId]. Null: the repository converts with the mock rates.
  final double? toAmount;

  /// Expenses and income only.
  final String? categoryId;
  final String? subcategoryId;
  final String description;
  final RecurrenceDraft? recurrence;
}

enum TransactionFailure {
  invalidAmount,
  accountNotFound,

  /// A transfer from an account to itself.
  sameAccount,

  /// Expense or income without a category of its type (or a subcategory
  /// that is not of that category).
  invalidCategory,
  futureDate,

  /// The end of the recurrence is missing or before its start.
  invalidEnd,
  notFound,
}

/// What an addition created, to undo it.
@immutable
class AddedTransaction {
  const AddedTransaction({this.transactionId, this.recurringId});

  /// Null for a recurrence that starts in the future.
  final String? transactionId;

  /// Null when the transaction is not recurring.
  final String? recurringId;
}

@immutable
class TransactionResult {
  const TransactionResult.ok(this.added) : failure = null;
  const TransactionResult.failed(this.failure) : added = null;

  final AddedTransaction? added;
  final TransactionFailure? failure;

  bool get ok => failure == null;
}

/// A category (and maybe its subcategory) the repository proposes.
@immutable
class CategorySuggestion {
  const CategorySuggestion(this.categoryId, [this.subcategoryId]);

  final String categoryId;
  final String? subcategoryId;
}
