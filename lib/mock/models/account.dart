import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';

enum AccountType { checking, savings, broker }

@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    this.bankName = '',
    required this.type,
    required this.initialBalance,
    required this.currency,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;

  /// Fictional bank name (empty for the accounts the user creates).
  final String bankName;
  final AccountType type;

  /// Balance at the start of the mock history. The current balance is
  /// computed by MockRepository from the transactions.
  final double initialBalance;
  final String currency;

  /// A color of [CategoryColors.all] or a free one from the color picker.
  final CategoryColor color;
  final IconData icon;

  Account copyWith({
    String? name,
    double? initialBalance,
    String? currency,
    CategoryColor? color,
    IconData? icon,
  }) => Account(
    id: id,
    name: name ?? this.name,
    bankName: bankName,
    type: type,
    initialBalance: initialBalance ?? this.initialBalance,
    currency: currency ?? this.currency,
    color: color ?? this.color,
    icon: icon ?? this.icon,
  );
}
