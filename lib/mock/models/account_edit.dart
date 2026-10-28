import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';
import 'account.dart';

/// What the form of an account collects.
@immutable
class AccountDraft {
  const AccountDraft({
    required this.name,
    required this.initialBalance,
    required this.currency,
    required this.color,
    required this.icon,
    this.type = AccountType.checking,
  });

  final String name;

  /// May be zero or negative (a credit card).
  final double initialBalance;
  final String currency;
  final CategoryColor color;
  final IconData icon;

  /// Only used when an account is created.
  final AccountType type;
}

/// Why a change of the accounts was not applied.
enum AccountFailure {
  /// The name is empty.
  invalidName,

  /// Another account has the same name (capitals do not count).
  duplicateName,

  /// The balance is not a finite number.
  invalidAmount,

  /// The currency is not one the app supports.
  invalidCurrency,

  /// The account has transactions, recurrences or movements: it cannot be
  /// deleted, nor can its currency change.
  inUse,

  /// The account does not exist.
  notFound,
}

@immutable
class AccountResult {
  const AccountResult.ok(this.account) : failure = null;
  const AccountResult.failed(this.failure) : account = null;

  /// The account created or changed.
  final Account? account;
  final AccountFailure? failure;

  bool get ok => failure == null;
}
