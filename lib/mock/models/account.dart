import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';

enum AccountType { checking, savings, broker }

@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.bankName,
    required this.type,
    required this.initialBalance,
    required this.currency,
    required this.colorIndex,
    required this.icon,
  });

  final String id;
  final String name;

  /// Fictional bank name.
  final String bankName;
  final AccountType type;

  /// Balance at the start of the mock history. The current balance is
  /// computed by MockRepository from the transactions.
  final double initialBalance;
  final String currency;

  /// Index into [CategoryColors.all].
  final int colorIndex;
  final IconData icon;

  CategoryColor get color => CategoryColors.all[colorIndex];
}
