import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget_status.dart';
import 'package:sossoldi/mock/models/category.dart';
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
          expect(holdingIds, contains(m.holdingId));
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
          expect(c.colorIndex, lessThan(CategoryColors.all.length));
        }
        for (final s in subcategories.values) {
          expect(categoryIds, contains(s.categoryId));
        }
      });

      test('every expense category has exactly one budget', () {
        for (final c in repo.categories(type: CategoryType.expense)) {
          expect(repo.budgets.where((b) => b.categoryId == c.id), hasLength(1));
        }
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

      test('holding quantities and PMC match the movements', () {
        for (final h in repo.holdings) {
          final moves = repo.movements(holdingId: h.id);
          final buys = moves.where((m) => m.type == MovementType.buy);
          final sells = moves.where((m) => m.type == MovementType.sell);
          final quantity =
              buys.fold(0.0, (s, m) => s + m.quantity!) -
              sells.fold(0.0, (s, m) => s + m.quantity!);
          expect(h.quantity, closeTo(quantity, 1e-9), reason: h.id);
          final units = buys.fold(0.0, (s, m) => s + m.quantity!);
          final cost = buys.fold(0.0, (s, m) => s + m.quantity! * m.price!);
          expect(h.averageCost, closeTo(cost / units, 1e-3), reason: h.id);
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

      test('catalog has 20-30 assets with one year of prices', () {
        expect(repo.assetCatalog.length, inInclusiveRange(20, 30));
        for (final a in repo.assetCatalog) {
          final history = repo.priceHistory(a.id);
          expect(history.length, greaterThan(250));
          expect(history.every((p) => p.price > 0), isTrue);
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
