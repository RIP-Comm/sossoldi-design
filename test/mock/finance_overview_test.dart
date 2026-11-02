import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/budget_status.dart';
import 'package:sossoldi/mock/models/finance_overview.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';
import 'package:sossoldi/mock/models/transaction.dart';

int _n = 0;

Transaction _tx(
  DateTime date,
  double amount, {
  TransactionType type = TransactionType.expense,
  String category = 'cat_groceries',
  String account = checkingAccountId,
  String? toAccount,
}) => Transaction(
  id: 'tx_test_${_n++}',
  type: type,
  amount: amount,
  currency: 'EUR',
  date: date,
  description: 'test',
  accountId: account,
  toAccountId: toAccount,
  categoryId: type == TransactionType.transfer ? null : category,
);

Budget _budget(
  String category,
  double amount,
  BudgetPeriod period, {
  String id = '',
}) => Budget(
  id: id.isEmpty ? 'bud_${category}_${period.name}' : id,
  categoryId: category,
  amount: amount,
  currency: 'EUR',
  period: period,
);

RecurringTransaction _recurring(
  String id,
  double amount,
  DateTime next, {
  TransactionType type = TransactionType.expense,
  RecurringStatus status = RecurringStatus.active,
  RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
}) => RecurringTransaction(
  id: id,
  type: type,
  amount: amount,
  currency: 'EUR',
  description: 'Rec $id',
  frequency: frequency,
  nextDate: next,
  status: status,
  accountId: checkingAccountId,
  toAccountId: type == TransactionType.transfer ? savingsAccountId : null,
  categoryId: type == TransactionType.transfer ? null : 'cat_home',
);

/// A repository with only the given transactions, budgets and recurrences.
MockRepository _repo(
  DateTime now, {
  List<Transaction> transactions = const [],
  List<Budget> budgets = const [],
  List<RecurringTransaction> recurring = const [],
  List<Account>? accounts,
}) => MockRepository(
  now: now,
  transactions: (_, _) => transactions,
  budgets: (_, _) => budgets,
  recurring: (_) => recurring,
  accounts: accounts,
);

/// A transaction of a recurring one, dated today (the 15th).
Transaction _recTx(String recurringId) => Transaction(
  id: 'tx_rec_$recurringId',
  type: TransactionType.expense,
  amount: 12,
  currency: 'EUR',
  date: DateTime(2026, 10, 15),
  description: 'Rec $recurringId',
  accountId: checkingAccountId,
  categoryId: 'cat_home',
  recurringId: recurringId,
);

final _oct15 = DateTime(2026, 10, 15, 12);

/// Three previous months, 300 € of expenses on day 5 of each.
List<Transaction> _history() => [
  for (final m in [7, 8, 9]) _tx(DateTime(2026, m, 5), 300),
];

void main() {
  group('rule a: exceeded budgets', () {
    test('one error message per budget over its limit, biggest first', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 10, 3), 150, category: 'cat_home'),
          _tx(DateTime(2026, 10, 4), 260, category: 'cat_leisure'),
          _tx(DateTime(2026, 10, 5), 50, category: 'cat_transport'),
        ],
        budgets: [
          _budget('cat_home', 100, BudgetPeriod.monthly),
          _budget('cat_leisure', 200, BudgetPeriod.monthly),
          _budget('cat_transport', 50, BudgetPeriod.monthly), // = limit
        ],
      );
      final m = repo.digestExceededBudgets();
      expect(m.map((e) => e.categoryId), ['cat_leisure', 'cat_home']);
      expect(m.map((e) => e.amount), [60, 50]);
      expect(m.every((e) => e.tone == DigestTone.error), isTrue);
      expect(m.every((e) => e.rule == DigestRule.budgetExceeded), isTrue);
    });

    test('a budget is judged in its own current period', () {
      // The weekly one is exceeded only by this week's spending.
      final repo = _repo(
        _oct15, // Thursday: the week started on Monday the 12th
        transactions: [
          _tx(DateTime(2026, 10, 8), 500, category: 'cat_home'), // last week
          _tx(DateTime(2026, 10, 13), 90, category: 'cat_leisure'),
        ],
        budgets: [
          _budget('cat_home', 100, BudgetPeriod.weekly),
          _budget('cat_leisure', 80, BudgetPeriod.weekly),
        ],
      );
      expect(repo.digestExceededBudgets().map((e) => e.categoryId), [
        'cat_leisure',
      ]);
    });

    test('nothing when no budget is exceeded', () {
      final repo = _repo(
        _oct15,
        transactions: [_tx(DateTime(2026, 10, 3), 50, category: 'cat_home')],
        budgets: [_budget('cat_home', 100, BudgetPeriod.monthly)],
      );
      expect(repo.digestExceededBudgets(), isEmpty);
    });
  });

  group('rule b: budgets at risk', () {
    MockRepository at(DateTime now, double spent, BudgetPeriod period) => _repo(
      now,
      transactions: [
        _tx(
          DateTime(now.year, now.month, now.day),
          spent,
          category: 'cat_home',
        ),
      ],
      budgets: [_budget('cat_home', 100, period)],
    );

    test('from 80% to the limit, with the days left', () {
      final m = at(_oct15, 85, BudgetPeriod.monthly).digestBudgetsAtRisk();
      expect(m, hasLength(1));
      expect(m.single.categoryId, 'cat_home');
      expect(m.single.percent, closeTo(0.85, 1e-9));
      expect(m.single.days, 17); // until Nov 1
      expect(m.single.tone, DigestTone.warning);
    });

    test('80% counts, 79% does not, 100% counts, over 100% is rule a', () {
      expect(
        at(_oct15, 80, BudgetPeriod.monthly).digestBudgetsAtRisk(),
        hasLength(1),
      );
      expect(
        at(_oct15, 79, BudgetPeriod.monthly).digestBudgetsAtRisk(),
        isEmpty,
      );
      expect(
        at(_oct15, 100, BudgetPeriod.monthly).digestBudgetsAtRisk(),
        hasLength(1),
      );
      expect(
        at(_oct15, 101, BudgetPeriod.monthly).digestBudgetsAtRisk(),
        isEmpty,
      );
    });

    test('more than 3 days left: 4 yes, 3 no', () {
      // October ends on the 31st: on the 28th there are 4 days to Nov 1.
      expect(
        at(
          DateTime(2026, 10, 28, 12),
          90,
          BudgetPeriod.monthly,
        ).digestBudgetsAtRisk(),
        hasLength(1),
      );
      expect(
        at(
          DateTime(2026, 10, 29, 12),
          90,
          BudgetPeriod.monthly,
        ).digestBudgetsAtRisk(),
        isEmpty,
      );
    });

    test('works for weekly budgets: Monday has 7 days left, Friday 3', () {
      expect(
        at(
          DateTime(2026, 10, 12, 12),
          90,
          BudgetPeriod.weekly,
        ).digestBudgetsAtRisk().single.days,
        7,
      );
      expect(
        at(
          DateTime(2026, 10, 23, 12),
          90,
          BudgetPeriod.weekly,
        ).digestBudgetsAtRisk(),
        isEmpty,
      );
    });

    test('most used first', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 10, 3), 82, category: 'cat_home'),
          _tx(DateTime(2026, 10, 4), 95, category: 'cat_leisure'),
        ],
        budgets: [
          _budget('cat_home', 100, BudgetPeriod.monthly),
          _budget('cat_leisure', 100, BudgetPeriod.monthly),
        ],
      );
      expect(repo.digestBudgetsAtRisk().map((e) => e.categoryId), [
        'cat_leisure',
        'cat_home',
      ]);
    });
  });

  group('rule c: spending against the average', () {
    MockRepository withSpent(double spent, {DateTime? now}) => _repo(
      now ?? _oct15,
      transactions: [..._history(), _tx(DateTime(2026, 10, 5), spent)],
    );

    test('at least 10% under the average: success, with the difference', () {
      final m = withSpent(270).digestSpendingVsAverage()!;
      expect(m.rule, DigestRule.spendingVsAverage);
      expect(m.tone, DigestTone.success);
      expect(m.isBelow, isTrue);
      expect(m.amount, 30);
    });

    test('at least 10% over: warning', () {
      final m = withSpent(330).digestSpendingVsAverage()!;
      expect(m.tone, DigestTone.warning);
      expect(m.isBelow, isFalse);
      expect(m.amount, 30);
    });

    test('inside the 10% band: nothing', () {
      expect(withSpent(271).digestSpendingVsAverage(), isNull);
      expect(withSpent(300).digestSpendingVsAverage(), isNull);
      expect(withSpent(329).digestSpendingVsAverage(), isNull);
    });

    test('compares the same days: later spending of past months is out', () {
      final repo = _repo(
        _oct15,
        transactions: [
          ..._history(),
          // After the 15th of each month: not part of the comparison.
          for (final m in [7, 8, 9]) _tx(DateTime(2026, m, 20), 1000),
          _tx(DateTime(2026, 10, 5), 270),
        ],
      );
      expect(repo.digestSpendingVsAverage()!.amount, 30);
    });

    test('not in the first 3 days of the month, yes from the 4th', () {
      final data = [..._history(), _tx(DateTime(2026, 10, 1), 100)];
      for (final d in [1, 2, 3]) {
        expect(
          _repo(
            DateTime(2026, 10, d, 12),
            transactions: data,
          ).digestSpendingVsAverage(),
          isNull,
          reason: 'day $d',
        );
      }
      // On the 4th the past months count only up to the 4th: day 5 is out.
      final repo = _repo(
        DateTime(2026, 10, 4, 12),
        transactions: [
          for (final m in [7, 8, 9]) _tx(DateTime(2026, m, 2), 300),
          _tx(DateTime(2026, 10, 2), 100),
        ],
      );
      expect(repo.digestSpendingVsAverage()!.tone, DigestTone.success);
    });

    test('a month shorter than today still works (Feb has 28 days)', () {
      final repo = _repo(
        DateTime(2026, 3, 30, 12),
        transactions: [
          _tx(DateTime(2026, 2, 28), 300), // last day of February
          _tx(DateTime(2026, 1, 28), 300),
          _tx(DateTime(2025, 12, 28), 300),
          _tx(DateTime(2026, 3, 10), 500),
        ],
      );
      expect(repo.digestSpendingVsAverage()!.tone, DigestTone.warning);
    });

    test('nothing to compare with: nothing', () {
      expect(
        _repo(
          _oct15,
          transactions: [_tx(DateTime(2026, 10, 5), 50)],
        ).digestSpendingVsAverage(),
        isNull,
      );
    });

    test('transfers and income are not spending', () {
      final repo = _repo(
        _oct15,
        transactions: [
          ..._history(),
          _tx(DateTime(2026, 10, 5), 270),
          _tx(
            DateTime(2026, 10, 6),
            900,
            type: TransactionType.transfer,
            toAccount: savingsAccountId,
          ),
          _tx(DateTime(2026, 10, 7), 900, type: TransactionType.income),
        ],
      );
      expect(repo.digestSpendingVsAverage()!.amount, 30);
    });
  });

  group('rule d: large recurrences', () {
    MockRepository with_(List<RecurringTransaction> r, {DateTime? now}) =>
        _repo(now ?? _oct15, recurring: r);

    test('above the threshold in the next 7 days: one info message', () {
      final m = with_([_recurring('a', 150, DateTime(2026, 10, 18))])
          .digestLargeRecurrences()!;
      expect(m.rule, DigestRule.largeRecurrences);
      expect(m.tone, DigestTone.info);
      expect(m.count, 1);
      expect(m.amount, 150);
      expect(m.description, 'Rec a');
      expect(m.days, 7);
    });

    test('the threshold itself does not count, a cent above does', () {
      expect(
        with_([_recurring('a', 100, DateTime(2026, 10, 18))])
            .digestLargeRecurrences(),
        isNull,
      );
      expect(
        with_([_recurring('a', 100.01, DateTime(2026, 10, 18))])
            .digestLargeRecurrences(),
        isNotNull,
      );
    });

    test('the window: the 22nd is in, the 23rd is out; tomorrow is in', () {
      expect(
        with_([_recurring('a', 200, DateTime(2026, 10, 22))])
            .digestLargeRecurrences(),
        isNotNull,
      );
      expect(
        with_([_recurring('a', 200, DateTime(2026, 10, 23))])
            .digestLargeRecurrences(),
        isNull,
      );
      expect(
        with_([_recurring('a', 200, DateTime(2026, 10, 16))])
            .digestLargeRecurrences(),
        isNotNull,
      );
    });

    test('several are grouped with their total and no single name', () {
      final m = with_([
        _recurring('a', 150, DateTime(2026, 10, 17)),
        _recurring('b', 250, DateTime(2026, 10, 20)),
        _recurring('c', 40, DateTime(2026, 10, 19)), // under the threshold
      ]).digestLargeRecurrences()!;
      expect(m.count, 2);
      expect(m.amount, 400);
      expect(m.description, isNull);
    });

    test('only expenses, only active ones', () {
      expect(
        with_([
          _recurring(
            'i',
            2000,
            DateTime(2026, 10, 17),
            type: TransactionType.income,
          ),
          _recurring(
            't',
            500,
            DateTime(2026, 10, 17),
            type: TransactionType.transfer,
          ),
          _recurring(
            'p',
            500,
            DateTime(2026, 10, 17),
            status: RecurringStatus.paused,
          ),
        ]).digestLargeRecurrences(),
        isNull,
      );
    });

    test('the window can cross the end of the month', () {
      final m = with_([
        _recurring('a', 850, DateTime(2026, 11, 3)),
      ], now: DateTime(2026, 10, 28, 12)).digestLargeRecurrences()!;
      expect(m.count, 1);
      expect(m.amount, 850);
    });

    test('a recurrence that already happened today is not upcoming', () {
      // Its date is today: it has a real transaction, not a planned date.
      final repo = _repo(
        _oct15,
        recurring: [_recurring('a', 300, DateTime(2026, 10, 15))],
      );
      expect(repo.digestLargeRecurrences(), isNull);
    });
  });

  group('rule e: a category that grew', () {
    test('more than 50% above the same days last month: warning', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 5), 100),
          _tx(DateTime(2026, 10, 5), 151),
        ],
      );
      final m = repo.digestCategoryGrowth()!;
      expect(m.rule, DigestRule.categoryGrowth);
      expect(m.tone, DigestTone.warning);
      expect(m.categoryId, 'cat_groceries');
      expect(m.percent, closeTo(0.51, 1e-9));
      expect(m.amount, 51);
    });

    test('exactly 50% is not enough', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 5), 100),
          _tx(DateTime(2026, 10, 5), 150),
        ],
      );
      expect(repo.digestCategoryGrowth(), isNull);
    });

    test('compares the same days: last month after the 15th is out', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 5), 100),
          _tx(DateTime(2026, 9, 25), 900),
          _tx(DateTime(2026, 10, 5), 160),
        ],
      );
      expect(repo.digestCategoryGrowth(), isNotNull);
    });

    test('a small spending is ignored (minimum 30), 30 counts', () {
      MockRepository small(double now) => _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 5), 10),
          _tx(DateTime(2026, 10, 5), now),
        ],
      );
      expect(small(29).digestCategoryGrowth(), isNull);
      expect(small(30).digestCategoryGrowth(), isNotNull);
    });

    test('nothing last month: no growth to speak of', () {
      final repo = _repo(
        _oct15,
        transactions: [_tx(DateTime(2026, 10, 5), 500)],
      );
      expect(repo.digestCategoryGrowth(), isNull);
    });

    test('the biggest increase wins', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 5), 100, category: 'cat_home'),
          _tx(DateTime(2026, 10, 5), 200, category: 'cat_home'),
          _tx(DateTime(2026, 9, 6), 50, category: 'cat_leisure'),
          _tx(DateTime(2026, 10, 6), 400, category: 'cat_leisure'),
        ],
      );
      expect(repo.digestCategoryGrowth()!.categoryId, 'cat_leisure');
    });

    test('not in the first 3 days', () {
      final repo = _repo(
        DateTime(2026, 10, 3, 12),
        transactions: [
          _tx(DateTime(2026, 9, 1), 100),
          _tx(DateTime(2026, 10, 1), 400),
        ],
      );
      expect(repo.digestCategoryGrowth(), isNull);
    });
  });

  group('the whole digest', () {
    test('nothing applies: one neutral message', () {
      final d = _repo(_oct15).financeDigest();
      expect(d, hasLength(1));
      expect(d.single.rule, DigestRule.allGood);
      expect(d.single.tone, DigestTone.info);
    });

    test('at most 3, by priority: a, then b, then c, d, e', () {
      final repo = _repo(
        _oct15,
        transactions: [
          ..._history(),
          _tx(DateTime(2026, 10, 5), 150, category: 'cat_home'),
          _tx(DateTime(2026, 10, 6), 90, category: 'cat_leisure'),
        ],
        budgets: [
          _budget('cat_home', 100, BudgetPeriod.monthly),
          _budget('cat_leisure', 100, BudgetPeriod.monthly),
        ],
        recurring: [_recurring('a', 300, DateTime(2026, 10, 18))],
      );
      final d = repo.financeDigest();
      expect(d.map((e) => e.rule), [
        DigestRule.budgetExceeded,
        DigestRule.budgetAtRisk,
        DigestRule.spendingVsAverage,
      ]);
    });

    test('four exceeded budgets: only three messages', () {
      final repo = _repo(
        _oct15,
        transactions: [
          for (final c in [
            'cat_home',
            'cat_leisure',
            'cat_health',
            'cat_shopping',
          ])
            _tx(DateTime(2026, 10, 3), 200, category: c),
        ],
        budgets: [
          for (final c in [
            'cat_home',
            'cat_leisure',
            'cat_health',
            'cat_shopping',
          ])
            _budget(c, 100, BudgetPeriod.monthly),
        ],
      );
      final d = repo.financeDigest();
      expect(d, hasLength(3));
      expect(d.every((e) => e.rule == DigestRule.budgetExceeded), isTrue);
    });

    test('first day of the month: no comparison messages', () {
      final repo = _repo(
        DateTime(2026, 10, 1, 12),
        transactions: [..._history(), _tx(DateTime(2026, 10, 1), 10)],
      );
      expect(repo.financeDigest().single.rule, DigestRule.allGood);
    });

    test('the generated data gives a valid digest every day', () {
      for (var d = 0; d < 40; d++) {
        final repo = MockRepository(now: DateTime(2026, 9, 20 + d, 12));
        final digest = repo.financeDigest();
        expect(digest, isNotEmpty);
        expect(digest.length, lessThanOrEqualTo(3));
      }
    });
  });

  group('accounts with change', () {
    List<Account> usd() => [
      Account(
        id: checkingAccountId,
        name: 'Dollar account',
        bankName: 'Test',
        type: AccountType.checking,
        initialBalance: 1000,
        currency: 'USD',
        color: CategoryColors.all[0],
        icon: PhosphorIconsRegular.bank,
      ),
    ];

    test('balance today minus the balance at the start of the month', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 9, 20), 200, type: TransactionType.income),
          _tx(DateTime(2026, 10, 1), 50), // the 1st counts in the change
          _tx(DateTime(2026, 10, 10), 30, type: TransactionType.income),
        ],
      );
      final a = repo.accountsWithChange().firstWhere(
        (e) => e.account.id == checkingAccountId,
      );
      expect(a.balance, repo.accountBalance(checkingAccountId));
      expect(a.change, -20);
      expect(
        a.balance - a.change,
        closeTo(
          repo.accountBalanceAt(checkingAccountId, DateTime(2026, 10)),
          0.001,
        ),
      );
    });

    test('transfers move the change of both accounts', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(
            DateTime(2026, 10, 3),
            400,
            type: TransactionType.transfer,
            toAccount: savingsAccountId,
          ),
        ],
      );
      final list = repo.accountsWithChange();
      expect(
        list.firstWhere((e) => e.account.id == checkingAccountId).change,
        -400,
      );
      expect(
        list.firstWhere((e) => e.account.id == savingsAccountId).change,
        400,
      );
      expect(list.firstWhere((e) => e.account.id == brokerAccountId).change, 0);
    });

    test('a dollar account: balance and change in its own currency', () {
      final repo = _repo(
        _oct15,
        accounts: usd(),
        transactions: [_tx(DateTime(2026, 10, 3), 40)],
      );
      final a = repo.accountsWithChange().single;
      expect(a.account.currency, 'USD');
      expect(a.balance, 960);
      expect(a.change, -40);
    });

    test('first day: the change is that day alone', () {
      final repo = _repo(
        DateTime(2026, 10, 1, 12),
        transactions: [
          _tx(DateTime(2026, 9, 30), 100),
          _tx(DateTime(2026, 10, 1), 25),
        ],
      );
      expect(
        repo
            .accountsWithChange()
            .firstWhere((e) => e.account.id == checkingAccountId)
            .change,
        -25,
      );
    });

    test('with the generated data the changes add up', () {
      final repo = MockRepository(now: _oct15);
      for (final e in repo.accountsWithChange()) {
        expect(
          e.balance - e.change,
          closeTo(
            repo.accountBalanceAt(e.account.id, DateTime(2026, 10)),
            0.001,
          ),
        );
      }
    });
  });

  group('upcoming recurrences', () {
    test('the planned ones of this month, soonest first, at most 5', () {
      final repo = MockRepository(now: DateTime(2026, 10, 3, 12));
      final list = repo.upcomingRecurrencesThisMonth();
      expect(list.length, lessThanOrEqualTo(5));
      expect(list.every((o) => o.isPlanned), isTrue);
      expect(list.every((o) => o.date.month == 10 && o.date.day > 3), isTrue);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].date.isBefore(list[i - 1].date), isFalse);
      }
      // The same dates as the Recurring tab.
      final tab = repo.recurringOccurrences(2026, 10).where((o) => o.isPlanned);
      expect(list.map((o) => o.date), tab.take(5).map((o) => o.date));
      expect(repo.upcomingRecurrencesThisMonth(limit: 100).length, tab.length);
    });

    test('none on the last day of the month', () {
      final repo = MockRepository(now: DateTime(2026, 10, 31, 12));
      expect(repo.upcomingRecurrencesThisMonth(), isEmpty);
    });

    test('a paused one is not there', () {
      final repo = _repo(
        _oct15,
        recurring: [
          _recurring(
            'p',
            50,
            DateTime(2026, 10, 20),
            status: RecurringStatus.paused,
          ),
        ],
      );
      expect(repo.upcomingRecurrencesThisMonth(), isEmpty);
    });
  });

  group('upcomingRecurrences (Dashboard widget)', () {
    test('the Overview reads the same as before: end of month, no today', () {
      final repo = _repo(
        _oct15,
        recurring: [
          _recurring('a', 10, DateTime(2026, 10, 20)),
          _recurring('b', 20, DateTime(2026, 11, 3)),
        ],
      );
      expect(repo.upcomingRecurrencesThisMonth().map((o) => o.recurringId), [
        'a',
      ]);
    });

    test('active only, soonest first, across months, limited', () {
      final repo = _repo(
        _oct15,
        recurring: [
          _recurring('late', 10, DateTime(2026, 11, 3)),
          _recurring('soon', 20, DateTime(2026, 10, 18)),
          _recurring(
            'paused',
            30,
            DateTime(2026, 10, 16),
            status: RecurringStatus.paused,
          ),
          _recurring(
            'transfer',
            40,
            DateTime(2026, 10, 25),
            type: TransactionType.transfer,
          ),
        ],
      );
      final all = repo.upcomingRecurrences(limit: 10, includeToday: true);
      expect(all.map((o) => o.recurringId).take(3), [
        'soon',
        'transfer',
        'late',
      ]);
      expect(all.any((o) => o.recurringId == 'paused'), isFalse);
      expect(all.first.type, TransactionType.expense);
      expect(all[1].type, TransactionType.transfer);
      for (var i = 1; i < all.length; i++) {
        expect(all[i].date.isBefore(all[i - 1].date), isFalse);
      }
      expect(repo.upcomingRecurrences(limit: 2).length, 2);
      // Same dates and amounts as the Recurring tab.
      final tab = repo.recurringOccurrences(2026, 10).where((o) => o.isPlanned);
      expect(
        all.where((o) => o.date.month == 10).map((o) => (o.date, o.amount)),
        tab.map((o) => (o.date, o.amount)),
      );
    });

    test('until cuts the horizon', () {
      final repo = _repo(
        _oct15,
        recurring: [_recurring('late', 10, DateTime(2026, 11, 3))],
      );
      expect(repo.upcomingRecurrences(until: DateTime(2026, 10, 31)), isEmpty);
      expect(
        repo.upcomingRecurrences(until: DateTime(2026, 11, 3)),
        hasLength(1),
      );
    });

    test('an occurrence of today counts only with includeToday', () {
      final repo = _repo(
        _oct15,
        transactions: [_recTx('today')],
        recurring: [_recurring('today', 12, DateTime(2026, 11, 15))],
      );
      expect(
        repo.upcomingRecurrences(includeToday: true).first.date,
        DateTime(2026, 10, 15),
      );
      expect(
        repo.upcomingRecurrences().every(
          (o) => o.date.isAfter(DateTime(2026, 10, 15)),
        ),
        isTrue,
      );
    });

    test('a paused recurrence with a transaction today is left out', () {
      final repo = _repo(
        _oct15,
        transactions: [_recTx('p')],
        recurring: [
          _recurring(
            'p',
            12,
            DateTime(2026, 11, 15),
            status: RecurringStatus.paused,
          ),
        ],
      );
      expect(repo.upcomingRecurrences(includeToday: true), isEmpty);
    });

    test('none when there are no recurring transactions', () {
      expect(_repo(_oct15).upcomingRecurrences(includeToday: true), isEmpty);
    });
  });

  group('cash flow', () {
    test('cumulative income, expenses and balance up to today', () {
      final repo = _repo(
        DateTime(2026, 10, 4, 12),
        transactions: [
          _tx(DateTime(2026, 9, 30), 999), // last month: out
          _tx(DateTime(2026, 10, 1), 10),
          _tx(DateTime(2026, 10, 2), 1000, type: TransactionType.income),
          _tx(DateTime(2026, 10, 2), 30),
          _tx(
            DateTime(2026, 10, 3),
            500,
            type: TransactionType.transfer,
            toAccount: savingsAccountId,
          ),
          _tx(DateTime(2026, 10, 4), 5.5),
        ],
      );
      final c = repo.cashFlow();
      expect(c.daysInPeriod, 31);
      expect(c.periodStart, DateTime(2026, 10));
      expect(c.currency, 'EUR');
      expect(c.income, [0, 1000, 1000, 1000]);
      expect(c.expenses, [10, 40, 40, 45.5]);
      expect(c.balance, [-10, 960, 960, 954.5]);
    });

    test('the first day has one point', () {
      final repo = _repo(
        DateTime(2026, 10, 1, 12),
        transactions: [_tx(DateTime(2026, 10, 1), 12.34)],
      );
      final c = repo.cashFlow();
      expect(c.income, [0]);
      expect(c.expenses, [12.34]);
      expect(c.balance, [-12.34]);
    });

    test('it agrees with the month balance trend', () {
      final repo = MockRepository(now: _oct15);
      final c = repo.cashFlow();
      expect(c.balance, repo.balanceTrend().current);
      expect(c.income.length, 15);
    });

    test('a month with no transactions is flat', () {
      final c = _repo(_oct15).cashFlow();
      expect(c.balance.every((v) => v == 0), isTrue);
    });
  });

  group('month budgets', () {
    test('exceeded first, then by usage, highest first; all periods', () {
      final repo = _repo(
        _oct15,
        transactions: [
          _tx(DateTime(2026, 10, 3), 60, category: 'cat_home'),
          _tx(DateTime(2026, 10, 3), 90, category: 'cat_leisure'),
          _tx(DateTime(2026, 10, 3), 150, category: 'cat_health'),
          _tx(DateTime(2026, 10, 3), 10, category: 'cat_shopping'),
          _tx(DateTime(2026, 10, 14), 20, category: 'cat_groceries'),
        ],
        budgets: [
          _budget('cat_home', 100, BudgetPeriod.monthly),
          _budget('cat_leisure', 100, BudgetPeriod.quarterly),
          _budget('cat_health', 100, BudgetPeriod.yearly),
          _budget('cat_shopping', 100, BudgetPeriod.monthly),
          _budget('cat_groceries', 25, BudgetPeriod.weekly),
        ],
      );
      final list = repo.monthBudgets();
      expect(list.map((s) => s.budget.categoryId), [
        'cat_health', // exceeded, first even if its period is the year
        'cat_leisure', // 90%
        'cat_groceries', // 80%
        'cat_home', // 60%
        'cat_shopping', // 10%
      ]);
    });

    test('the same statuses as the Budget tab', () {
      final repo = MockRepository(now: _oct15);
      final list = repo.monthBudgets();
      expect(list.length, repo.budgets.length);
      final monthly = repo.budgetOverview(BudgetPeriod.monthly).items;
      for (final s in monthly) {
        final same = list.firstWhere((e) => e.budget.id == s.budget.id);
        expect(same.spent, s.spent);
        expect(same.amount, s.amount);
        expect(same.state, s.state);
      }
      // Exceeded ones are all before the rest.
      final firstOk = list.indexWhere((s) => s.state != BudgetState.exceeded);
      expect(
        list.skip(firstOk).any((s) => s.state == BudgetState.exceeded),
        isFalse,
      );
    });

    test('no budgets: an empty list', () {
      expect(_repo(_oct15).monthBudgets(), isEmpty);
    });
  });
}
