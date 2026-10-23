// Single entry point to the prototype data. Screens read everything from
// here and never touch the lists in lib/mock/data, so this class can later
// be replaced by one backed by a real database with the same methods.
//
// Data is in memory, generated once per instance, relative to [now] and
// with fixed random seeds: the same [now] always gives the same data.
// Amounts are doubles rounded to cents, good enough for a prototype.

import 'date_utils.dart';
import 'data/account_data.dart';
import 'data/asset_catalog_data.dart';
import 'data/budget_data.dart';
import 'data/category_data.dart';
import 'data/exchange_rate_data.dart';
import 'data/holding_data.dart';
import 'data/recurring_data.dart';
import 'data/transaction_data.dart';
import 'data/user_data.dart';
import 'models/account.dart';
import 'models/asset.dart';
import 'models/budget.dart';
import 'models/budget_status.dart';
import 'models/category.dart';
import 'models/exchange_rate.dart';
import 'models/holding.dart';
import 'models/investment_movement.dart';
import 'models/price_point.dart';
import 'models/recurring_transaction.dart';
import 'models/subcategory.dart';
import 'models/transaction.dart';
import 'models/user.dart';

class MockRepository {
  MockRepository({DateTime? now}) : now = now ?? DateTime.now() {
    _recurring = buildRecurring(today);
    _transactions = buildTransactions(today: today, recurring: _recurring);
    _budgets = buildBudgets(today: today, transactions: _transactions);
    _priceHistories = buildPriceHistories(today);
    final investments = buildHoldingsAndMovements(
      today: today,
      catalog: mockAssetCatalog,
      priceHistories: _priceHistories,
    );
    _holdings = investments.holdings;
    _movements = investments.movements;
    _exchangeRates = buildExchangeRates(this.now);
  }

  /// The moment the data is relative to.
  final DateTime now;
  DateTime get today => dateOnly(now);

  late final List<RecurringTransaction> _recurring;
  late final List<Transaction> _transactions;
  late final List<Budget> _budgets;
  late final Map<String, List<PricePoint>> _priceHistories;
  late final List<Holding> _holdings;
  late final List<InvestmentMovement> _movements;
  late final List<ExchangeRate> _exchangeRates;

  // User

  User get user => mockUser;

  // Accounts

  List<Account> get accounts => List.unmodifiable(mockAccounts);

  Account account(String id) => mockAccounts.firstWhere((a) => a.id == id);

  /// Initial balance plus all transactions up to today, in the account
  /// currency.
  double accountBalance(String accountId) {
    var balance = account(accountId).initialBalance;
    for (final t in _transactions) {
      if (t.accountId == accountId) {
        balance += t.type == TransactionType.income ? t.amount : -t.amount;
      }
      if (t.toAccountId == accountId) balance += t.amount;
    }
    return round2(balance);
  }

  /// Sum of all account balances, in EUR.
  double get totalBalance => round2(
    mockAccounts.fold(
      0.0,
      (sum, a) => sum + toEur(accountBalance(a.id), a.currency),
    ),
  );

  // Categories

  List<Category> categories({CategoryType? type}) => List.unmodifiable(
    mockCategories.where((c) => type == null || c.type == type),
  );

  Category category(String id) => mockCategories.firstWhere((c) => c.id == id);

  List<Subcategory> subcategoriesOf(String categoryId) => List.unmodifiable(
    mockSubcategories.where((s) => s.categoryId == categoryId),
  );

  Subcategory subcategory(String id) =>
      mockSubcategories.firstWhere((s) => s.id == id);

  /// The parent category, which holds icon and color of the subcategory.
  Category parentOf(Subcategory subcategory) =>
      category(subcategory.categoryId);

  // Transactions

  /// All transactions, newest first.
  List<Transaction> get transactions =>
      List.unmodifiable(_transactions.reversed);

  Transaction transaction(String id) =>
      _transactions.firstWhere((t) => t.id == id);

  /// Transactions with [start] <= date < [end], newest first, optionally
  /// filtered. [accountId] matches both sides of a transfer.
  List<Transaction> transactionsInPeriod(
    DateTime start,
    DateTime end, {
    String? accountId,
    String? categoryId,
    TransactionType? type,
  }) => List.unmodifiable(
    _transactions.reversed.where(
      (t) =>
          !t.date.isBefore(start) &&
          t.date.isBefore(end) &&
          (accountId == null ||
              t.accountId == accountId ||
              t.toAccountId == accountId) &&
          (categoryId == null || t.categoryId == categoryId) &&
          (type == null || t.type == type),
    ),
  );

  double totalIncome(DateTime start, DateTime end) =>
      _sum(transactionsInPeriod(start, end, type: TransactionType.income));

  double totalExpenses(DateTime start, DateTime end) =>
      _sum(transactionsInPeriod(start, end, type: TransactionType.expense));

  /// Expenses per top-level category in the period, in EUR.
  Map<String, double> expensesByCategory(DateTime start, DateTime end) {
    final totals = <String, double>{};
    for (final t in transactionsInPeriod(
      start,
      end,
      type: TransactionType.expense,
    )) {
      totals[t.categoryId!] =
          (totals[t.categoryId!] ?? 0) + toEur(t.amount, t.currency);
    }
    return totals.map((k, v) => MapEntry(k, round2(v)));
  }

  double _sum(Iterable<Transaction> list) =>
      round2(list.fold(0.0, (sum, t) => sum + toEur(t.amount, t.currency)));

  // Recurring

  List<RecurringTransaction> recurringTransactions({RecurringStatus? status}) =>
      List.unmodifiable(
        _recurring.where((r) => status == null || r.status == status),
      );

  RecurringTransaction recurring(String id) =>
      _recurring.firstWhere((r) => r.id == id);

  /// Active recurring transactions due within [days], soonest first.
  List<RecurringTransaction> upcomingRecurring({int days = 30}) {
    final limit = today.add(Duration(days: days));
    return List.unmodifiable(
      _recurring
          .where(
            (r) =>
                r.status == RecurringStatus.active &&
                !r.nextDate.isAfter(limit),
          )
          .toList()
        ..sort((a, b) => a.nextDate.compareTo(b.nextDate)),
    );
  }

  // Budgets

  List<Budget> get budgets => List.unmodifiable(_budgets);

  Budget budgetForCategory(String categoryId) =>
      _budgets.firstWhere((b) => b.categoryId == categoryId);

  /// Spending against [budget] in its period containing [on] (default today).
  BudgetStatus budgetStatus(Budget budget, {DateTime? on}) {
    final range = budget.period.rangeContaining(on ?? today);
    final spent = transactionsInPeriod(
      range.start,
      range.end,
      categoryId: budget.categoryId,
      type: TransactionType.expense,
    );
    return BudgetStatus(
      budget: budget,
      spent: _sum(spent),
      periodStart: range.start,
      periodEnd: range.end,
    );
  }

  List<BudgetStatus> budgetStatuses({DateTime? on}) =>
      List.unmodifiable(_budgets.map((b) => budgetStatus(b, on: on)));

  // Asset catalog

  List<Asset> get assetCatalog => List.unmodifiable(mockAssetCatalog);

  Asset asset(String id) => mockAssetCatalog.firstWhere((a) => a.id == id);

  /// Catalog search by name, ticker or ISIN (case-insensitive).
  List<Asset> searchAssets(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return List.unmodifiable(
      mockAssetCatalog.where(
        (a) =>
            a.name.toLowerCase().contains(q) ||
            a.ticker.toLowerCase().contains(q) ||
            a.isin.toLowerCase().contains(q),
      ),
    );
  }

  /// Daily prices of the last year, oldest first, in the asset currency.
  List<PricePoint> priceHistory(String assetId) =>
      List.unmodifiable(_priceHistories[assetId]!);

  /// Latest price, in the asset currency.
  double latestPrice(String assetId) => _priceHistories[assetId]!.last.price;

  /// When prices were last "refreshed" (simulated): same as the rates.
  DateTime get pricesUpdatedAt => ratesUpdatedAt;

  // Holdings

  List<Holding> get holdings => List.unmodifiable(_holdings);

  Holding holding(String id) => _holdings.firstWhere((h) => h.id == id);

  /// Current value of a position, in EUR.
  double holdingValue(String holdingId) {
    final h = holding(holdingId);
    if (h.isManual) return round2(h.manualValue!);
    return round2(toEur(h.quantity * latestPrice(h.assetId!), h.currency));
  }

  /// Purchase cost of the units still held (quantity x PMC), in EUR.
  double holdingCost(String holdingId) {
    final h = holding(holdingId);
    return round2(toEur(h.quantity * h.averageCost, h.currency));
  }

  double holdingGain(String holdingId) =>
      round2(holdingValue(holdingId) - holdingCost(holdingId));

  double get portfolioValue =>
      round2(_holdings.fold(0.0, (sum, h) => sum + holdingValue(h.id)));

  double get portfolioCost =>
      round2(_holdings.fold(0.0, (sum, h) => sum + holdingCost(h.id)));

  double get portfolioGain => round2(portfolioValue - portfolioCost);

  /// Accounts plus investments, in EUR.
  double get netWorth => round2(totalBalance + portfolioValue);

  // Investment movements

  /// Newest first, optionally for one holding. Includes expected
  /// dividends (dated after today).
  List<InvestmentMovement> movements({String? holdingId}) => List.unmodifiable(
    _movements.reversed.where(
      (m) => holdingId == null || m.holdingId == holdingId,
    ),
  );

  /// Dividends dated after today, soonest first.
  List<InvestmentMovement> get expectedDividends => List.unmodifiable(
    _movements.where(
      (m) => m.type == MovementType.dividend && m.date.isAfter(today),
    ),
  );

  // Exchange rates

  List<ExchangeRate> get exchangeRates => List.unmodifiable(_exchangeRates);

  DateTime get ratesUpdatedAt => _exchangeRates.first.updatedAt;

  /// Converts [amount] from [currency] to EUR with the fixed rates.
  double toEur(double amount, String currency) {
    if (currency == 'EUR') return amount;
    return amount *
        _exchangeRates.firstWhere((r) => r.currency == currency).toEur;
  }
}
