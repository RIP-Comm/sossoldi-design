import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/date_utils.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_time_range.dart';

double _sum(Iterable<double> v) => v.fold(0.0, (a, b) => a + b);

void main() {
  group('time ranges', () {
    final today = DateTime(2026, 10, 22);

    test('resolve to the expected days', () {
      DateRange r(TransactionTimeRange t) => t.resolve(today);
      expect(
        r(TransactionTimeRange.currentMonth),
        DateRange(DateTime(2026, 10), today),
      );
      expect(
        r(TransactionTimeRange.lastMonth),
        DateRange(DateTime(2026, 9), DateTime(2026, 9, 30)),
      );
      expect(
        r(TransactionTimeRange.last3Months),
        DateRange(DateTime(2026, 8), today),
      );
      expect(
        r(TransactionTimeRange.last6Months),
        DateRange(DateTime(2026, 5), today),
      );
      expect(
        r(TransactionTimeRange.yearToDate),
        DateRange(DateTime(2026), today),
      );
      expect(
        r(TransactionTimeRange.last12Months),
        DateRange(DateTime(2025, 11), today),
      );
    });

    test('the previous period has the same length and ends the day before', () {
      for (final t in TransactionTimeRange.values) {
        final range = t.resolve(today);
        final previous = range.previous;
        expect(previous.days, range.days, reason: '$t');
        expect(
          previous.end,
          DateTime(range.start.year, range.start.month, range.start.day - 1),
        );
      }
      final month = TransactionTimeRange.currentMonth.resolve(today).previous;
      expect(month, DateRange(DateTime(2026, 9, 9), DateTime(2026, 9, 30)));
      final last = TransactionTimeRange.lastMonth.resolve(today).previous;
      expect(last, DateRange(DateTime(2026, 8, 2), DateTime(2026, 8, 31)));
    });

    test('granularity: weekly always, monthly from 2 months, default at 6', () {
      const weekly = TransactionGranularity.weekly;
      const monthly = TransactionGranularity.monthly;
      DateRange r(TransactionTimeRange t) => t.resolve(today);
      expect(r(TransactionTimeRange.currentMonth).allowedGranularities, [
        weekly,
      ]);
      expect(r(TransactionTimeRange.lastMonth).allowedGranularities, [weekly]);
      expect(r(TransactionTimeRange.last3Months).allowedGranularities, [
        weekly,
        monthly,
      ]);
      expect(r(TransactionTimeRange.last3Months).defaultGranularity, weekly);
      expect(r(TransactionTimeRange.last6Months).defaultGranularity, monthly);
      expect(r(TransactionTimeRange.last12Months).defaultGranularity, monthly);
      expect(r(TransactionTimeRange.yearToDate).defaultGranularity, monthly);
      // Year to date in February is two months: weekly by default.
      final feb = TransactionTimeRange.yearToDate.resolve(
        DateTime(2026, 2, 10),
      );
      expect(feb.defaultGranularity, weekly);
      expect(feb.allowedGranularities, contains(monthly));
      // In January it is one month: weekly only.
      final jan = TransactionTimeRange.yearToDate.resolve(
        DateTime(2026, 1, 20),
      );
      expect(jan.allowedGranularities, [weekly]);
    });
  });

  // The consistency checks run on several "now" dates, like the repository
  // test does: real today, first of month, a Monday, new year, year end.
  final nows = {
    'a regular day': DateTime(2026, 10, 22, 10),
    'first of month': DateTime(2026, 10, 1, 10),
    'a Monday': DateTime(2026, 10, 19, 10),
    'new year': DateTime(2027, 1, 1, 10),
    'end of year': DateTime(2026, 12, 31, 10),
  };

  for (final MapEntry(key: label, value: now) in nows.entries) {
    group('breakdown on $label', () {
      final repo = MockRepository(now: now);

      /// Brute-force total of the kind in [range], in cents, as an oracle.
      double oracle(
        DateRange range,
        TransactionKind kind, {
        Set<String> accounts = const {},
        Set<String> categories = const {},
      }) {
        final type = kind == TransactionKind.expense
            ? TransactionType.expense
            : TransactionType.income;
        var cents = 0;
        for (final t in repo.transactions) {
          if (t.type != type || !range.contains(t.date)) continue;
          if (accounts.isNotEmpty && !accounts.contains(t.accountId)) continue;
          if (categories.isNotEmpty && !categories.contains(t.categoryId)) {
            continue;
          }
          cents += (repo.toMain(t.amount, t.currency) * 100).round();
        }
        return cents / 100;
      }

      test(
        'total = sum of categories = sum of buckets, for every combination',
        () {
          for (final range in TransactionTimeRange.values) {
            for (final kind in TransactionKind.values) {
              final resolved = range.resolve(repo.today);
              for (final g in resolved.allowedGranularities) {
                final b = repo.transactionBreakdown(
                  range: range,
                  kind: kind,
                  granularity: g,
                );
                final reason = '$range $kind $g';
                expect(b.total, oracle(resolved, kind), reason: reason);
                expect(
                  _sum(b.categories.map((c) => c.amount)),
                  closeTo(b.total, 0.001),
                  reason: reason,
                );
                expect(
                  _sum(b.buckets.map((x) => x.total)),
                  closeTo(b.total, 0.001),
                  reason: reason,
                );
                expect(b.previousTotal, oracle(resolved.previous, kind));
                // Per category: the buckets add up to the category's total.
                for (final c in b.categories) {
                  final over = _sum(
                    b.buckets.map((x) => x.amounts[c.categoryId] ?? 0),
                  );
                  expect(over, closeTo(c.amount, 0.001), reason: reason);
                }
              }
            }
          }
        },
      );

      test('categories are top-level, sorted, and only those with money', () {
        final parents = {for (final c in repo.categories()) c.id};
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
        );
        expect(b.categories, isNotEmpty);
        for (final c in b.categories) {
          expect(parents, contains(c.categoryId));
          expect(c.amount, greaterThan(0));
          expect(repo.category(c.categoryId).type, CategoryType.expense);
        }
        for (var i = 1; i < b.categories.length; i++) {
          expect(
            b.categories[i].amount,
            lessThanOrEqualTo(b.categories[i - 1].amount),
          );
        }
        expect(
          {for (final c in b.categories) c.categoryId}.length,
          b.categories.length,
        );
      });

      test('income and expenses are kept apart', () {
        final income = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.income,
        );
        expect(income.categories, isNotEmpty);
        expect(
          income.categories.every(
            (c) => repo.category(c.categoryId).type == CategoryType.income,
          ),
          isTrue,
        );
      });

      test('transfers never count', () {
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.last12Months,
          kind: TransactionKind.expense,
        );
        final transferTotal = _sum([
          for (final t in repo.transactions)
            if (t.type == TransactionType.transfer) t.amount,
        ]);
        expect(transferTotal, greaterThan(0));
        expect(
          b.total,
          oracle(b.range, TransactionKind.expense),
          reason: 'only expenses are added up',
        );
      });

      test(
        'weekly buckets: contiguous, Monday to Sunday, cut to the range',
        () {
          for (final range in TransactionTimeRange.values) {
            final b = repo.transactionBreakdown(
              range: range,
              kind: TransactionKind.expense,
              granularity: TransactionGranularity.weekly,
            );
            expect(b.granularity, TransactionGranularity.weekly);
            expect(b.buckets.first.start, b.range.start);
            expect(b.buckets.last.end, b.range.end);
            for (var i = 0; i < b.buckets.length; i++) {
              final x = b.buckets[i];
              expect(x.start.weekday == DateTime.monday || i == 0, isTrue);
              expect(
                x.end.weekday == DateTime.sunday || i == b.buckets.length - 1,
                isTrue,
              );
              expect(x.end.isBefore(x.start), isFalse);
              if (i > 0) {
                expect(
                  dateOnly(x.start),
                  DateTime(
                    b.buckets[i - 1].end.year,
                    b.buckets[i - 1].end.month,
                    b.buckets[i - 1].end.day + 1,
                  ),
                );
              }
            }
          }
        },
      );

      test('monthly buckets are calendar months, cut to the range', () {
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
        );
        expect(b.granularity, TransactionGranularity.monthly);
        expect(b.buckets, hasLength(b.range.monthsSpanned));
        expect(b.buckets.first.start, b.range.start);
        expect(b.buckets.last.end, b.range.end);
        for (final x in b.buckets) {
          expect(x.start.month, x.end.month);
          expect(x.start.year, x.end.year);
        }
      });

      test('a granularity that does not suit the range falls back', () {
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.currentMonth,
          kind: TransactionKind.expense,
          granularity: TransactionGranularity.monthly,
        );
        expect(b.granularity, TransactionGranularity.weekly);
        final dflt = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
        );
        expect(dflt.granularity, TransactionGranularity.monthly);
        final weekly = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
          granularity: TransactionGranularity.weekly,
        );
        expect(weekly.granularity, TransactionGranularity.weekly);
        expect(weekly.buckets.length, greaterThan(dflt.buckets.length));
      });

      test('account and category filters apply to every number', () {
        final all = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
        );
        final category = all.categories.first.categoryId;
        final one = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
          categoryIds: {category},
        );
        expect(one.categories.map((c) => c.categoryId), [category]);
        expect(one.total, all.categories.first.amount);
        expect(
          _sum(one.buckets.map((b) => b.total)),
          closeTo(one.total, 0.001),
        );
        expect(
          one.previousTotal,
          oracle(
            one.previousRange,
            TransactionKind.expense,
            categories: {category},
          ),
        );

        final account = repo.accounts.first.id;
        final byAccount = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
          accountIds: {account},
        );
        expect(
          byAccount.total,
          oracle(byAccount.range, TransactionKind.expense, accounts: {account}),
        );
        final none = repo.transactionBreakdown(
          range: TransactionTimeRange.last6Months,
          kind: TransactionKind.expense,
          accountIds: {repo.accounts.last.id},
        );
        expect(
          none.total,
          oracle(
            none.range,
            TransactionKind.expense,
            accounts: {repo.accounts.last.id},
          ),
        );
      });

      test('nothing to show: empty, zero, no change, buckets still there', () {
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.currentMonth,
          kind: TransactionKind.expense,
          categoryIds: {'cat_salary'}, // an income category
        );
        expect(b.isEmpty, isTrue);
        expect(b.total, 0);
        expect(b.categories, isEmpty);
        expect(b.changeVsPrevious, isNull);
        expect(b.buckets, isNotEmpty);
        expect(b.buckets.every((x) => x.amounts.isEmpty), isTrue);
      });

      test('change vs previous: a fraction, or null without a previous', () {
        final b = repo.transactionBreakdown(
          range: TransactionTimeRange.last3Months,
          kind: TransactionKind.expense,
        );
        expect(b.previousTotal, greaterThan(0));
        expect(
          b.changeVsPrevious,
          closeTo((b.total - b.previousTotal) / b.previousTotal, 1e-9),
        );
        // A year back there is no history at all.
        final far = repo.transactionBreakdown(
          range: TransactionTimeRange.last12Months,
          kind: TransactionKind.expense,
        );
        expect(far.previousTotal, 0);
        expect(far.changeVsPrevious, isNull);
      });
    });
  }

  test('on the first of the month the current month is one single day', () {
    final repo = MockRepository(now: DateTime(2026, 10, 1, 10));
    final b = repo.transactionBreakdown(
      range: TransactionTimeRange.currentMonth,
      kind: TransactionKind.expense,
    );
    expect(b.range.days, 1);
    expect(b.buckets, hasLength(1));
  });
}
