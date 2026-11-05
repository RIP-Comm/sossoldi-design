import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account.dart';
import 'package:sossoldi/mock/models/net_worth.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_edit.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  group('net worth', () {
    test('accounts plus positions, the liquidity counted once', () {
      final r = MockRepository(now: _now);
      final s = r.portfolioSummary();
      expect(r.netWorth, closeTo(r.totalBalance + s.marketValue, 0.011));
      // Same thing seen from the portfolio: the other accounts plus
      // positions and liquidity.
      expect(
        r.netWorth,
        closeTo(r.totalBalance - r.liquidity + s.totalValue, 0.011),
      );
      expect(r.liquidity, isNonZero);
    });

    test('the series ends today at the current value', () {
      final r = MockRepository(now: _now);
      for (final p in NetWorthPeriod.values) {
        final s = r.netWorthSeries(p);
        expect(s.current, r.netWorth);
        expect(s.points.last.value, r.netWorth);
        expect(s.points.last.time, DateTime(2026, 10, 22));
        expect(s.change, closeTo(s.current - s.points.first.value, 1e-9));
      }
    });

    test('a transfer between accounts, or to the broker, changes nothing', () {
      final a = MockRepository(now: _now);
      final b = MockRepository(now: _now);
      final from = b.accounts.firstWhere((x) => x.type == AccountType.checking);
      final broker = b.accounts.firstWhere((x) => x.type == AccountType.broker);
      final before = b.netWorth;
      final result = b.addTransaction(
        TransactionDraft(
          type: TransactionType.transfer,
          amount: 500,
          accountId: from.id,
          toAccountId: broker.id,
          date: DateTime(2026, 9, 10),
        ),
      );
      expect(result.ok, isTrue);
      expect(b.netWorth, closeTo(before, 0.011));
      for (final day in [
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 10),
        DateTime(2026, 9, 20),
        DateTime(2026, 10, 21),
      ]) {
        expect(b.netWorthAt(day), closeTo(a.netWorthAt(day), 0.011));
      }
    });

    test('history: about four years, so 5Y is not covered and 1Y is', () {
      final r = MockRepository(now: _now);
      expect(r.netWorthPeriodAvailable(NetWorthPeriod.threeMonths), isTrue);
      expect(r.netWorthPeriodAvailable(NetWorthPeriod.year), isTrue);
      expect(r.netWorthPeriodAvailable(NetWorthPeriod.threeYears), isTrue);
      expect(r.netWorthPeriodAvailable(NetWorthPeriod.fiveYears), isFalse);
      expect(r.netWorthPeriodAvailable(NetWorthPeriod.all), isTrue);
      final all = r.netWorthSeries(NetWorthPeriod.all);
      expect(all.points.first.time, r.netWorthHistoryStart);
      // An uncovered period starts where the history does.
      expect(
        r.netWorthSeries(NetWorthPeriod.fiveYears).points.first.time,
        r.netWorthHistoryStart,
      );
    });

    test('sampling: daily up to 6 months, weekly for a year', () {
      final r = MockRepository(now: _now);
      final three = r.netWorthSeries(NetWorthPeriod.threeMonths).points;
      expect(three[1].time.difference(three[0].time).inDays, 1);
      final year = r.netWorthSeries(NetWorthPeriod.year).points;
      expect(year[1].time.difference(year[0].time).inDays, 7);
      expect(year.length, lessThan(60));
    });

    test('change and percentage; no percentage from a start at or below 0', () {
      final up = NetWorthSeries(
        period: NetWorthPeriod.year,
        currency: 'EUR',
        current: 1100,
        points: [
          NetWorthPoint(time: DateTime(2026, 1, 1), value: 1000),
          NetWorthPoint(time: DateTime(2026, 10, 22), value: 1100),
        ],
      );
      expect(up.change, 100);
      expect(up.changePercent, closeTo(0.1, 1e-9));
      final negative = NetWorthSeries(
        period: NetWorthPeriod.year,
        currency: 'EUR',
        current: 50,
        points: [
          NetWorthPoint(time: DateTime(2026, 1, 1), value: -100),
          NetWorthPoint(time: DateTime(2026, 10, 22), value: 50),
        ],
      );
      expect(negative.change, 150);
      expect(negative.changePercent, isNull);
      final zero = NetWorthSeries(
        period: NetWorthPeriod.year,
        currency: 'EUR',
        current: 50,
        points: [
          NetWorthPoint(time: DateTime(2026, 1, 1), value: 0),
          NetWorthPoint(time: DateTime(2026, 10, 22), value: 50),
        ],
      );
      expect(zero.changePercent, isNull);
      final single = NetWorthSeries(
        period: NetWorthPeriod.year,
        currency: 'EUR',
        current: 50,
        points: [NetWorthPoint(time: DateTime(2026, 10, 22), value: 50)],
      );
      expect(single.change, isNull);
      expect(single.start, isNull);
    });

    test('a new user: zero, no change, no period covered', () {
      final r = MockRepository.newUser(now: _now);
      final s = r.netWorthSeries(NetWorthPeriod.year);
      expect(s.current, 0);
      expect(s.change, isNull);
      expect(s.points, hasLength(1));
      for (final p in NetWorthPeriod.values) {
        expect(r.netWorthPeriodAvailable(p), isFalse);
      }
    });

    test('without investments the value is the accounts', () {
      final r = MockRepository(
        now: _now,
        accounts: [mockAccounts.first],
        investments: (_, _) => (holdings: const [], movements: const []),
      );
      expect(r.portfolioValue, 0);
      expect(r.netWorth, r.totalBalance);
      final s = r.netWorthSeries(NetWorthPeriod.threeMonths);
      expect(s.current, r.totalBalance);
      expect(
        s.points.first.value,
        closeTo(r.netWorthAt(s.points.first.time), 1e-9),
      );
    });
  });
}
