import 'package:flutter/foundation.dart';

enum TransactionType { expense, income, transfer }

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.description,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    this.subcategoryId,
    this.recurringId,
  });

  final String id;
  final TransactionType type;

  /// Always positive; the sign comes from [type].
  final double amount;
  final String currency;
  final DateTime date;
  final String description;

  /// Source account (for transfers, the account money leaves).
  final String accountId;

  /// Destination account, transfers only.
  final String? toAccountId;

  /// Top-level category; null for transfers.
  final String? categoryId;
  final String? subcategoryId;

  /// The RecurringTransaction that generated it, if any.
  final String? recurringId;

  /// The same transaction no longer tied to a recurring one.
  Transaction withoutRecurring() => Transaction(
    id: id,
    type: type,
    amount: amount,
    currency: currency,
    date: date,
    description: description,
    accountId: accountId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    subcategoryId: subcategoryId,
  );
}
