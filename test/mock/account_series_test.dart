import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/net_worth.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_edit.dart';
import 'package:sossoldi/mock/models/transaction_filter.dart';

final _now = DateTime(2026, 10, 22, 10);

AccountDraft _draft(
  String name, {
  double amount = 100,
  String currency = 'EUR',
  AccountType type = AccountType.checking,
}) => AccountDraft(
  name: name,
  initialBalance: amount,
  currency: currency,
  color: CategoryColors.all[3],
  icon: PhosphorIconsRegular.bank,
  type: type,
);

String _add(MockRepository r, AccountDraft d) => r.addAccount(d).account!.id;

void main() {
  group('accountSeries', () {
    final repo = MockRepository(now: _now);

    test(
      'the last point is today and equals the balance, for every period',
      () {
        for (final a in repo.accounts) {
          for (final p in NetWorthPeriod.values) {
            final s = repo.accountSeries(a.id, p);
            expect(s.currency, a.currency);
            expect(s.current, repo.accountBalance(a.id), reason: '${a.id} $p');
            expect(s.points.last.value, s.current, reason: '${a.id} $p');
            expect(s.points.last.time, DateTime(2026, 10, 22));
            for (var i = 1; i < s.points.length; i++) {
              expect(s.points[i].time.isAfter(s.points[i - 1].time), isTrue);
            }
          }
        }
      },
    );

    test(
      'is sampled like the net worth: daily up to 6 months, then weekly',
      () {
        final daily = repo.accountSeries(
          checkingAccountId,
          NetWorthPeriod.threeMonths,
        );
        expect(daily.points[1].time.difference(daily.points[0].time).inDays, 1);
        final weekly = repo.accountSeries(
          brokerAccountId,
          NetWorthPeriod.threeYears,
        );
        expect(
          weekly.points[1].time.difference(weekly.points[0].time).inDays,
          7,
        );
      },
    );

    test(
      'a broker account includes the cash of its movements, as the liquidity',
      () {
        final s = repo.accountSeries(
          brokerAccountId,
          NetWorthPeriod.yearToDate,
        );
        expect(repo.toMain(s.current, s.currency), repo.liquidity);
        // Movements make it move even without transactions of its own.
        expect(s.hasHistory, isTrue);
        expect(repo.accountHistoryStart(brokerAccountId), isNotNull);
      },
    );

    test('change and percent come from the first and the last point', () {
      final s = repo.accountSeries(
        checkingAccountId,
        NetWorthPeriod.threeMonths,
      );
      expect(s.start, s.points.first.value);
      expect(s.change, closeTo(s.current - s.points.first.value, 1e-9));
      if (s.start! > 0) {
        expect(s.changePercent, closeTo(s.change! / s.start!, 1e-9));
      }
    });

    test('periods the history does not reach are not available', () {
      // Checking has about six months of transactions; the broker about four years.
      expect(
        repo.accountPeriodAvailable(
          checkingAccountId,
          NetWorthPeriod.fiveYears,
        ),
        isFalse,
      );
      expect(
        repo.accountPeriodAvailable(checkingAccountId, NetWorthPeriod.all),
        isTrue,
      );
      expect(
        repo.accountPeriodAvailable(brokerAccountId, NetWorthPeriod.threeYears),
        isTrue,
      );
      expect(
        repo.accountPeriodAvailable(brokerAccountId, NetWorthPeriod.fiveYears),
        isFalse,
      );
    });

    test('a period longer than the history starts at the history', () {
      final s = repo.accountSeries(checkingAccountId, NetWorthPeriod.fiveYears);
      expect(s.points.first.time, repo.accountHistoryStart(checkingAccountId));
    });

    test(
      'an account without transactions: only today, no change, no period',
      () {
        final r = MockRepository.newUser(now: _now);
        final id = _add(r, _draft('Cash', amount: 250));
        final s = r.accountSeries(id, NetWorthPeriod.yearToDate);
        expect(s.points, hasLength(1));
        expect(s.current, 250);
        expect(s.hasHistory, isFalse);
        expect(s.start, isNull);
        expect(s.change, isNull);
        expect(s.changePercent, isNull);
        expect(r.accountHistoryStart(id), isNull);
        for (final p in NetWorthPeriod.values) {
          expect(r.accountPeriodAvailable(id, p), isFalse);
        }
      },
    );

    test('a short history starts at the first transaction, after the starting balance', () {
      final r = MockRepository.newUser(now: _now);
      final a = _add(r, _draft('A', amount: 1000));
      final b = _add(r, _draft('B', amount: 0));
      void transfer(int daysAgo, double amount) => r.addTransaction(
        TransactionDraft(
          type: TransactionType.transfer,
          amount: amount,
          accountId: a,
          toAccountId: b,
          date: DateTime(2026, 10, 22 - daysAgo),
        ),
      );
      transfer(3, 100);
      transfer(1, 200);
      final s = r.accountSeries(a, NetWorthPeriod.all);
      expect(s.points.map((p) => p.value), [900, 900, 700, 700]);
      expect(s.points.first.time, DateTime(2026, 10, 19));
      expect(s.change, -200);
      expect(s.changePercent, closeTo(-200 / 900, 1e-9));
      // The receiving side too.
      expect(
        r.accountSeries(b, NetWorthPeriod.all).points.map((p) => p.value),
        [100, 100, 300, 300],
      );
      // Year to date is longer than the history: same points.
      expect(
        r.accountSeries(a, NetWorthPeriod.yearToDate).points,
        hasLength(4),
      );
      expect(r.accountPeriodAvailable(a, NetWorthPeriod.yearToDate), isFalse);
    });

    test('a zero or negative start has no percent', () {
      final r = MockRepository.newUser(now: _now);
      final a = _add(r, _draft('A', amount: 0));
      final b = _add(r, _draft('B', amount: 0));
      r.addTransaction(
        TransactionDraft(
          type: TransactionType.transfer,
          amount: 50,
          accountId: a,
          toAccountId: b,
          date: DateTime(2026, 10, 20),
        ),
      );
      final s = r.accountSeries(b, NetWorthPeriod.all);
      expect(s.change, 0);
      final sa = r.accountSeries(a, NetWorthPeriod.all);
      expect(sa.start, -50);
      expect(sa.changePercent, isNull);
    });
  });

  group('accountDefaultPeriod', () {
    NetWorthPeriod defaultFor(int daysAgo) {
      final r = MockRepository.newUser(now: _now);
      final a = _add(r, _draft('A', amount: 1000));
      final b = _add(r, _draft('B', amount: 0));
      r.addTransaction(
        TransactionDraft(
          type: TransactionType.transfer,
          amount: 10,
          accountId: a,
          toAccountId: b,
          date: DateTime(2026, 10, 22 - daysAgo),
        ),
      );
      final p = r.accountDefaultPeriod(a);
      // Never a period that cannot be picked.
      expect(r.accountPeriodAvailable(a, p), isTrue);
      return p;
    }

    test('year to date when the history covers it', () {
      expect(defaultFor(300), NetWorthPeriod.yearToDate);
      final repo = MockRepository(now: _now);
      expect(
        repo.accountDefaultPeriod(brokerAccountId),
        NetWorthPeriod.yearToDate,
      );
    });

    test(
      '6 months, then 3 months, when they take in nearly all the history',
      () {
        expect(defaultFor(190), NetWorthPeriod.sixMonths);
        expect(defaultFor(100), NetWorthPeriod.threeMonths);
      },
    );

    test('all when no period fits the history closely', () {
      // Five months of history: 6M is not covered, 3M is far too short.
      expect(defaultFor(150), NetWorthPeriod.all);
      expect(defaultFor(3), NetWorthPeriod.all);
      // The demo checking account has about six months, a little short of 6M.
      final repo = MockRepository(now: _now);
      expect(repo.accountDefaultPeriod(checkingAccountId), NetWorthPeriod.all);
    });

    test('no history at all: all', () {
      final r = MockRepository.newUser(now: _now);
      final id = _add(r, _draft('Cash'));
      expect(r.accountDefaultPeriod(id), NetWorthPeriod.all);
    });
  });

  group('accountsByBalance', () {
    test('orders by the balance in the main currency, negatives last, ties by name', () {
      final r = MockRepository.newUser(now: _now);
      _add(r, _draft('Zeta', amount: 100));
      _add(r, _draft('alpha', amount: 100));
      _add(r, _draft('Yen', amount: 5000, currency: 'JPY'));
      _add(r, _draft('Pounds', amount: 90, currency: 'GBP'));
      _add(r, _draft('Debt', amount: -50));
      _add(r, _draft('Big debt', amount: -500));
      final list = r.accountsByBalance();
      for (final e in list) {
        expect(e.balance, r.accountBalance(e.account.id));
        expect(
          e.balanceInMain,
          closeTo(r.toMain(e.balance, e.account.currency), 0.01),
        );
      }
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].balanceInMain >= list[i].balanceInMain, isTrue);
      }
      final names = list.map((e) => e.account.name).toList();
      // Equal balances: alphabetical, capitals aside.
      expect(names.indexOf('alpha'), lessThan(names.indexOf('Zeta')));
      // The order follows the converted balance, not the number: 5000 yen are
      // worth less than 100 euro, 90 pounds more.
      expect(names.indexOf('Pounds'), lessThan(names.indexOf('alpha')));
      expect(names.indexOf('Zeta'), lessThan(names.indexOf('Yen')));
      // The negative ones come last, the deepest at the very end.
      expect(names.sublist(names.length - 2), ['Debt', 'Big debt']);
    });

    test('follows a change of the main currency and notifies nothing new', () {
      final r = MockRepository(now: _now);
      final before = r.accountsByBalance().map((e) => e.account.id).toList();
      r.setMainCurrency('USD');
      final after = r.accountsByBalance();
      expect(after.map((e) => e.account.id), before);
      expect(
        after.first.balanceInMain,
        closeTo(
          r.toMain(after.first.balance, after.first.account.currency),
          0.01,
        ),
      );
    });

    test('is empty with no account', () {
      expect(MockRepository.newUser(now: _now).accountsByBalance(), isEmpty);
    });
  });

  test('the list of an account has both sides of a transfer', () {
    final repo = MockRepository(now: _now);
    final transfer = repo.transactions.firstWhere(
      (t) => t.type == TransactionType.transfer,
    );
    for (final id in [transfer.accountId, transfer.toAccountId!]) {
      final page = repo.searchTransactions(
        TransactionFilter(accountIds: {id}),
        pageSize: 1000,
      );
      expect(page.items.any((t) => t.id == transfer.id), isTrue);
      for (final t in page.items) {
        expect(t.accountId == id || t.toAccountId == id, isTrue);
      }
    }
  });
}
