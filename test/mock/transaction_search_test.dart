import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/date_utils.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_filter.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  final repo = MockRepository(now: now);
  final all = repo.transactions; // newest first, the oracle's input

  /// Every page of [filter], concatenated.
  List<Transaction> everything(TransactionFilter filter, {int size = 20}) {
    final first = repo.searchTransactions(filter, pageSize: size);
    return [
      for (var p = 1; p <= first.pageCount; p++)
        ...repo.searchTransactions(filter, page: p, pageSize: size).items,
    ];
  }

  List<String> ids(Iterable<Transaction> list) => [for (final t in list) t.id];

  bool inMonth(Transaction t, int month) =>
      t.date.year == 2026 && t.date.month == month;

  final month = TransactionFilter.forMonthOf(now);
  final lastMonth = TransactionFilter.forMonthOf(DateTime(2026, 9, 15));

  group('no filter and default filter', () {
    test('an empty filter returns every transaction, newest first', () {
      final result = everything(const TransactionFilter());
      expect(ids(result), ids(all));
      for (var i = 1; i < result.length; i++) {
        expect(result[i].date.isAfter(result[i - 1].date), isFalse);
      }
    });

    test('the default is the whole current month', () {
      expect(month.from, DateTime(2026, 10));
      expect(month.to, DateTime(2026, 10, 31));
      expect(ids(everything(month)), ids(all.where((t) => inMonth(t, 10))));
    });

    test('the date range includes its first and last day', () {
      final day = all.firstWhere((t) => t.date.month == 9).date;
      final f = const TransactionFilter().withDateRange(day, day);
      final result = everything(f);
      expect(result, isNotEmpty);
      expect(result.every((t) => dateOnly(t.date) == dateOnly(day)), isTrue);
      expect(
        result.length,
        all.where((t) => dateOnly(t.date) == dateOnly(day)).length,
      );
    });

    test('open-ended ranges', () {
      final cut = DateTime(2026, 9, 1);
      final from = const TransactionFilter().withDateRange(cut, null);
      final to = const TransactionFilter().withDateRange(null, cut);
      expect(
        everything(from).length + everything(to).length,
        // Only the cut day itself is counted twice.
        all.length + all.where((t) => dateOnly(t.date) == cut).length,
      );
    });
  });

  group('each filter alone', () {
    test('type', () {
      for (final type in TransactionType.values) {
        final result = everything(TransactionFilter(types: {type}));
        expect(result, isNotEmpty, reason: '$type');
        expect(result.every((t) => t.type == type), isTrue);
        expect(result.length, all.where((t) => t.type == type).length);
      }
      final two = everything(
        const TransactionFilter(
          types: {TransactionType.income, TransactionType.transfer},
        ),
      );
      expect(two.any((t) => t.type == TransactionType.expense), isFalse);
    });

    test('category (and it leaves transfers out)', () {
      final result = everything(
        const TransactionFilter(categoryIds: {'cat_home'}),
      );
      expect(result, isNotEmpty);
      expect(result.every((t) => t.categoryId == 'cat_home'), isTrue);
      final two = everything(
        const TransactionFilter(categoryIds: {'cat_home', 'cat_salary'}),
      );
      expect(two.length, greaterThan(result.length));
      expect(two.any((t) => t.type == TransactionType.transfer), isFalse);
    });

    test('account matches both sides of a transfer', () {
      final transfer = all.firstWhere(
        (t) => t.type == TransactionType.transfer,
      );
      for (final id in [transfer.accountId, transfer.toAccountId!]) {
        final result = everything(TransactionFilter(accountIds: {id}));
        expect(ids(result), contains(transfer.id));
        expect(
          result.every((t) => t.accountId == id || t.toAccountId == id),
          isTrue,
        );
      }
    });

    test('amount range, in the main currency, inclusive', () {
      double eur(Transaction t) => repo.toMain(t.amount, t.currency);
      final result = everything(
        const TransactionFilter().withAmountRange(50, 200),
      );
      expect(result, isNotEmpty);
      expect(result.every((t) => eur(t) >= 50 && eur(t) <= 200), isTrue);
      expect(
        result.length,
        all.where((t) => eur(t) >= 50 && eur(t) <= 200).length,
      );
      // Only a minimum, only a maximum.
      final atLeast = everything(
        const TransactionFilter().withAmountRange(500, null),
      );
      expect(atLeast, isNotEmpty);
      expect(atLeast.every((t) => eur(t) >= 500), isTrue);
      final atMost = everything(
        const TransactionFilter().withAmountRange(null, 20),
      );
      expect(atMost, isNotEmpty);
      expect(atMost.every((t) => eur(t) <= 20), isTrue);
    });
  });

  group('search', () {
    Set<String> found(String q) =>
        ids(everything(TransactionFilter(query: q))).toSet();

    test('matches description, category, subcategory and account', () {
      final byDescription = all.firstWhere((t) => t.description.length > 4);
      final word = byDescription.description.substring(0, 4).toUpperCase();
      expect(found(word), contains(byDescription.id));

      // Category name: every Home transaction, whatever its description.
      expect(
        found('home'),
        containsAll(
          all.where((t) => t.categoryId == 'cat_home').map((t) => t.id),
        ),
      );
      // Subcategory name.
      final withSub = all.firstWhere((t) => t.subcategoryId != null);
      final sub = repo.subcategory(withSub.subcategoryId!).name;
      expect(found(sub), contains(withSub.id));
      // Account name, destination account of a transfer included.
      final transfer = all.firstWhere(
        (t) => t.type == TransactionType.transfer,
      );
      final toName = repo.account(transfer.toAccountId!).name;
      expect(found(toName), contains(transfer.id));
    });

    test('is case-insensitive, trimmed, and blank text matches all', () {
      expect(
        ids(everything(const TransactionFilter(query: '  HOME '))),
        ids(everything(const TransactionFilter(query: 'home'))),
      );
      expect(
        everything(const TransactionFilter(query: '   ')).length,
        all.length,
      );
    });

    test('nothing matches nonsense', () {
      final page = repo.searchTransactions(
        const TransactionFilter(query: 'zzzzqqqq'),
      );
      expect(page.items, isEmpty);
      expect(page.total, 0);
      expect(page.pageCount, 0);
      expect(page.page, 1);
      expect(page.netByDay, isEmpty);
    });
  });

  group('combining filters', () {
    test('category + last month + type apply together', () {
      final f = lastMonth.copyWith(
        categoryIds: {'cat_home'},
        types: {TransactionType.expense},
      );
      final result = everything(f);
      expect(result, isNotEmpty);
      for (final t in result) {
        expect(t.categoryId, 'cat_home');
        expect(t.type, TransactionType.expense);
        expect(t.date.month, 9);
      }
      expect(
        result.length,
        all
            .where(
              (t) =>
                  t.categoryId == 'cat_home' &&
                  t.type == TransactionType.expense &&
                  inMonth(t, 9),
            )
            .length,
      );
      final narrower = everything(f.copyWith(query: 'rent'));
      expect(narrower.length, lessThanOrEqualTo(result.length));
      expect(ids(result), containsAll(ids(narrower)));
    });

    test('adding a filter never adds results', () {
      final base = everything(month);
      expect(
        everything(month.copyWith(accountIds: {repo.accounts.first.id})),
        isNotEmpty,
      );
      final plus = everything(
        month
            .copyWith(accountIds: {repo.accounts.first.id})
            .withAmountRange(10, null),
      );
      expect(ids(base), containsAll(ids(plus)));
    });
  });

  group('pagination', () {
    const none = TransactionFilter();

    test('pages of 20, in order, without gaps or repeats', () {
      final first = repo.searchTransactions(none);
      expect(first.total, all.length);
      expect(first.pageSize, 20);
      expect(first.pageCount, (all.length / 20).ceil());
      expect(first.items, hasLength(20));
      final seen = <String>[];
      for (var p = 1; p <= first.pageCount; p++) {
        final page = repo.searchTransactions(none, page: p);
        expect(page.page, p);
        expect(page.total, all.length);
        if (p < first.pageCount) expect(page.items, hasLength(20));
        seen.addAll(ids(page.items));
      }
      expect(seen, ids(all));
    });

    test('the last page can be partial', () {
      final first = repo.searchTransactions(none);
      final last = repo.searchTransactions(none, page: first.pageCount);
      expect(last.items, hasLength(all.length - 20 * (first.pageCount - 1)));
    });

    test('out-of-range pages are clamped', () {
      final first = repo.searchTransactions(none);
      expect(repo.searchTransactions(none, page: 0).page, 1);
      expect(repo.searchTransactions(none, page: 999).page, first.pageCount);
    });

    test('the example: category Home, last month, page 2', () {
      final f = lastMonth.copyWith(categoryIds: {'cat_home'});
      final matching = all
          .where((t) => t.categoryId == 'cat_home' && inMonth(t, 9))
          .toList();
      // Page size 2 so that the month spans several pages.
      final page2 = repo.searchTransactions(f, page: 2, pageSize: 2);
      expect(matching.length, greaterThan(2));
      expect(page2.total, matching.length);
      expect(page2.page, 2);
      expect(ids(page2.items), ids(matching.skip(2).take(2)));
    });

    test('a different page size is honoured', () {
      final page = repo.searchTransactions(none, pageSize: 7);
      expect(page.items, hasLength(7));
      expect(page.pageCount, (all.length / 7).ceil());
    });
  });

  group('day totals', () {
    test('income minus expenses of the whole day, transfers excluded', () {
      final page = repo.searchTransactions(month);
      expect(page.netByDay, isNotEmpty);
      for (final entry in page.netByDay.entries) {
        final day = all.where((t) => dateOnly(t.date) == entry.key);
        final expected = day.fold<double>(0, (sum, t) {
          if (t.type == TransactionType.transfer) return sum;
          final eur = repo.toMain(t.amount, t.currency);
          return sum + (t.type == TransactionType.income ? eur : -eur);
        });
        expect(entry.value, closeTo(expected, 0.01), reason: '${entry.key}');
      }
    });

    test('a day split over two pages has the same total on both', () {
      // A day with at least two transactions, and a page size that puts a
      // page boundary inside it.
      final byDay = <DateTime, List<Transaction>>{};
      for (final t in all) {
        byDay.putIfAbsent(dateOnly(t.date), () => []).add(t);
      }
      final day = byDay.entries.firstWhere((e) => e.value.length >= 2);
      final size = all.indexOf(day.value.first) + 1;
      const none = TransactionFilter();
      final p1 = repo.searchTransactions(none, pageSize: size, page: 1);
      final p2 = repo.searchTransactions(none, pageSize: size, page: 2);
      expect(p1.netByDay.containsKey(day.key), isTrue);
      expect(p2.netByDay.containsKey(day.key), isTrue);
      expect(p1.netByDay[day.key], p2.netByDay[day.key]);
    });

    test('totals respect the filters', () {
      final expenses = repo.searchTransactions(
        month.copyWith(types: {TransactionType.expense}),
      );
      expect(expenses.netByDay.values.every((v) => v < 0), isTrue);
    });

    test('days with only transfers have no total', () {
      final page = repo.searchTransactions(
        const TransactionFilter(types: {TransactionType.transfer}),
      );
      expect(page.items, isNotEmpty);
      expect(page.netByDay, isEmpty);
    });
  });

  group('filter object', () {
    test(
      'active filter count ignores the search text and the default date',
      () {
        expect(month.activeFilterCount(month), 0);
        expect(month.copyWith(query: 'x').activeFilterCount(month), 0);
        expect(lastMonth.activeFilterCount(month), 1);
        final many = month
            .copyWith(
              types: {TransactionType.income},
              categoryIds: {'cat_home'},
              accountIds: {repo.accounts.first.id},
            )
            .withAmountRange(1, null);
        expect(many.activeFilterCount(month), 4);
        expect(month.withDateRange(null, null).activeFilterCount(month), 1);
      },
    );

    test('equality compares sets and days, not instances or times', () {
      expect(
        TransactionFilter.forMonthOf(DateTime(2026, 10, 3, 8)),
        TransactionFilter.forMonthOf(DateTime(2026, 10, 28, 20)),
      );
      expect(
        month.copyWith(categoryIds: {'a', 'b'}),
        month.copyWith(categoryIds: {'b', 'a'}),
      );
      expect(month.copyWith(query: 'a'), isNot(month));
    });
  });
}
