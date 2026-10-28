import 'package:flutter/widgets.dart';

import '../../../design_system/design_system.dart';

/// What the Latest transactions widget shows for one transaction.
@immutable
class LatestTransactionEntry {
  const LatestTransactionEntry({
    required this.type,
    required this.icon,
    required this.description,
    required this.account,
    required this.amount,
    required this.currency,
    this.toAccount,
    this.iconColor,
  });

  final SossoldiTransactionType type;
  final IconData icon;

  /// Saturated category color; null (transfers) uses the text color.
  final Color? iconColor;
  final String description;

  /// Source account (for transfers, the account money leaves).
  final String account;
  final String? toAccount;

  /// Absolute amount; the sign comes from [type].
  final double amount;
  final String currency;
}
