import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/budget_status.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/date_utils.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';
import 'package:sossoldi/mock/models/transaction.dart';

/// Data depends on "today": check it on dates that stress the periods
/// (first of month, a Monday, new year, end of year) and on the real today.
final _dates = <String, DateTime>{
  'today': DateTime.now(),
  'first of month': DateTime(2026, 10, 1, 9),
  'monday': DateTime(2026, 10, 19, 9),
  'new year': DateTime(2027, 1, 1, 9),
  'end of year': DateTime(2026, 12, 31, 18),
};

void main() {
  for (final MapEntry(key: label, value: now) in _dates.entries) {
    group('data on $label', () {
      final repo = MockRepository(now: now);
      final accountIds = repo.accounts.map((a) => a.id).toSet();
      final categoryIds = repo.categories().map((c) => c.id).toSet();
      final subcategories = {
        for (final c in repo.categories())
          for (final s in repo.subcategoriesOf(c.id)) s.id: s,
      };

      test('every referenced id exists', () {
        final recurringIds = repo
            .recurringTransactions()
            .map((r) => r.id)
            .toSet();
        for (final t in repo.transactions) {
          expect(accountIds, contains(t.accountId));
          if (t.toAccountId != null) {
            expect(accountIds, contains(t.toAccountId));
          }
          if (t.categoryId != null) expect(categoryIds, contains(t.categoryId));
          if (t.subcategoryId != null) {
            expect(subcategories[t.subcategoryId]!.categoryId, t.categoryId);
          }
          if (t.recurringId != null) {
            expect(recurringIds, contains(t.recurringId));
          }
        }
        for (final r in repo.recurringTransactions()) {
          expect(accountIds, contains(r.accountId));
          if (r.toAccountId != null) {
            expect(accountIds, contains(r.toAccountId));
          }
          if (r.categoryId != null) expect(categoryIds, contains(r.categoryId));
        }
        for (final b in repo.budgets) {
          expect(categoryIds, contains(b.categoryId));
        }
        final assetIds = repo.assetCatalog.map((a) => a.id).toSet();
        for (final h in repo.holdings) {
          if (h.assetId != null) expect(assetIds, contains(h.assetId));
          if (h.accountId != null) expect(accountIds, contains(h.accountId));
        }
        final holdingIds = repo.holdings.map((h) => h.id).toSet();
        for (final m in repo.movements()) {
          // A cost can be about nothing in particular.
          if (m.holdingId != null) expect(holdingIds, contains(m.holdingId));
        }
      });

      test('ids are unique', () {
        final ids = repo.transactions.map((t) => t.id).toList();
        expect(ids.toSet().length, ids.length);
        final movementIds = repo.movements().map((m) => m.id).toList();
        expect(movementIds.toSet().length, movementIds.length);
      });

      test('transfers have a destination and no category', () {
        for (final t in repo.transactions) {
          final isTransfer = t.type == TransactionType.transfer;
          expect(t.toAccountId != null, isTransfer);
          if (isTransfer) expect(t.categoryId, isNull);
          if (!isTransfer) expect(t.categoryId, isNotNull);
          expect(t.amount, greaterThan(0));
          expect(t.date.isAfter(repo.today), isFalse);
        }
      });

      test('categories and subcategories are consistent', () {
        expect(repo.categories(type: CategoryType.expense), hasLength(8));
        expect(repo.categories(type: CategoryType.income), hasLength(4));
        for (final c in repo.categories()) {
          expect(repo.subcategoriesOf(c.id), isNotEmpty);
          expect(CategoryColors.all, contains(c.color));
        }
        for (final s in subcategories.values) {
          expect(categoryIds, contains(s.categoryId));
        }
      });

      test('budgets: one-to-many from category, none on subcategories', () {
        final expenseIds = {
          for (final c in repo.categories(type: CategoryType.expense)) c.id,
        };
        final subcategoryIds = {
          for (final c in repo.categories())
            for (final sub in repo.subcategoriesOf(c.id)) sub.id,
        };
        for (final c in repo.categories(type: CategoryType.expense)) {
          expect(repo.budgetsForCategory(c.id), isNotEmpty, reason: c.id);
        }
        for (final b in repo.budgets) {
          expect(expenseIds, contains(b.categoryId));
          expect(subcategoryIds, isNot(contains(b.categoryId)));
        }
        // At most one budget per category and period; ids are unique.
        final pairs = {for (final b in repo.budgets) (b.categoryId, b.period)};
        expect(pairs, hasLength(repo.budgets.length));
        expect({
          for (final b in repo.budgets) b.id,
        }, hasLength(repo.budgets.length));
        // At least two categories have budgets on different periods.
        final multi = [
          for (final c in repo.categories(type: CategoryType.expense))
            if (repo.budgetsForCategory(c.id).length > 1) c.id,
        ];
        expect(multi.length, greaterThanOrEqualTo(2));
        // Semiannual has none, so that its empty state can be seen.
        expect(
          repo.budgets.where((b) => b.period == BudgetPeriod.semiannual),
          isEmpty,
        );
      });

      test('budgets cover every state in the current period', () {
        final states = repo.budgetStatuses().map((s) => s.state).toList();
        expect(states.where((s) => s == BudgetState.ok), isNotEmpty);
        expect(states.where((s) => s == BudgetState.warning), isNotEmpty);
        expect(
          states.where((s) => s == BudgetState.exceeded).length,
          greaterThanOrEqualTo(2),
        );
      });

      test('purchases cover several years', () {
        final buys = repo.movements().where((m) => m.type == MovementType.buy);
        final oldest = buys
            .map((m) => m.date)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        expect(repo.today.difference(oldest).inDays, greaterThan(3 * 365));
        // Buys in at least three different calendar years.
        expect(buys.map((m) => m.date.year).toSet().length, greaterThan(2));
        // Every buy and sell is on a price the asset had that day or before.
        for (final m in repo.movements()) {
          if (m.type != MovementType.buy && m.type != MovementType.sell) {
            continue;
          }
          expect(m.date.isAfter(repo.today), isFalse);
        }
      });

      test('holding quantities and PMC match the movements', () {
        for (final h in repo.holdings) {
          final moves = repo.movements(holdingId: h.id);
          final buys = moves.where((m) => m.type == MovementType.buy);
          final sells = moves.where((m) => m.type == MovementType.sell);
          final quantity =
              buys.fold(0.0, (s, m) => s + m.quantity!) -
              sells.fold(0.0, (s, m) => s + m.quantity!);
          expect(h.quantity, closeTo(quantity, 1e-9), reason: h.id);
          // Average cost (PMC): the running average, a sell takes units out
          // at the average cost of that moment.
          var units = 0.0, cost = 0.0;
          for (final m in moves.reversed.where(
            (m) => m.type == MovementType.buy || m.type == MovementType.sell,
          )) {
            if (m.type == MovementType.buy) {
              units += m.quantity!;
              // The commission is part of what a buy cost.
              cost += m.quantity! * m.price! + m.fee;
            } else {
              cost -= cost / units * m.quantity!;
              units -= m.quantity!;
            }
          }
          expect(h.averageCost, closeTo(cost / units, 1e-3), reason: h.id);
          expect(
            replayHolding(moves).state!.averageCost,
            closeTo(h.averageCost, 1e-3),
          );
          expect(h.quantity, greaterThan(0));
        }
      });

      test(
        'portfolio has gains, losses, manual assets and expected dividends',
        () {
          final catalog = repo.holdings.where((h) => !h.isManual);
          expect(catalog.length, inInclusiveRange(6, 8));
          expect(repo.holdings.where((h) => h.isManual), isNotEmpty);
          expect(catalog.where((h) => repo.holdingGain(h.id) > 0), isNotEmpty);
          expect(catalog.where((h) => repo.holdingGain(h.id) < 0), isNotEmpty);
          expect(repo.expectedDividends, isNotEmpty);
        },
      );

      test('recurring next dates are in the future', () {
        for (final r in repo.recurringTransactions()) {
          expect(r.nextDate.isAfter(repo.today), isTrue, reason: r.id);
        }
        expect(
          repo.recurringTransactions(status: RecurringStatus.paused),
          isNotEmpty,
        );
      });

      test('full months have 30-50 transactions', () {
        final start = repo.today.subtract(const Duration(days: 182));
        for (
          var m = DateTime(start.year, start.month + 1);
          DateTime(m.year, m.month + 1).isBefore(repo.today);
          m = DateTime(m.year, m.month + 1)
        ) {
          final count = repo
              .transactionsInPeriod(m, DateTime(m.year, m.month + 1))
              .length;
          expect(count, inInclusiveRange(30, 50), reason: '$m');
        }
      });

      test('balance trend matches income minus expenses', () {
        final trend = repo.balanceTrend();
        final start = trend.periodStart;
        final tomorrow = DateTime(
          repo.today.year,
          repo.today.month,
          repo.today.day + 1,
        );
        expect(trend.current, hasLength(repo.today.day));
        expect(trend.net, closeTo(repo.netResult(start, tomorrow), 0.02));
        expect(
          trend.net,
          closeTo(
            repo.totalIncome(start, tomorrow) -
                repo.totalExpenses(start, tomorrow),
            0.02,
          ),
        );
        final previousStart = DateTime(start.year, start.month - 1);
        expect(
          trend.previous,
          hasLength(DateTime(start.year, start.month, 0).day),
        );
        expect(
          trend.previous.last,
          closeTo(repo.netResult(previousStart, start), 0.02),
        );
        expect(
          trend.daysInPeriod,
          DateTime(start.year, start.month + 1, 0).day,
        );
        expect(repo.mainCurrency, 'EUR');
        expect(trend.income, repo.totalIncome(start, tomorrow));
        expect(trend.expenses, repo.totalExpenses(start, tomorrow));
        expect(trend.income - trend.expenses, closeTo(trend.net, 0.02));
        final sameDay =
            trend.previous[trend.current.length <= trend.previous.length
                ? trend.current.length - 1
                : trend.previous.length - 1];
        expect(trend.vsPreviousSameDay, closeTo(trend.net - sameDay, 0.02));
      });

      test('latest transactions are the newest ones, in order', () {
        final latest = repo.latestTransactions(6);
        expect(latest, hasLength(6));
        expect(latest.first.id, repo.transactions.first.id);
        for (var i = 1; i < latest.length; i++) {
          expect(latest[i].date.isAfter(latest[i - 1].date), isFalse);
        }
      });

      test('catalog has 20-30 assets with five years of prices', () {
        expect(repo.assetCatalog.length, inInclusiveRange(20, 30));
        for (final a in repo.assetCatalog) {
          final history = repo.priceHistory(a.id);
          // About 260 trading days a year.
          expect(history.length, greaterThan(1250), reason: a.id);
          expect(history.every((p) => p.price > 0), isTrue);
          expect(history.every((p) => isTradingDay(p.date)), isTrue);
          // Oldest first, one price a day, no repeated day.
          for (var i = 1; i < history.length; i++) {
            expect(history[i].date.isAfter(history[i - 1].date), isTrue);
          }
          expect(
            history.first.date.isBefore(
              DateTime(repo.today.year - 4, repo.today.month, repo.today.day),
            ),
            isTrue,
          );
          // No jump between the years (the volatile stocks still move a lot a day).
          for (var i = 1; i < history.length; i++) {
            final change = history[i].price / history[i - 1].price - 1;
            expect(change.abs(), lessThan(0.2), reason: '${a.id} $i');
          }
        }
        expect(repo.searchAssets('vwce').single.isin, 'IE00BK5BQT80');
        expect(repo.searchAssets('apple'), hasLength(1));
      });
    });
  }

  test('same "now" gives the same data', () {
    final now = DateTime(2026, 10, 22, 10);
    final a = MockRepository(now: now);
    final b = MockRepository(now: now);
    expect(
      a.transactions.map((t) => '${t.id}${t.date}${t.amount}${t.description}'),
      b.transactions.map((t) => '${t.id}${t.date}${t.amount}${t.description}'),
    );
    expect(
      a.priceHistory('ast_aapl').map((p) => p.price),
      b.priceHistory('ast_aapl').map((p) => p.price),
    );
    expect(a.portfolioValue, b.portfolioValue);
  });
}
