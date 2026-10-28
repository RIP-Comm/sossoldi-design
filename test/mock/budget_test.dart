import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/date_utils.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/budget_status.dart';
import 'package:sossoldi/mock/models/transaction.dart';

double _sum(Iterable<double> v) => v.fold(0.0, (a, b) => a + b);

void main() {
  group('periods', () {
    test(
      'rangeContaining: weeks start on Monday, the rest follow the calendar',
      () {
        final wed = DateTime(2026, 10, 21);
        expect(BudgetPeriod.weekly.rangeContaining(wed), (
          start: DateTime(2026, 10, 19),
          end: DateTime(2026, 10, 26),
        ));
        // A Sunday belongs to the week that started on the Monday before.
        expect(
          BudgetPeriod.weekly.rangeContaining(DateTime(2026, 10, 25)).start,
          DateTime(2026, 10, 19),
        );
        expect(
          BudgetPeriod.weekly.rangeContaining(DateTime(2026, 10, 26)).start,
          DateTime(2026, 10, 26),
        );
        expect(BudgetPeriod.monthly.rangeContaining(wed), (
          start: DateTime(2026, 10),
          end: DateTime(2026, 11),
        ));
        expect(BudgetPeriod.quarterly.rangeContaining(wed), (
          start: DateTime(2026, 10),
          end: DateTime(2027),
        ));
        expect(BudgetPeriod.quarterly.rangeContaining(DateTime(2026, 5, 3)), (
          start: DateTime(2026, 4),
          end: DateTime(2026, 7),
        ));
        expect(BudgetPeriod.semiannual.rangeContaining(wed), (
          start: DateTime(2026, 7),
          end: DateTime(2027),
        ));
        expect(BudgetPeriod.semiannual.rangeContaining(DateTime(2026, 6, 30)), (
          start: DateTime(2026),
          end: DateTime(2026, 7),
        ));
        expect(BudgetPeriod.yearly.rangeContaining(wed), (
          start: DateTime(2026),
          end: DateTime(2027),
        ));
      },
    );
  });

  group('states', () {
    test('ok under 80%, warning from 80% to 100%, exceeded over 100%', () {
      BudgetState at(double usage) => BudgetStatus.stateForUsage(usage);
      expect(at(0), BudgetState.ok);
      expect(at(0.79), BudgetState.ok);
      expect(at(0.8), BudgetState.warning);
      expect(at(1.0), BudgetState.warning);
      expect(at(1.0001), BudgetState.exceeded);
      expect(at(3), BudgetState.exceeded);
    });

    test(
      'a status derives remaining, over-by and usage from amount and spent',
      () {
        const budget = Budget(
          id: 'b',
          categoryId: 'cat_home',
          amount: 200,
          currency: 'EUR',
          period: BudgetPeriod.monthly,
        );
        BudgetStatus status(double spent) => BudgetStatus(
          budget: budget,
          amount: 200,
          spent: spent,
          currency: 'EUR',
          periodStart: DateTime(2026, 10),
          periodEnd: DateTime(2026, 11),
        );
        final ok = status(100);
        expect((ok.usage, ok.remaining, ok.overBy), (0.5, 100, 0));
        expect(ok.state, BudgetState.ok);
        final edge = status(160);
        expect(edge.state, BudgetState.warning);
        final full = status(200);
        expect((full.remaining, full.overBy), (0, 0));
        expect(full.state, BudgetState.warning);
        final over = status(250);
        expect((over.remaining, over.overBy), (-50, 50));
        expect(over.usage, 1.25);
        expect(over.state, BudgetState.exceeded);
      },
    );
  });

  final nows = {
    'a regular day': DateTime(2026, 10, 22, 10),
    'first of month': DateTime(2026, 10, 1, 10),
    'a Monday': DateTime(2026, 10, 19, 10),
    'a Sunday': DateTime(2026, 10, 25, 10),
    'new year': DateTime(2027, 1, 1, 10),
    'end of year': DateTime(2026, 12, 31, 10),
  };

  for (final MapEntry(key: label, value: now) in nows.entries) {
    group('on $label', () {
      final repo = MockRepository(now: now);

      /// Expenses of [categoryId] in the period of [period] containing today.
      double oracle(String categoryId, BudgetPeriod period) {
        final r = period.rangeContaining(repo.today);
        var cents = 0;
        for (final t in repo.transactions) {
          if (t.type == TransactionType.expense &&
              t.categoryId == categoryId &&
              !t.date.isBefore(r.start) &&
              t.date.isBefore(r.end)) {
            cents += (repo.toMain(t.amount, t.currency) * 100).round();
          }
        }
        return cents / 100;
      }

      test(
        'every budget counts the expenses of its category in its own period',
        () {
          for (final b in repo.budgets) {
            final s = repo.budgetStatus(b);
            expect(s.spent, oracle(b.categoryId, b.period), reason: b.id);
            expect(s.amount, b.amount);
            expect(s.currency, 'EUR');
            expect(s.remaining, closeTo(b.amount - s.spent, 1e-9));
          }
        },
      );

      test('two budgets of one category on different periods differ', () {
        final groceries = repo.budgetsForCategory('cat_groceries');
        expect(groceries.map((b) => b.period), [
          BudgetPeriod.weekly,
          BudgetPeriod.monthly,
        ]);
        final week = repo.budgetStatus(groceries[0]);
        final month = repo.budgetStatus(groceries[1]);
        expect(week.periodStart.weekday, DateTime.monday);
        expect(
          week.periodEnd,
          DateTime(
            week.periodStart.year,
            week.periodStart.month,
            week.periodStart.day + 7,
          ),
        );
        expect(month.periodStart.day, 1);
        expect(week.periodStart, isNot(month.periodStart));
      });

      test('overview: totals and order', () {
        for (final period in BudgetPeriod.values) {
          final o = repo.budgetOverview(period);
          expect(o.period, period);
          expect(o.items.every((s) => s.budget.period == period), isTrue);
          expect(
            o.items.length,
            repo.budgets.where((b) => b.period == period).length,
          );
          expect(o.total, closeTo(_sum(o.items.map((s) => s.amount)), 0.01));
          expect(o.spent, closeTo(_sum(o.items.map((s) => s.spent)), 0.01));
          expect(o.remaining, closeTo(o.total - o.spent, 1e-9));
          for (var i = 1; i < o.items.length; i++) {
            expect(o.items[i].amount, lessThanOrEqualTo(o.items[i - 1].amount));
          }
        }
      });

      test(
        'the bar is the total budget; the colored parts are the spending',
        () {
          for (final period in BudgetPeriod.values) {
            final o = repo.budgetOverview(period);
            if (o.isEmpty) continue;
            final reason = '$period';
            // One part per budget that spent something, in the order of the items.
            final spending = o.items.where((s) => s.spent > 0).toList();
            expect(o.segments, hasLength(spending.length), reason: reason);
            final bar = o.spent > o.total ? o.spent : o.total;
            for (final (i, seg) in o.segments.indexed) {
              final s = spending[i];
              expect(seg.budgetId, s.budget.id);
              expect(seg.categoryId, s.budget.categoryId);
              // As wide as what it spent over the whole bar.
              expect(seg.share, closeTo(s.spent / bar, 1e-9), reason: reason);
              expect(seg.exceeded, s.state == BudgetState.exceeded);
            }
            final covered = _sum(o.segments.map((s) => s.share));
            // The parts cover as much of the bar as the overall usage...
            expect(covered, closeTo(o.usage.clamp(0.0, 1.0), 1e-9));
            // ...and the rest is the neutral part.
            expect(o.emptyShare, closeTo(1 - covered, 1e-9));
            expect(covered + o.emptyShare, closeTo(1, 1e-9));
          }
        },
      );

      test(
        'a budget that is over its limit does not take room from the others',
        () {
          final o = repo.budgetOverview(BudgetPeriod.monthly);
          final exceeded = o.items.where(
            (s) => s.state == BudgetState.exceeded,
          );
          expect(exceeded, isNotEmpty);
          // While the total is not reached, every part is its own spending over
          // the total budget: the others do not shrink because one went over.
          expect(o.usage, lessThan(1));
          for (final s in exceeded) {
            expect(s.overBy, greaterThan(0));
            final seg = o.segments.firstWhere((x) => x.budgetId == s.budget.id);
            expect(seg.exceeded, isTrue);
            expect(seg.share, closeTo(s.spent / o.total, 1e-9));
          }
          for (final seg in o.segments.where((x) => !x.exceeded)) {
            final s = o.items.firstWhere((x) => x.budget.id == seg.budgetId);
            expect(seg.share, closeTo(s.spent / o.total, 1e-9));
          }
          expect(o.emptyShare, greaterThan(0));
        },
      );

      test(
        'when the total is exceeded the bar is full and the parts share it',
        () {
          final r = MockRepository(now: now);
          for (final b in r.budgets.where(
            (b) => b.period == BudgetPeriod.monthly,
          )) {
            r.updateBudgetAmount(b.id, 1);
          }
          final o = r.budgetOverview(BudgetPeriod.monthly);
          expect(o.spent, greaterThan(o.total));
          expect(o.state, BudgetState.exceeded);
          expect(_sum(o.segments.map((s) => s.share)), closeTo(1, 1e-9));
          expect(o.emptyShare, 0);
          for (final seg in o.segments) {
            final s = o.items.firstWhere((x) => x.budget.id == seg.budgetId);
            expect(seg.share, closeTo(s.spent / o.spent, 1e-9));
          }
        },
      );

      test('the overall figures match the sum of the budgets, overspending included', () {
        final o = repo.budgetOverview(BudgetPeriod.monthly);
        expect(o.usage, closeTo(o.spent / o.total, 1e-9));
        expect(o.state, BudgetStatus.stateForUsage(o.usage));
        expect(
          o.overBy,
          o.spent > o.total ? closeTo(o.spent - o.total, 1e-9) : 0,
        );
      });

      test('a period without budgets is empty', () {
        final o = repo.budgetOverview(BudgetPeriod.semiannual);
        expect(o.isEmpty, isTrue);
        expect(o.total, 0);
        expect(o.spent, 0);
        expect(o.segments, isEmpty);
        expect(o.emptyShare, 1);
        expect(o.usage, 0);
        expect(o.state, BudgetState.ok);
      });

      test('the transactions of a budget add up to what is spent', () {
        for (final b in repo.budgets) {
          final filter = repo.budgetTransactionFilter(b.id);
          final s = repo.budgetStatus(b);
          expect(filter.categoryIds, {b.categoryId});
          expect(filter.from, s.periodStart);
          expect(
            filter.to,
            DateTime(s.periodEnd.year, s.periodEnd.month, s.periodEnd.day - 1),
          );
          final first = repo.searchTransactions(filter);
          var net = 0.0;
          var count = 0;
          for (var p = 1; p <= first.pageCount; p++) {
            final page = repo.searchTransactions(filter, page: p);
            net += _sum(page.netByDay.values);
            count += page.items.length;
            expect(
              page.items.every((t) => t.type == TransactionType.expense),
              isTrue,
            );
            expect(
              page.items.every((t) => t.categoryId == b.categoryId),
              isTrue,
            );
          }
          expect(count, first.total);
          expect(-net, closeTo(s.spent, 0.02), reason: b.id);
        }
      });
    });
  }

  group('without spending', () {
    test('a budget on a period with no transactions is untouched', () {
      final repo = MockRepository(now: DateTime(2026, 10, 22, 10));
      final long = DateTime(2020, 5, 5);
      final b = repo.budgetsForCategory('cat_home').first;
      final s = repo.budgetStatus(b, on: long);
      expect(s.spent, 0);
      expect(s.usage, 0);
      expect(s.state, BudgetState.ok);
      expect(s.remaining, s.amount);
      expect(s.overBy, 0);
      final o = repo.budgetOverview(BudgetPeriod.monthly, on: long);
      expect(o.spent, 0);
      expect(o.segments, isEmpty);
      expect(o.emptyShare, 1);
      final filter = repo.budgetTransactionFilter(b.id, on: long);
      expect(repo.searchTransactions(filter).items, isEmpty);
    });
  });

  group('main currency', () {
    test('amounts follow it, usage and state do not', () {
      final now = DateTime(2026, 10, 22, 10);
      final eur = MockRepository(now: now);
      final usd = MockRepository(now: now)..setMainCurrency('USD');
      final rate = eur.toEur(1, 'USD');
      for (final period in BudgetPeriod.values) {
        final a = eur.budgetOverview(period);
        final b = usd.budgetOverview(period);
        expect(b.currency, 'USD');
        expect(b.total, closeTo(a.total / rate, 0.05));
        expect(b.usage, closeTo(a.usage, 0.002));
        expect(b.state, a.state);
        for (final (i, s) in a.items.indexed) {
          expect(b.items[i].budget.id, s.budget.id);
          expect(b.items[i].usage, closeTo(s.usage, 0.002));
          expect(b.items[i].state, s.state);
        }
      }
    });
  });

  group('editing and deleting', () {
    late MockRepository repo;
    late Budget home;
    setUp(() {
      repo = MockRepository(now: DateTime(2026, 10, 22, 10));
      home = repo.budgetsForCategory('cat_home').first;
    });

    test('a new amount shows up everywhere, and only for that budget', () {
      final before = repo.budgetOverview(BudgetPeriod.monthly);
      final others = {
        for (final b in repo.budgets)
          if (b.id != home.id) b.id: b.amount,
      };
      repo.updateBudgetAmount(home.id, 1234.5);
      expect(repo.budget(home.id).amount, 1234.5);
      final after = repo.budgetOverview(BudgetPeriod.monthly);
      expect(
        after.total,
        closeTo(
          before.total -
              before.items.firstWhere((s) => s.budget.id == home.id).amount +
              1234.5,
          0.01,
        ),
      );
      expect(after.items.first.budget.id, home.id); // now the largest
      for (final b in repo.budgets) {
        if (b.id != home.id) expect(b.amount, others[b.id]);
      }
    });

    test(
      'the amount is given in the main currency and stored in the budget\'s',
      () {
        repo.setMainCurrency('USD');
        repo.updateBudgetAmount(home.id, 100);
        final rate = repo.toEur(1, 'USD');
        expect(repo.budget(home.id).currency, 'EUR');
        expect(repo.budget(home.id).amount, closeTo(100 * rate, 0.01));
        expect(
          repo.budgetStatus(repo.budget(home.id)).amount,
          closeTo(100, 0.02),
        );
      },
    );

    test('a new amount can change the state', () {
      final spent = repo.budgetStatus(home).spent;
      repo.updateBudgetAmount(home.id, spent + 1);
      expect(
        repo.budgetStatus(repo.budget(home.id)).state,
        BudgetState.warning,
      );
      repo.updateBudgetAmount(home.id, spent / 2);
      expect(
        repo.budgetStatus(repo.budget(home.id)).state,
        BudgetState.exceeded,
      );
      repo.updateBudgetAmount(home.id, spent * 10);
      expect(repo.budgetStatus(repo.budget(home.id)).state, BudgetState.ok);
    });

    test('invalid amounts are refused and change nothing', () {
      var notified = 0;
      repo.addListener(() => notified++);
      for (final bad in [0.0, -5.0, double.nan, double.infinity]) {
        expect(
          () => repo.updateBudgetAmount(home.id, bad),
          throwsArgumentError,
        );
      }
      expect(repo.budget(home.id).amount, home.amount);
      expect(notified, 0);
    });

    test('listeners hear about edits and deletions', () {
      var notified = 0;
      repo.addListener(() => notified++);
      repo.updateBudgetAmount(home.id, 500);
      repo.deleteBudget(home.id);
      expect(notified, 2);
    });

    test(
      'deleting removes only that budget; its category keeps the others',
      () {
        final groceries = repo.budgetsForCategory('cat_groceries');
        final count = repo.budgets.length;
        repo.deleteBudget(groceries.first.id);
        expect(repo.budgets, hasLength(count - 1));
        expect(repo.budgetsForCategory('cat_groceries'), [groceries.last]);
        final weekly = repo.budgetOverview(BudgetPeriod.weekly);
        expect(
          weekly.items.any((s) => s.budget.id == groceries.first.id),
          isFalse,
        );
      },
    );

    test('deleting the last budget of a period leaves it empty', () {
      for (final b
          in repo.budgets
              .where((b) => b.period == BudgetPeriod.yearly)
              .toList()) {
        repo.deleteBudget(b.id);
      }
      final o = repo.budgetOverview(BudgetPeriod.yearly);
      expect(o.isEmpty, isTrue);
      expect(o.total, 0);
    });

    test('totals stay consistent after a deletion', () {
      final before = repo.budgetOverview(BudgetPeriod.monthly);
      final gone = before.items.last;
      repo.deleteBudget(gone.budget.id);
      final after = repo.budgetOverview(BudgetPeriod.monthly);
      expect(after.total, closeTo(before.total - gone.amount, 0.01));
      expect(after.spent, closeTo(before.spent - gone.spent, 0.01));
      expect(
        _sum(after.segments.map((s) => s.share)),
        closeTo(after.usage.clamp(0.0, 1.0), 1e-9),
      );
    });
  });

  test('the spending date helpers agree with the calendar', () {
    expect(dateOnly(DateTime(2026, 10, 22, 23, 59)), DateTime(2026, 10, 22));
  });
}
