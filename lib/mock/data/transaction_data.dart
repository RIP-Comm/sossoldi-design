// About 6 months of transactions for an Italian user: occurrences of the
// recurring transactions plus variable everyday spending, generated with a
// fixed seed so they are the same at every launch.

import 'dart:math';

import '../date_utils.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import 'account_data.dart';
import 'budget_data.dart';

const historyDays = 182;

/// Variable spending or income: how often per month and how much.
class _Spec {
  const _Spec(
    this.categoryId,
    this.subcategoryId,
    this.descriptions,
    this.min,
    this.max,
    this.countMin,
    this.countMax, {
    this.type = TransactionType.expense,
    this.probability = 1,
  });

  final String categoryId;
  final String subcategoryId;
  final List<String> descriptions;
  final double min;
  final double max;
  final int countMin;
  final int countMax;
  final TransactionType type;

  /// Chance that the spec produces anything in a given month.
  final double probability;
}

const _specs = [
  _Spec(
    'cat_groceries',
    'sub_groceries_supermarket',
    ['Weekly groceries', 'Supermarket'],
    45,
    110,
    4,
    5,
  ),
  _Spec(
    'cat_groceries',
    'sub_groceries_market',
    ['Farmers market', 'Bakery', 'Butcher'],
    8,
    30,
    1,
    3,
  ),
  _Spec('cat_transport', 'sub_transport_fuel', ['Fuel'], 45, 70, 1, 2),
  _Spec(
    'cat_transport',
    'sub_transport_public',
    ['Metro ticket', 'Train ticket', 'Bus pass top-up'],
    2,
    12,
    2,
    4,
  ),
  _Spec('cat_transport', 'sub_transport_parking', ['Parking'], 2, 8, 0, 2),
  _Spec(
    'cat_leisure',
    'sub_leisure_restaurants',
    ['Dinner out', 'Pizza with friends', 'Lunch', 'Sushi'],
    18,
    65,
    3,
    5,
  ),
  _Spec(
    'cat_leisure',
    'sub_leisure_bars',
    ['Coffee', 'Aperitivo', 'Breakfast at the bar'],
    1.5,
    8,
    3,
    6,
  ),
  _Spec(
    'cat_leisure',
    'sub_leisure_events',
    ['Cinema', 'Concert', 'Museum'],
    9,
    35,
    0,
    1,
  ),
  _Spec(
    'cat_leisure',
    'sub_leisure_travel',
    ['Train to Florence', 'Hotel', 'Weekend flight'],
    80,
    350,
    1,
    1,
    probability: 0.35,
  ),
  _Spec('cat_health', 'sub_health_pharmacy', ['Pharmacy'], 6, 30, 0, 2),
  _Spec(
    'cat_health',
    'sub_health_doctor',
    ['Dentist', 'Medical check-up'],
    40,
    120,
    1,
    1,
    probability: 0.25,
  ),
  _Spec(
    'cat_subscriptions',
    'sub_subscriptions_apps',
    ['App subscription', 'Cloud storage'],
    1.99,
    9.99,
    0,
    1,
  ),
  _Spec(
    'cat_shopping',
    'sub_shopping_clothing',
    ['Clothes', 'Shoes'],
    25,
    90,
    0,
    2,
  ),
  _Spec(
    'cat_shopping',
    'sub_shopping_electronics',
    ['Headphones', 'Phone case', 'Charger'],
    20,
    150,
    1,
    1,
    probability: 0.2,
  ),
  _Spec(
    'cat_education',
    'sub_education_books',
    ['Bookshop'],
    10,
    30,
    1,
    1,
    probability: 0.4,
  ),
  _Spec(
    'cat_education',
    'sub_education_courses',
    ['Online course'],
    30,
    90,
    1,
    1,
    probability: 0.1,
  ),
  _Spec(
    'cat_home',
    'sub_home_maintenance',
    ['Hardware store', 'Plumber'],
    20,
    150,
    1,
    1,
    probability: 0.3,
  ),
  _Spec(
    'cat_freelance',
    'sub_freelance_design',
    ['Logo design', 'Website mockup'],
    200,
    700,
    1,
    1,
    type: TransactionType.income,
    probability: 0.35,
  ),
  _Spec(
    'cat_freelance',
    'sub_freelance_consulting',
    ['Consulting'],
    150,
    400,
    1,
    1,
    type: TransactionType.income,
    probability: 0.15,
  ),
  _Spec(
    'cat_refunds',
    'sub_refunds_health',
    ['Health insurance refund'],
    15,
    80,
    1,
    1,
    type: TransactionType.income,
    probability: 0.2,
  ),
  _Spec(
    'cat_refunds',
    'sub_refunds_expenses',
    ['Work expense refund'],
    20,
    120,
    1,
    1,
    type: TransactionType.income,
    probability: 0.2,
  ),
  _Spec(
    'cat_gifts',
    'sub_gifts_family',
    ['Gift from grandparents'],
    50,
    150,
    1,
    1,
    type: TransactionType.income,
    probability: 0.1,
  ),
];

List<Transaction> buildTransactions({
  required DateTime today,
  required List<RecurringTransaction> recurring,
}) {
  final random = Random(20240521);
  final start = today.subtract(const Duration(days: historyDays));
  final drafts = <Transaction>[];

  Transaction draft({
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String description,
    String accountId = checkingAccountId,
    String? toAccountId,
    String? categoryId,
    String? subcategoryId,
    String? recurringId,
  }) => Transaction(
    id: '',
    type: type,
    amount: amount,
    currency: 'EUR',
    date: date,
    description: description,
    accountId: accountId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    recurringId: recurringId,
  );

  // Past occurrences of the recurring transactions.
  for (final r in recurring) {
    // Paused ones stopped two months ago.
    final last = r.status == RecurringStatus.paused
        ? today.subtract(const Duration(days: 60))
        : today;
    for (var k = 1; ; k++) {
      final date = r.frequency.step(r.nextDate, -k, anchorDay: r.anchorDay);
      if (date.isBefore(start)) break;
      if (date.isAfter(last)) continue;
      drafts.add(
        draft(
          type: r.type,
          amount: r.amount,
          date: date,
          description: r.description,
          accountId: r.accountId,
          toAccountId: r.toAccountId,
          categoryId: r.categoryId,
          subcategoryId: r.subcategoryId,
          recurringId: r.id,
        ),
      );
    }
  }

  // Variable spending, month by month.
  for (
    var month = DateTime(start.year, start.month);
    !month.isAfter(today);
    month = DateTime(month.year, month.month + 1)
  ) {
    final days = daysInMonth(month.year, month.month);
    for (final spec in _specs) {
      if (random.nextDouble() > spec.probability) continue;
      final count =
          spec.countMin + random.nextInt(spec.countMax - spec.countMin + 1);
      for (var i = 0; i < count; i++) {
        final date = DateTime(
          month.year,
          month.month,
          1 + random.nextInt(days),
        );
        final amount = round2(
          spec.min + random.nextDouble() * (spec.max - spec.min),
        );
        final description =
            spec.descriptions[random.nextInt(spec.descriptions.length)];
        if (date.isBefore(start) || date.isAfter(today)) continue;
        drafts.add(
          draft(
            type: spec.type,
            amount: amount,
            date: date,
            description: description,
            categoryId: spec.categoryId,
            subcategoryId: spec.subcategoryId,
          ),
        );
      }
    }
  }

  // Every budgeted category needs some spending in its current period,
  // otherwise its budget could not show a usage (e.g. on a Monday).
  for (final plan in budgetPlans) {
    if (spentInCurrentPeriod(drafts, plan.categoryId, plan.period, today) > 0) {
      continue;
    }
    final spec = _specs.firstWhere((s) => s.categoryId == plan.categoryId);
    drafts.add(
      draft(
        type: TransactionType.expense,
        amount: round2((spec.min + spec.max) / 2),
        date: today,
        description: spec.descriptions.first,
        categoryId: spec.categoryId,
        subcategoryId: spec.subcategoryId,
      ),
    );
  }

  drafts.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.description.compareTo(b.description);
  });
  return [
    for (final (i, t) in drafts.indexed)
      Transaction(
        id: 'tx_${(i + 1).toString().padLeft(4, '0')}',
        type: t.type,
        amount: t.amount,
        currency: t.currency,
        date: t.date,
        description: t.description,
        accountId: t.accountId,
        toAccountId: t.toAccountId,
        categoryId: t.categoryId,
        subcategoryId: t.subcategoryId,
        recurringId: t.recurringId,
      ),
  ];
}
