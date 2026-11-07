import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/insights/insight.dart';
import 'package:sossoldi/insights/insight_constants.dart';
import 'package:sossoldi/insights/insight_engine.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/portfolio.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';
import 'package:sossoldi/mock/models/transaction.dart';

// Thursday; the week runs Monday 19 to Sunday 25, the month 1 to 31.
final _now = DateTime(2026, 10, 22, 10);

int _n = 0;

DateTime _ago(int days, [DateTime? from]) {
  final d = from ?? _now;
  return DateTime(d.year, d.month, d.day - days);
}

Transaction _tx(
  int daysAgo,
  double amount, {
  String category = 'cat_groceries',
  TransactionType type = TransactionType.expense,
  String? recurringId,
  String description = 'test',
}) => Transaction(
  id: 'tx_t_${(_n++).toString().padLeft(4, '0')}',
  type: type,
  amount: amount,
  currency: 'EUR',
  date: _ago(daysAgo),
  description: description,
  accountId: checkingAccountId,
  categoryId: category,
  recurringId: recurringId,
);

Budget _budget(
  double amount, {
  String category = 'cat_groceries',
  BudgetPeriod period = BudgetPeriod.monthly,
}) => Budget(
  id: 'bud_${category}_${period.name}',
  categoryId: category,
  amount: amount,
  currency: 'EUR',
  period: period,
);

RecurringTransaction _rec(
  String id,
  double amount,
  int inDays, {
  TransactionType type = TransactionType.expense,
  RecurringStatus status = RecurringStatus.active,
}) => RecurringTransaction(
  id: id,
  type: type,
  amount: amount,
  currency: 'EUR',
  description: 'Rec $id',
  frequency: RecurrenceFrequency.monthly,
  // One due today has happened today and its next date is a month away.
  nextDate: _ago(inDays == 0 ? -30 : -inDays),
  status: status,
  accountId: checkingAccountId,
  toAccountId: type == TransactionType.transfer ? savingsAccountId : null,
  categoryId: type == TransactionType.transfer ? null : 'cat_home',
);

/// Only the given data, no portfolio unless [investments] is true.
MockRepository _repo({
  DateTime? now,
  List<Transaction> transactions = const [],
  List<Budget> budgets = const [],
  List<RecurringTransaction> recurring = const [],
  bool investments = false,
}) => MockRepository(
  now: now ?? _now,
  transactions: (_, _) => transactions,
  budgets: (_, _) => budgets,
  recurring: (_) => recurring,
  investments: investments
      ? null
      : (_, _) => (holdings: const [], movements: const []),
);

/// A recorded transaction today keeps the reminders quiet; an old one makes
/// the history long enough for the net worth high, and the spending lowers
/// the net worth so it is not at a high.
List<Transaction> get _quiet => [_tx(40, 30, category: 'cat_home'), _tx(0, 5)];

Insight _eval(MockRepository r, [DateTime? now]) =>
    InsightEngine(r).evaluate(now ?? _now);

void main() {
  group('neutral and new user', () {
    test('no rule applies: All good', () {
      final i = _eval(_repo(transactions: _quiet));
      expect(i.type, InsightType.allGood);
      expect(i.isNone, isTrue);
      expect(i.tone, InsightTone.neutral);
      expect(i.action, InsightAction.none);
      expect(i.level, 8);
    });

    test('a new user is asked for the first transaction', () {
      final r = MockRepository.newUser(now: _now);
      final i = _eval(r);
      expect(i.type, InsightType.firstTransaction);
      expect(i.action, InsightAction.addTransaction);
      // At any hour.
      expect(
        _eval(r, DateTime(2026, 10, 22, 7)).type,
        InsightType.firstTransaction,
      );
    });
  });

  group('level 1: budget exceeded in the last 7 days', () {
    test('picks the budget with the highest percentage, with its numbers', () {
      final r = _repo(
        transactions: [
          _tx(1, 150),
          _tx(1, 120, category: 'cat_home'),
        ],
        budgets: [
          _budget(100), // 150%
          _budget(100, category: 'cat_home'), // 120%
        ],
      );
      final i = _eval(r);
      expect(i.type, InsightType.budgetExceeded);
      expect(i.level, 1);
      expect(i.tone, InsightTone.negative);
      expect(i.action, InsightAction.viewBudget);
      expect(i.budgetId, 'bud_cat_groceries_monthly');
      expect(i.percent, closeTo(1.5, 1e-9));
      expect(i.amount, 50);
      expect(i.limit, 100);
      // Same numbers as the Budget tab.
      final s = r.budgetStatus(r.budget('bud_cat_groceries_monthly'));
      expect(i.percent, s.usage);
      expect(i.amount, s.overBy);
    });

    test('the day it went over comes from the transactions', () {
      final r = _repo(
        transactions: [_tx(9, 60), _tx(5, 30), _tx(3, 20), _tx(1, 10)],
        budgets: [_budget(100)],
      );
      // 60, 90, 110: over on the third one, 3 days ago.
      expect(r.budgetExceededOn('bud_cat_groceries_monthly'), _ago(3));
      expect(_eval(r).level, 1);
    });

    test('7 days ago is still recent, 8 drops to level 5', () {
      final seven = _repo(transactions: [_tx(7, 150)], budgets: [_budget(100)]);
      expect(_eval(seven).level, 1);
      final eight = _repo(transactions: [_tx(8, 150)], budgets: [_budget(100)]);
      final i = _eval(eight);
      expect(i.type, InsightType.budgetExceeded);
      expect(i.level, 5);
    });

    test('not exceeded: no date', () {
      final r = _repo(transactions: [_tx(1, 50)], budgets: [_budget(100)]);
      expect(r.budgetExceededOn('bud_cat_groceries_monthly'), isNull);
    });

    test('a tie in percentage keeps a stable order (shortest period)', () {
      final r = _repo(
        transactions: [_tx(1, 150)],
        budgets: [
          _budget(100),
          _budget(100, period: BudgetPeriod.weekly),
        ],
      );
      expect(_eval(r).budgetId, 'bud_cat_groceries_weekly');
      expect(_eval(r), _eval(r));
    });
  });

  group('level order', () {
    final exceeded = _tx(1, 150);
    test('a budget just exceeded beats a payment due', () {
      final r = _repo(
        transactions: [exceeded],
        budgets: [_budget(100)],
        recurring: [_rec('r1', 40, 1)],
      );
      expect(_eval(r).type, InsightType.budgetExceeded);
    });

    test('a payment due beats a budget at risk', () {
      final r = _repo(
        transactions: [_tx(1, 85)],
        budgets: [_budget(100)],
        recurring: [_rec('r1', 40, 1)],
      );
      expect(_eval(r).type, InsightType.recurringDue);
    });

    test('a budget at risk beats an unusual expense', () {
      final r = _repo(
        transactions: [
          for (var i = 0; i < 6; i++) _tx(20 + i, 20, category: 'cat_home'),
          _tx(0, 80, category: 'cat_home'),
          _tx(1, 85),
        ],
        budgets: [_budget(100)],
      );
      expect(_eval(r).type, InsightType.budgetAtRisk);
      // Without the budget the unusual expense shows.
      final without = _repo(transactions: r.transactions.toList());
      expect(_eval(without).type, InsightType.unusualExpense);
    });

    test('an unusual expense beats the reminders and the good news', () {
      final i = _eval(
        _repo(
          transactions: [
            for (var i = 0; i < 6; i++) _tx(20 + i, 20),
            _tx(1, 80),
          ],
        ),
        DateTime(2026, 10, 22, 19),
      );
      expect(i.type, InsightType.unusualExpense);
    });

    test('a reminder beats good news', () {
      final r = _repo(
        transactions: [
          _tx(40, 30, category: 'cat_home'),
          _tx(1, 2000, type: TransactionType.income, category: 'cat_work'),
          _tx(0, 1, category: 'cat_home'),
        ],
      );
      // Net worth is at a 30-day high only because of the income of
      // yesterday: today's small expense lowers it, so use another repo.
      final high = _repo(
        transactions: [
          _tx(40, 30, category: 'cat_home'),
          _tx(0, 2000, type: TransactionType.income, category: 'cat_work'),
        ],
      );
      expect(_eval(high).type, InsightType.netWorthHigh);
      // The evening with the last transaction yesterday: the reminder.
      final evening = _repo(
        transactions: [
          _tx(40, 30, category: 'cat_home'),
          _tx(1, 2000, type: TransactionType.income, category: 'cat_work'),
        ],
      );
      expect(
        _eval(evening, DateTime(2026, 10, 22, 19)).type,
        InsightType.noTransactionToday,
      );
      expect(_eval(r).type, isNot(InsightType.noTransactionToday));
    });
  });

  group('level 2: recurring due', () {
    test('today or tomorrow, nearest then largest, expenses only', () {
      final r = _repo(
        transactions: [
          ..._quiet,
          _tx(0, 10, category: 'cat_home', recurringId: 'b_today_small'),
          _tx(0, 30, category: 'cat_home', recurringId: 'c_today_big'),
          _tx(0, 800, category: 'cat_home', recurringId: 'e_paused'),
        ],
        recurring: [
          _rec('a_tomorrow_big', 90, 1),
          _rec('b_today_small', 10, 0),
          _rec('c_today_big', 30, 0),
          _rec('d_in_two_days', 500, 2),
          _rec('e_paused', 800, 0, status: RecurringStatus.paused),
          _rec('f_income', 700, 0, type: TransactionType.income),
        ],
      );
      final i = _eval(r);
      expect(i.type, InsightType.recurringDue);
      expect(i.recurringId, 'c_today_big');
      expect(i.days, 0);
      expect(i.amount, 30);
      expect(i.action, InsightAction.viewRecurring);
      expect(i.tone, InsightTone.attention);
    });

    test('two days away is not due', () {
      final r = _repo(transactions: _quiet, recurring: [_rec('r', 40, 2)]);
      expect(_eval(r).type, InsightType.allGood);
    });

    test('tomorrow counts', () {
      final r = _repo(transactions: _quiet, recurring: [_rec('r', 40, 1)]);
      expect(_eval(r).days, 1);
    });
  });

  group('level 3: budget at risk', () {
    test('80% to 100%, with the days left in the period', () {
      final r = _repo(transactions: [_tx(1, 85)], budgets: [_budget(100)]);
      final i = _eval(r);
      expect(i.type, InsightType.budgetAtRisk);
      expect(i.level, 3);
      expect(i.percent, closeTo(0.85, 1e-9));
      expect(i.amount, 15);
      // 22 October to the end of the month, as the digest counts.
      expect(i.days, 10);
      expect(i.tone, InsightTone.attention);
    });

    test('exactly 100% is at risk, not exceeded; 79% is nothing', () {
      expect(
        _eval(_repo(transactions: [_tx(1, 100)], budgets: [_budget(100)])).type,
        InsightType.budgetAtRisk,
      );
      expect(
        _eval(
          _repo(
            transactions: [
              _tx(1, 79),
              _tx(0, 1, category: 'cat_home'),
            ],
            budgets: [_budget(100)],
          ),
        ).type,
        isNot(InsightType.budgetAtRisk),
      );
    });

    test('the highest percentage wins', () {
      final r = _repo(
        transactions: [
          _tx(1, 85),
          _tx(1, 95, category: 'cat_home'),
        ],
        budgets: [
          _budget(100),
          _budget(100, category: 'cat_home'),
        ],
      );
      expect(_eval(r).categoryId, 'cat_home');
    });
  });

  group('level 4: unusual expense', () {
    List<Transaction> history([int count = 6]) => [
      for (var i = 0; i < count; i++) _tx(10 + i * 3, 20),
    ];

    test('3x the usual and at least 50 EUR', () {
      final r = _repo(transactions: [...history(), _tx(2, 60)]);
      final i = _eval(r, DateTime(2026, 10, 22, 12));
      expect(i.type, InsightType.unusualExpense);
      expect(i.ratio, closeTo(3, 1e-9));
      expect(i.amount, 60);
      expect(i.limit, 20);
      expect(i.action, InsightAction.viewTransactions);
    });

    test('thresholds: below 3x, below 50 EUR, too little history', () {
      InsightType type(List<Transaction> t) =>
          _eval(_repo(transactions: t)).type;
      expect(
        type([...history(), _tx(1, 59)]),
        isNot(InsightType.unusualExpense),
      );
      // 3x of a 10 EUR average is 30 EUR: under the minimum amount.
      expect(
        type([for (var i = 0; i < 6; i++) _tx(10 + i, 10), _tx(1, 40)]),
        isNot(InsightType.unusualExpense),
      );
      expect(
        type([...history(4), _tx(1, 200)]),
        isNot(InsightType.unusualExpense),
      );
      expect(type([...history(5), _tx(1, 200)]), InsightType.unusualExpense);
    });

    test('only the last 3 days, never a recurring or a transfer', () {
      InsightType type(Transaction t) =>
          _eval(_repo(transactions: [...history(), t])).type;
      expect(type(_tx(3, 200)), InsightType.unusualExpense);
      expect(type(_tx(4, 200)), isNot(InsightType.unusualExpense));
      expect(
        type(_tx(1, 200, recurringId: 'rec_x')),
        isNot(InsightType.unusualExpense),
      );
    });

    test('the highest ratio wins', () {
      final r = _repo(
        transactions: [
          ...history(),
          _tx(1, 100), // 5x
          _tx(1, 90), // 4.5x
        ],
      );
      expect(_eval(r).amount, 100);
    });

    test('a category with little history has none', () {
      final r = _repo(transactions: [_tx(20, 20), _tx(1, 500)]);
      expect(_eval(r).type, isNot(InsightType.unusualExpense));
    });
  });

  group('level 5: portfolio drop', () {
    MockRepository withPortfolio(double factor, {List<Budget>? budgets}) {
      final r = _repo(
        transactions: _quiet,
        budgets: budgets ?? const [],
        investments: true,
      );
      for (final h in r.holdings) {
        if (h.assetId != null) {
          r.debugSetLastPrice(h.assetId!, r.latestPrice(h.assetId!) * factor);
        }
      }
      return r;
    }

    test('a daily change of -2% or worse', () {
      final r = withPortfolio(0.5);
      final i = _eval(r);
      expect(i.type, InsightType.portfolioDrop);
      expect(i.level, 5);
      expect(i.tone, InsightTone.negative);
      expect(i.action, InsightAction.viewInvestments);
      // The number of the Investments snapshot.
      final daily = r.investmentsSnapshot(ValuePeriod.day).daily!;
      expect(i.percent, daily.percent);
      expect(i.amount, daily.amount);
      expect(i.percent! <= InsightConstants.portfolioDropDaily, isTrue);
    });

    test('older budget overruns share the level, after the drop', () {
      final r = withPortfolio(0.5, budgets: [_budget(1, category: 'cat_home')]);
      // The overrun is older than 7 days: level 5, behind today's drop.
      expect(_eval(r).type, InsightType.portfolioDrop);
    });
  });

  group('level 6: reminder', () {
    test('after 18:00 with nothing recorded today', () {
      final r = _repo(transactions: [_tx(40, 30), _tx(1, 5)]);
      expect(_eval(r, DateTime(2026, 10, 22, 17, 59)).isNone, isTrue);
      final i = _eval(r, DateTime(2026, 10, 22, 18));
      expect(i.type, InsightType.noTransactionToday);
      expect(i.action, InsightAction.addTransaction);
      expect(i.tone, InsightTone.neutral);
    });

    test('nothing in the evening when today already has one', () {
      final r = _repo(transactions: _quiet);
      expect(_eval(r, DateTime(2026, 10, 22, 21)).isNone, isTrue);
    });

    test('whatever the hour after more than 2 days', () {
      final two = _repo(transactions: [_tx(40, 30), _tx(2, 5)]);
      expect(_eval(two).isNone, isTrue);
      final three = _repo(transactions: [_tx(40, 30), _tx(3, 5)]);
      final i = _eval(three);
      expect(i.type, InsightType.noRecentTransactions);
      expect(i.days, 3);
    });

    test('a change of day without restarting', () {
      final r = _repo(transactions: [_tx(40, 30), _tx(1, 5)]);
      final engine = InsightEngine(r);
      expect(
        engine.evaluate(DateTime(2026, 10, 22, 23, 59)).type,
        InsightType.noTransactionToday,
      );
      // Midnight: the last one is now 2 days old, the morning is quiet.
      expect(engine.evaluate(DateTime(2026, 10, 23, 8)).isNone, isTrue);
      expect(
        engine.evaluate(DateTime(2026, 10, 24, 8)).type,
        InsightType.noRecentTransactions,
      );
    });

    test('the moments the answer can change by itself', () {
      final engine = InsightEngine(_repo());
      expect(
        engine.nextTimeBoundary(DateTime(2026, 10, 22, 10)),
        DateTime(2026, 10, 22, 18),
      );
      expect(
        engine.nextTimeBoundary(DateTime(2026, 10, 22, 18)),
        DateTime(2026, 10, 23),
      );
      expect(
        engine.nextTimeBoundary(DateTime(2026, 12, 31, 20)),
        DateTime(2027, 1, 1),
      );
    });
  });

  group('level 7: good news', () {
    test('the portfolio up 2% today', () {
      final r = _repo(transactions: _quiet, investments: true);
      for (final h in r.holdings) {
        if (h.assetId != null) {
          r.debugSetLastPrice(h.assetId!, r.latestPrice(h.assetId!) * 1.5);
        }
      }
      final i = _eval(r);
      expect(i.type, InsightType.portfolioGain);
      expect(i.tone, InsightTone.positive);
      expect(i.action, InsightAction.viewInvestments);
    });

    test('net worth above the last 30 days, with no action', () {
      final r = _repo(
        transactions: [
          _tx(40, 30, category: 'cat_home'),
          _tx(0, 2000, type: TransactionType.income, category: 'cat_work'),
        ],
      );
      final i = _eval(r);
      expect(i.type, InsightType.netWorthHigh);
      expect(i.action, InsightAction.none);
      expect(i.amount, r.netWorth);
      expect(i.limit, lessThan(i.amount!));
      expect(i.change, isNotNull);
      expect(i.change, greaterThan(0));
      expect(i.days, InsightConstants.netWorthHighDays);
    });

    test('a short history has no net worth high', () {
      final r = _repo(
        transactions: [
          _tx(5, 2000, type: TransactionType.income, category: 'cat_work'),
          _tx(0, 1),
        ],
      );
      expect(r.netWorthHighBefore(_now, days: 30), isNull);
      expect(_eval(r).type, isNot(InsightType.netWorthHigh));
    });
  });

  test('the same data and now give the same insight', () {
    final r = _repo(transactions: [_tx(1, 150)], budgets: [_budget(100)]);
    expect(_eval(r), _eval(r));
  });

  test('with the demo data the engine answers for any day', () {
    for (final now in [
      DateTime(2026, 10, 22, 10),
      DateTime(2026, 1, 1, 9),
      DateTime(2026, 3, 2, 19),
      DateTime(2026, 12, 31, 23),
    ]) {
      final r = MockRepository(now: now);
      final i = InsightEngine(r).evaluate(now);
      expect(i.level, inInclusiveRange(1, 8));
      if (i.budgetId != null) {
        final s = r.budgetStatus(r.budget(i.budgetId!));
        expect(i.percent, s.usage);
      }
    }
  });
}
