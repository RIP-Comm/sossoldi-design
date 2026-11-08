import 'package:flutter/widgets.dart';

import '../../../design_system/design_system.dart';

/// What the Latest transactions and Upcoming recurring widgets show for one
/// transaction or occurrence.
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
    this.dateLabel,
    this.dateChipType = SossoldiChipType.info,
    this.onTap,
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

  /// Date chip of an occurrence of a recurring transaction ("1st June").
  final String? dateLabel;
  final SossoldiChipType dateChipType;

  /// Opens the transaction; null (an occurrence, edit mode) does nothing.
  final VoidCallback? onTap;
}
