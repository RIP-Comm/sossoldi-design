import '../mock/date_utils.dart';
import '../mock/mock_repository.dart';
import '../mock/models/budget_status.dart';
import '../mock/models/portfolio.dart';
import '../mock/models/transaction.dart';
import 'insight.dart';
import 'insight_constants.dart';

/// Picks the one insight that matters right now from the repository's data.
/// Pure Dart: no Flutter, no text, [now] injected. It can be reused anywhere
/// (the Dashboard widget is its first user).
///
/// Levels, the first with a candidate wins, and inside a level the most
/// serious one (ties keep a stable order):
///  1. a budget exceeded within the last 7 days (highest usage)
///  2. a recurring expense due today or tomorrow (nearest, then largest)
///  3. a budget at risk, from 80% (highest usage)
///  4. an unusual expense of the last 3 days (highest ratio to the usual)
///  5. the portfolio down 2% or more today; budgets exceeded longer ago
///  6. a reminder to record transactions
///  7. good news: portfolio up 2% or more today, net worth at a 30-day high
///  8. nothing: [Insight.allGood]
class InsightEngine {
  const InsightEngine(this.repository);

  final MockRepository repository;

  /// The insight for [now].
  Insight evaluate(DateTime now) {
    final today = dateOnly(now);
    final levels = <List<Insight> Function()>[
      () => _recentlyExceeded(today),
      () => _recurringDue(today),
      () => _budgetsAtRisk(today),
      () => _unusualExpense(today),
      () => _portfolioDropAndOldOverruns(today),
      () => _reminder(now, today),
      () => _goodNews(today),
    ];
    for (final level in levels) {
      final candidates = level();
      if (candidates.isNotEmpty) return candidates.first;
    }
    return const Insight.allGood();
  }

  /// The next instant after [now] at which the answer can change by itself
  /// with the data standing still: the evening reminder hour or midnight.
  /// The Dashboard widget re-evaluates then.
  DateTime nextTimeBoundary(DateTime now) {
    final evening = DateTime(
      now.year,
      now.month,
      now.day,
      InsightConstants.reminderHour,
    );
    if (now.isBefore(evening)) return evening;
    return DateTime(now.year, now.month, now.day + 1);
  }

  int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  /// Exceeded budgets (current period) with the day they went over, most
  /// used first; ties: shortest period, then id.
  List<({BudgetStatus status, int age})> _exceeded(DateTime today) {
    final out = <({BudgetStatus status, int age})>[];
    for (final b in repository.budgets) {
      final s = repository.budgetStatus(b, on: today);
      if (s.state != BudgetState.exceeded) continue;
      final on = repository.budgetExceededOn(b.id, on: today);
      // Without a date it cannot be called recent.
      final age = on == null ? 1 << 30 : _daysBetween(on, today);
      out.add((status: s, age: age));
    }
    out.sort((a, b) {
      final c = b.status.usage.compareTo(a.status.usage);
      if (c != 0) return c;
      final p = a.status.budget.period.index.compareTo(
        b.status.budget.period.index,
      );
      return p != 0 ? p : a.status.budget.id.compareTo(b.status.budget.id);
    });
    return out;
  }

  Insight _exceededInsight(BudgetStatus s, int level) => Insight(
    type: InsightType.budgetExceeded,
    tone: InsightTone.negative,
    action: InsightAction.viewBudget,
    level: level,
    budgetId: s.budget.id,
    categoryId: s.budget.categoryId,
    amount: s.overBy,
    limit: s.amount,
    percent: s.usage,
  );

  List<Insight> _recentlyExceeded(DateTime today) => [
    for (final e in _exceeded(today))
      if (e.age <= InsightConstants.exceededRecentDays)
        _exceededInsight(e.status, 1),
  ];

  List<Insight> _recurringDue(DateTime today) {
    final last = addDays(today, InsightConstants.recurringDueDays);
    final due = [
      for (final o in repository.upcomingRecurrences(
        limit: 100,
        until: last,
        includeToday: true,
        type: TransactionType.expense,
      ))
        if (!o.date.isBefore(today) && !o.date.isAfter(last)) o,
    ];
    due.sort((a, b) {
      final d = a.date.compareTo(b.date);
      if (d != 0) return d;
      final amount = repository
          .toMain(b.amount, b.currency)
          .compareTo(repository.toMain(a.amount, a.currency));
      return amount != 0 ? amount : a.recurringId.compareTo(b.recurringId);
    });
    return [
      for (final o in due)
        Insight(
          type: InsightType.recurringDue,
          tone: InsightTone.attention,
          action: InsightAction.viewRecurring,
          level: 2,
          recurringId: o.recurringId,
          amount: o.amount,
          currency: o.currency,
          date: o.date,
          days: _daysBetween(today, o.date),
        ),
    ];
  }

  List<Insight> _budgetsAtRisk(DateTime today) {
    final at = <BudgetStatus>[
      for (final b in repository.budgets)
        if (repository.budgetStatus(b, on: today) case final s
            when s.state == BudgetState.warning)
          s,
    ];
    at.sort((a, b) {
      final c = b.usage.compareTo(a.usage);
      if (c != 0) return c;
      final p = a.budget.period.index.compareTo(b.budget.period.index);
      return p != 0 ? p : a.budget.id.compareTo(b.budget.id);
    });
    return [
      for (final s in at)
        Insight(
          type: InsightType.budgetAtRisk,
          tone: InsightTone.attention,
          action: InsightAction.viewBudget,
          level: 3,
          budgetId: s.budget.id,
          categoryId: s.budget.categoryId,
          amount: s.remaining,
          limit: s.amount,
          percent: s.usage,
          days: _daysBetween(today, s.periodEnd),
        ),
    ];
  }

  List<Insight> _unusualExpense(DateTime today) {
    final windowStart = addDays(today, -InsightConstants.unusualWindowDays);
    final baselineStart = addDays(
      windowStart,
      -InsightConstants.unusualBaselineDays,
    );
    final stats = <String, ({int count, double average})>{};
    final found = <Insight>[];
    for (final t in repository.transactionsInPeriod(
      windowStart,
      addDays(today, 1),
      type: TransactionType.expense,
    )) {
      final categoryId = t.categoryId;
      // A recurrence is planned, not unexpected.
      if (categoryId == null || t.recurringId != null) continue;
      final baseline = stats[categoryId] ??= repository.categoryExpenseStats(
        categoryId,
        from: baselineStart,
        to: windowStart,
      );
      if (baseline.count < InsightConstants.unusualMinimumHistory ||
          baseline.average <= 0) {
        continue;
      }
      final amount = repository.toMain(t.amount, t.currency);
      final ratio = amount / baseline.average;
      if (amount < InsightConstants.unusualMinimumAmount ||
          ratio < InsightConstants.unusualRatio) {
        continue;
      }
      found.add(
        Insight(
          type: InsightType.unusualExpense,
          tone: InsightTone.attention,
          action: InsightAction.viewTransactions,
          level: 4,
          transactionId: t.id,
          categoryId: categoryId,
          amount: amount,
          limit: baseline.average,
          ratio: ratio,
          date: dateOnly(t.date),
        ),
      );
    }
    found.sort((a, b) {
      final c = b.ratio!.compareTo(a.ratio!);
      if (c != 0) return c;
      final d = b.date!.compareTo(a.date!);
      return d != 0 ? d : a.transactionId!.compareTo(b.transactionId!);
    });
    return found;
  }

  InvestmentChangeToday? _dailyChange() {
    final snapshot = repository.investmentsSnapshot(ValuePeriod.day);
    final change = snapshot.daily;
    final percent = change?.percent;
    return percent == null
        ? null
        : (
            amount: change!.amount,
            percent: percent,
            value: snapshot.totalValue,
          );
  }

  List<Insight> _portfolioDropAndOldOverruns(DateTime today) {
    final out = <Insight>[];
    final daily = _dailyChange();
    if (daily != null && daily.percent <= InsightConstants.portfolioDropDaily) {
      out.add(
        Insight(
          type: InsightType.portfolioDrop,
          tone: InsightTone.negative,
          action: InsightAction.viewInvestments,
          level: 5,
          amount: daily.amount,
          percent: daily.percent,
          value: daily.value,
        ),
      );
    }
    for (final e in _exceeded(today)) {
      if (e.age > InsightConstants.exceededRecentDays) {
        out.add(_exceededInsight(e.status, 5));
      }
    }
    return out;
  }

  List<Insight> _reminder(DateTime now, DateTime today) {
    final last = repository.lastTransactionDate;
    if (last == null) {
      return const [
        Insight(
          type: InsightType.firstTransaction,
          tone: InsightTone.neutral,
          action: InsightAction.addTransaction,
          level: 6,
        ),
      ];
    }
    final age = _daysBetween(last, today);
    if (age > InsightConstants.reminderStaleDays) {
      return [
        Insight(
          type: InsightType.noRecentTransactions,
          tone: InsightTone.neutral,
          action: InsightAction.addTransaction,
          level: 6,
          days: age,
        ),
      ];
    }
    if (age >= 1 && now.hour >= InsightConstants.reminderHour) {
      return const [
        Insight(
          type: InsightType.noTransactionToday,
          tone: InsightTone.neutral,
          action: InsightAction.addTransaction,
          level: 6,
        ),
      ];
    }
    return const [];
  }

  List<Insight> _goodNews(DateTime today) {
    final daily = _dailyChange();
    if (daily != null && daily.percent >= InsightConstants.portfolioGainDaily) {
      return [
        Insight(
          type: InsightType.portfolioGain,
          tone: InsightTone.positive,
          action: InsightAction.viewInvestments,
          level: 7,
          amount: daily.amount,
          percent: daily.percent,
          value: daily.value,
        ),
      ];
    }
    final high = repository.netWorthHighBefore(
      today,
      days: InsightConstants.netWorthHighDays,
    );
    final now = repository.netWorthAt(today);
    if (high != null && now > high) {
      final from = repository.netWorthAt(
        addDays(today, -InsightConstants.netWorthHighDays),
      );
      final change = now - from;
      return [
        Insight(
          type: InsightType.netWorthHigh,
          tone: InsightTone.positive,
          action: InsightAction.none,
          level: 7,
          amount: now,
          limit: high,
          change: change,
          percent: from > 0 ? change / from : null,
          days: InsightConstants.netWorthHighDays,
        ),
      ];
    }
    return const [];
  }
}

typedef InvestmentChangeToday = ({double amount, double percent, double value});
