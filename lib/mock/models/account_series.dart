import 'package:flutter/foundation.dart';

import 'account.dart';
import 'net_worth.dart';

/// An account with its balance in its own currency and converted to the main
/// one; the repository returns the list already sorted (see
/// `MockRepository.accountsByBalance`).
@immutable
class AccountBalance {
  const AccountBalance({
    required this.account,
    required this.balance,
    required this.balanceInMain,
  });

  final Account account;

  /// In the account's currency.
  final double balance;

  /// In the main currency (what the order is based on).
  final double balanceInMain;
}

/// The balance of one account over a [NetWorthPeriod], in the account's
/// currency. Same sampling as [NetWorthSeries] (daily up to 6 months, then
/// weekly or every two weeks); the first point is the start of the period (or
/// of the account's history when this is shorter), the last is today and
/// equals [current]. With fewer than two points [start] and [change] are null.
@immutable
class AccountSeries {
  const AccountSeries({
    required this.accountId,
    required this.period,
    required this.currency,
    required this.current,
    required this.points,
  });

  final String accountId;
  final NetWorthPeriod period;
  final String currency;
  final double current;

  /// Balance at the end of each day sampled; [NetWorthPoint.value] is in
  /// [currency].
  final List<NetWorthPoint> points;

  bool get hasHistory => points.length >= 2;

  /// Balance at the start of the period; null without [hasHistory].
  double? get start => hasHistory ? points.first.value : null;

  /// [current] minus [start]; null without history.
  double? get change => hasHistory ? current - points.first.value : null;

  /// [change] over [start]; null without history or when [start] is not
  /// above zero.
  double? get changePercent {
    final s = start;
    final c = change;
    return s == null || c == null || s <= 0 ? null : c / s;
  }
}
