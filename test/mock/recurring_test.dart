import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/date_utils.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/recurring_occurrence.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';
import 'package:sossoldi/mock/models/transaction.dart';

final _now = DateTime(2026, 10, 23, 12);

MockRepository _repo({DateTime? now}) => MockRepository(now: now ?? _now);

RecurringTransaction _custom(
  DateTime next, {
  RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
  int? anchorDay,
  RecurringStatus status = RecurringStatus.active,
}) => RecurringTransaction(
  id: 'rec_test',
  type: TransactionType.expense,
  amount: 50,
  currency: 'EUR',
  description: 'Test',
  frequency: frequency,
  nextDate: next,
  anchorDay: anchorDay,
  status: status,
  accountId: 'acc_checking',
  categoryId: 'cat_home',
);

MockRepository _only(RecurringTransaction r, {DateTime? now}) =>
    MockRepository(now: now ?? _now, recurring: (_) => [r]);

List<DateTime> _dates(MockRepository repo, int y, int m, {String? id}) => [
  for (final o in repo.recurringOccurrences(y, m))
    if (id == null || o.recurringId == id) o.date,
];

void main() {
  group('occurrences of a month', () {
    test('past ones are real transactions, the rest are planned', () {
      final repo = _repo();
      final all = repo.recurringOccurrences(2026, 10);
      expect(all, isNotEmpty);
      for (final o in all) {
        if (o.isPlanned) {
          expect(o.date.isAfter(repo.today), isTrue, reason: '$o');
        } else {
          expect(o.date.isAfter(repo.today), isFalse);
          final t = repo.transaction(o.transactionId!);
          expect(t.recurringId, o.recurringId);
          expect(dateOnly(t.date), o.date);
          expect(t.amount, o.amount);
        }
      }
      // Rent on the 1st already happened, salary on the 27th is planned.
      final rent = all.firstWhere((o) => o.recurringId == 'rec_rent');
      expect(rent.date, DateTime(2026, 10, 1));
      expect(rent.isPlanned, isFalse);
      final salary = all.firstWhere((o) => o.recurringId == 'rec_salary');
      expect(salary.date, DateTime(2026, 10, 27));
      expect(salary.isPlanned, isTrue);
    });

    test('sorted by date, all inside the month', () {
      final repo = _repo();
      for (var m = -8; m <= 14; m++) {
        final first = DateTime(2026, 10 + m);
        final list = repo.recurringOccurrences(first.year, first.month);
        for (var i = 0; i < list.length; i++) {
          expect(list[i].date.year, first.year);
          expect(list[i].date.month, first.month);
          expect(list[i].date.hour, 0);
          if (i > 0) {
            expect(list[i].date.isBefore(list[i - 1].date), isFalse);
          }
        }
      }
    });

    test('monthly ones appear once a month, in the past and the future', () {
      final repo = _repo();
      for (var m = -4; m <= 14; m++) {
        final first = DateTime(2026, 10 + m);
        final rent = repo
            .recurringOccurrences(first.year, first.month)
            .where((o) => o.recurringId == 'rec_rent');
        expect(rent.length, 1, reason: '$first');
        expect(rent.single.date.day, 1);
      }
    });

    test('weekly ones: one per Friday of the month', () {
      final repo = _repo();
      for (var m = -3; m <= 6; m++) {
        final first = DateTime(2026, 10 + m);
        final fridays = [
          for (var d = 1; d <= daysInMonth(first.year, first.month); d++)
            if (DateTime(first.year, first.month, d).weekday == DateTime.friday)
              DateTime(first.year, first.month, d),
        ];
        expect(
          _dates(repo, first.year, first.month, id: 'rec_cleaning'),
          fridays,
          reason: '$first',
        );
      }
    });

    test('bimonthly: every other month', () {
      final repo = _repo();
      final months = [
        for (var m = 0; m < 12; m++)
          if (_dates(repo, 2026, 10 + m, id: 'rec_utilities').isNotEmpty)
            DateTime(2026, 10 + m).month,
      ];
      expect(months.length, 6);
      for (var i = 1; i < months.length; i++) {
        expect((months[i] - months[i - 1]) % 12, 2);
      }
    });

    test('yearly: only one month a year has it', () {
      final repo = _repo();
      final hits = [
        for (var m = 0; m < 12; m++)
          if (_dates(repo, 2026, 11 + m, id: 'rec_car_insurance').isNotEmpty) m,
      ];
      expect(hits.length, 1);
      final next = repo.recurring('rec_car_insurance').nextDate;
      expect(_dates(repo, next.year, next.month, id: 'rec_car_insurance'), [
        next,
      ]);
      // The year after, the same day.
      expect(_dates(repo, next.year + 1, next.month, id: 'rec_car_insurance'), [
        addMonths(next, 12),
      ]);
    });

    test('quarterly and semiannual fall only in some months', () {
      for (final (freq, every) in [
        (RecurrenceFrequency.quarterly, 3),
        (RecurrenceFrequency.semiannual, 6),
      ]) {
        final repo = _only(_custom(DateTime(2026, 12, 15), frequency: freq));
        final months = [
          for (var m = 0; m < 24; m++)
            if (_dates(repo, 2026, 11 + m).isNotEmpty) m,
        ];
        expect(months.first, 1, reason: 'December is month index 1');
        for (var i = 1; i < months.length; i++) {
          expect(months[i] - months[i - 1], every);
        }
        expect(_dates(repo, 2027, 1), isEmpty);
        expect(_dates(repo, 2027, 2), isEmpty);
      }
    });

    test('biweekly: every 14 days', () {
      final repo = _only(
        _custom(
          DateTime(2026, 10, 30),
          frequency: RecurrenceFrequency.biweekly,
        ),
      );
      expect(_dates(repo, 2026, 11), [
        DateTime(2026, 11, 13),
        DateTime(2026, 11, 27),
      ]);
      // The ones before today are real transactions, every 14 days.
      expect(_dates(repo, 2026, 10), [
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 16),
        DateTime(2026, 10, 30),
      ]);
    });

    test('on the 31st: the last day of shorter months, 31st otherwise', () {
      final repo = _only(_custom(DateTime(2026, 10, 31)));
      expect(_dates(repo, 2026, 10), [DateTime(2026, 10, 31)]);
      expect(_dates(repo, 2026, 11), [DateTime(2026, 11, 30)]);
      expect(_dates(repo, 2026, 12), [DateTime(2026, 12, 31)]);
      expect(_dates(repo, 2027, 2), [DateTime(2027, 2, 28)]);
      expect(_dates(repo, 2027, 3), [DateTime(2027, 3, 31)]);
      expect(_dates(repo, 2027, 4), [DateTime(2027, 4, 30)]);
      expect(_dates(repo, 2028, 2), [DateTime(2028, 2, 29)], reason: 'leap');
    });

    test('a next date already clamped keeps its anchor day', () {
      // Next date Nov 30 but the recurrence is "the 31st".
      final repo = _only(_custom(DateTime(2026, 11, 30), anchorDay: 31));
      expect(_dates(repo, 2026, 12), [DateTime(2026, 12, 31)]);
      expect(_dates(repo, 2027, 1), [DateTime(2027, 1, 31)]);
      expect(_dates(repo, 2027, 2), [DateTime(2027, 2, 28)]);
    });

    test('around a daylight saving change the dates stay midnight days', () {
      for (final now in [
        DateTime(2026, 3, 20, 12),
        DateTime(2026, 10, 20, 12),
        DateTime(2026, 11, 2, 12),
      ]) {
        final repo = _repo(now: now);
        for (var m = -2; m <= 3; m++) {
          final first = DateTime(now.year, now.month + m);
          for (final o in repo.recurringOccurrences(first.year, first.month)) {
            expect(o.date.hour, 0, reason: '${o.date}');
            expect(o.date.month, first.month);
          }
        }
        final fridays = _dates(
          repo,
          now.year,
          now.month + 1,
          id: 'rec_cleaning',
        );
        for (final d in fridays) {
          expect(d.weekday, DateTime.friday);
        }
      }
    });

    test('a month far away still works, and a month with nothing is empty', () {
      final repo = _only(
        _custom(DateTime(2026, 12, 15), frequency: RecurrenceFrequency.yearly),
      );
      expect(_dates(repo, 2031, 12), [DateTime(2031, 12, 15)]);
      expect(repo.recurringOccurrences(2027, 3), isEmpty);
      expect(repo.recurringDayTypes(2027, 3), isEmpty);
    });
  });

  group('paused', () {
    test('has no planned dates, only the ones that happened', () {
      final repo = _repo();
      expect(repo.recurring('rec_disney').status, RecurringStatus.paused);
      for (var m = 0; m <= 12; m++) {
        final first = DateTime(2026, 10 + m);
        expect(
          _dates(repo, first.year, first.month, id: 'rec_disney'),
          isEmpty,
        );
      }
      // Paused two months ago: it is still in the older months.
      expect(_dates(repo, 2026, 7, id: 'rec_disney'), isNotEmpty);
    });
  });

  group('day types (the calendar dots)', () {
    test('one set of types per day', () {
      final repo = _repo();
      final types = repo.recurringDayTypes(2026, 10);
      expect(types[27], {TransactionType.income});
      expect(types[28], {TransactionType.transfer});
      expect(types[1], contains(TransactionType.expense));
      // Rent (expense) and the investment... on the 2nd, not the 1st.
      expect(types[2], {TransactionType.transfer, TransactionType.expense});
    });

    test('more types on the same day give more dots', () {
      final repo = _repo();
      final types = repo.recurringDayTypes(2026, 11);
      expect(types.values.any((s) => s.length >= 2), isTrue);
      // Every key is a real day of the month.
      for (final d in types.keys) {
        expect(d, inInclusiveRange(1, 30));
      }
    });
  });

  group('editing', () {
    test('pausing removes the future dates and keeps the past ones', () {
      final repo = _repo();
      var notified = 0;
      repo.addListener(() => notified++);
      final before = _dates(repo, 2026, 10, id: 'rec_spotify');
      expect(before, [DateTime(2026, 10, 20)]); // already happened
      expect(_dates(repo, 2026, 11, id: 'rec_spotify'), isNotEmpty);
      repo.updateRecurring('rec_spotify', status: RecurringStatus.paused);
      expect(notified, 1);
      expect(_dates(repo, 2026, 11, id: 'rec_spotify'), isEmpty);
      expect(_dates(repo, 2026, 10, id: 'rec_spotify'), before);
      // Back on: the dates come back.
      repo.updateRecurring('rec_spotify', status: RecurringStatus.active);
      expect(_dates(repo, 2026, 11, id: 'rec_spotify'), [
        DateTime(2026, 11, 20),
      ]);
    });

    test('a new amount counts only for the planned dates', () {
      final repo = _repo();
      final past = repo
          .recurringOccurrences(2026, 10)
          .firstWhere((o) => o.recurringId == 'rec_rent');
      final txAmount = repo.transaction(past.transactionId!).amount;
      repo.updateRecurring('rec_rent', amount: 900);
      final after = repo.recurringOccurrences(2026, 10);
      final rentPast = after.firstWhere((o) => o.recurringId == 'rec_rent');
      expect(rentPast.amount, txAmount);
      expect(repo.transaction(past.transactionId!).amount, txAmount);
      final rentNext = repo
          .recurringOccurrences(2026, 11)
          .firstWhere((o) => o.recurringId == 'rec_rent');
      expect(rentNext.amount, 900);
      expect(rentNext.isPlanned, isTrue);
    });

    test('invalid amounts are rejected and change nothing', () {
      final repo = _repo();
      for (final bad in [0.0, -5.0, double.nan, double.infinity]) {
        expect(
          () => repo.updateRecurring('rec_rent', amount: bad),
          throwsArgumentError,
        );
      }
      expect(repo.recurring('rec_rent').amount, 850);
    });

    test('a new frequency starts from the next date', () {
      final repo = _repo();
      final next = repo.recurring('rec_gym').nextDate; // Nov 5
      repo.updateRecurring('rec_gym', frequency: RecurrenceFrequency.yearly);
      expect(repo.recurring('rec_gym').nextDate, next);
      expect(_dates(repo, next.year, next.month, id: 'rec_gym'), [next]);
      expect(_dates(repo, next.year, next.month + 1, id: 'rec_gym'), isEmpty);
      expect(_dates(repo, next.year + 1, next.month, id: 'rec_gym'), [
        DateTime(next.year + 1, next.month, next.day),
      ]);
    });

    test('resuming a recurrence whose next date passed moves it forward', () {
      final repo = _only(_custom(DateTime(2026, 10, 24)));
      repo.updateRecurring('rec_test', status: RecurringStatus.paused);
      final later = MockRepository(
        now: DateTime(2026, 10, 23, 12),
        recurring: (_) => [_custom(DateTime(2026, 10, 24))],
      );
      later.updateRecurring('rec_test', frequency: RecurrenceFrequency.weekly);
      expect(later.recurring('rec_test').nextDate.isAfter(later.today), isTrue);
    });

    test('everything keeps next dates after today', () {
      final repo = _repo();
      for (final r in repo.recurringTransactions()) {
        repo.updateRecurring(r.id, frequency: RecurrenceFrequency.weekly);
        repo.updateRecurring(r.id, status: RecurringStatus.active);
      }
      for (final r in repo.recurringTransactions()) {
        expect(r.nextDate.isAfter(repo.today), isTrue, reason: r.id);
      }
    });
  });

  group('deleting', () {
    test('removes the dates but keeps the transactions, unlinked', () {
      final repo = _repo();
      final count = repo.transactions.length;
      final linked = repo.transactions
          .where((t) => t.recurringId == 'rec_netflix')
          .map((t) => t.id)
          .toList();
      expect(linked, isNotEmpty);
      var notified = 0;
      repo.addListener(() => notified++);
      repo.deleteRecurring('rec_netflix');
      expect(notified, 1);
      expect(repo.transactions.length, count);
      for (final id in linked) {
        expect(repo.transaction(id).recurringId, isNull);
      }
      for (var m = -4; m <= 6; m++) {
        final first = DateTime(2026, 10 + m);
        expect(
          _dates(repo, first.year, first.month, id: 'rec_netflix'),
          isEmpty,
        );
      }
      expect(
        repo.recurringTransactions().where((r) => r.id == 'rec_netflix'),
        isEmpty,
      );
    });
  });

  group('history', () {
    test('grouped by year, newest first, with the total of the year', () {
      final repo = _repo(now: DateTime(2027, 2, 10, 12));
      final groups = repo.recurringHistory(
        'rec_rent',
        range: RecurringHistoryRange.last12Months,
      );
      expect(groups.map((g) => g.year), [2027, 2026]);
      for (final g in groups) {
        final dates = g.transactions.map((t) => t.date).toList();
        for (var i = 1; i < dates.length; i++) {
          expect(dates[i].isAfter(dates[i - 1]), isFalse);
        }
        expect(g.transactions.every((t) => t.date.year == g.year), isTrue);
        // Rent is an expense: the total is negative.
        expect(
          g.total,
          closeTo(-g.transactions.fold(0.0, (s, t) => s + t.amount), 0.001),
        );
      }
    });

    test('the range limits how far back it goes', () {
      final repo = _repo();
      int count(RecurringHistoryRange r) => repo
          .recurringHistory('rec_rent', range: r)
          .fold(0, (s, g) => s + g.transactions.length);
      final c3 = count(RecurringHistoryRange.last3Months);
      final c6 = count(RecurringHistoryRange.last6Months);
      final c12 = count(RecurringHistoryRange.last12Months);
      final all = count(RecurringHistoryRange.all);
      expect(c3, 3, reason: 'Oct, Sep, Aug');
      expect(c6, 6);
      expect(c3 <= c6 && c6 <= c12 && c12 <= all, isTrue);
      expect(
        all,
        repo.transactions.where((t) => t.recurringId == 'rec_rent').length,
      );
    });

    test('income is positive and a transfer is positive', () {
      final repo = _repo();
      expect(repo.recurringHistory('rec_salary').first.total, greaterThan(0));
      expect(repo.recurringHistory('rec_savings').first.total, greaterThan(0));
    });

    test('nothing for an unknown or a new recurrence', () {
      expect(_repo().recurringHistory('nope'), isEmpty);
    });
  });
}
