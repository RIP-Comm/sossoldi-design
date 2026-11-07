// Single entry point to the prototype data. Screens read everything from
// here and never touch the lists in lib/mock/data, so this class can later
// be replaced by one backed by a real database with the same methods.
//
// Data is in memory, generated once per instance, relative to [now] and
// with fixed random seeds: the same [now] always gives the same data.
// Amounts are doubles rounded to cents, good enough for a prototype.

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;

import 'date_utils.dart';
import 'data/account_data.dart';
import 'data/asset_catalog_data.dart';
import 'data/budget_data.dart';
import 'data/category_data.dart';
import 'data/exchange_rate_data.dart';
import 'data/holding_data.dart';
import 'data/recurring_data.dart';
import 'data/suggested_category_data.dart';
import 'data/transaction_data.dart';
import 'data/user_data.dart';
import 'models/account.dart';
import 'models/account_edit.dart';
import 'models/asset.dart';
import 'models/balance_trend.dart';
import 'models/budget.dart';
import 'models/budget_overview.dart';
import 'models/budget_status.dart';
import 'models/category.dart';
import 'models/category_edit.dart';
import 'models/exchange_rate.dart';
import 'models/finance_overview.dart';
import 'models/holding.dart';
import 'models/investment_movement.dart';
import 'models/movement_edit.dart';
import 'models/investments_snapshot.dart';
import 'models/net_worth.dart';
import 'models/portfolio.dart';
import 'models/price_point.dart';
import 'models/recurring_occurrence.dart';
import 'models/recurring_transaction.dart';
import 'models/subcategory.dart';
import 'models/suggested_category.dart';
import 'models/transaction_breakdown.dart';
import 'models/transaction_edit.dart';
import 'models/transaction_filter.dart';
import 'models/transaction_page.dart';
import 'models/transaction_time_range.dart';
import 'models/transaction.dart';
import 'models/user.dart';

class MockRepository extends ChangeNotifier {
  /// [recurring] replaces the generated recurring transactions (tests of
  /// edge cases such as a recurrence on the 31st); [accounts], [transactions]
  /// and [budgets] do the same for the Overview tests.
  MockRepository({
    DateTime? now,
    @visibleForTesting
    List<RecurringTransaction> Function(DateTime today)? recurring,
    @visibleForTesting List<Account>? accounts,
    @visibleForTesting
    List<Transaction> Function(DateTime today, List<RecurringTransaction> r)?
    transactions,
    @visibleForTesting
    List<Budget> Function(DateTime today, List<Transaction> t)? budgets,
    @visibleForTesting
    ({List<Holding> holdings, List<InvestmentMovement> movements}) Function(
      DateTime today,
      Map<String, List<PricePoint>> priceHistories,
    )?
    investments,

    /// What "the current time" is for the "updated X ago" label and a price
    /// refresh. Default: the real clock, or [now] when that is given (so
    /// tests do not depend on it).
    DateTime Function()? clock,
    String? mainCurrency,
    @visibleForTesting List<Category>? categories,
    @visibleForTesting List<Subcategory>? subcategories,
  }) : now = now ?? DateTime.now(),
       _accounts = _withOneMain(List.of(accounts ?? mockAccounts)),
       _categories = List.of(categories ?? mockCategories),
       _subcategories = List.of(subcategories ?? mockSubcategories),
       _mainCurrency = mainCurrency ?? mockUser.mainCurrency,
       _clock = clock ?? (now != null ? (() => now) : DateTime.now) {
    // Copies: the lists given (e.g. const empty ones) may not be growable.
    _recurring = List.of((recurring ?? buildRecurring)(today));
    _transactions = List.of(
      transactions?.call(today, _recurring) ??
          buildTransactions(today: today, recurring: _recurring),
    );
    // A copy: the list given (e.g. a const empty one) may not be growable.
    _budgets = List.of(
      budgets?.call(today, _transactions) ??
          buildBudgets(today: today, transactions: _transactions),
    );
    _priceHistories = buildPriceHistories(today);
    _intradayPrices = buildIntradayPrices(_priceHistories);
    final generated =
        investments?.call(today, _priceHistories) ??
        buildHoldingsAndMovements(
          today: today,
          catalog: mockAssetCatalog,
          priceHistories: _priceHistories,
        );
    _exchangeRates = buildExchangeRates(this.now);
    _allHoldings = [...generated.holdings];
    _movements = [...generated.movements];
    // The movements move the liquidity from now on: the opening balance of
    // each account makes today's liquidity what it was before them.
    for (final a in _accounts) {
      _opening[a.id] = -_movementCash(a.id, null);
    }
    _pricesUpdatedAt = this.now.subtract(const Duration(minutes: 4));
  }

  /// A new user: nothing but the identity of the demo user and the main
  /// currency (EUR unless [mainCurrency] says otherwise). No account,
  /// category, budget, transaction, recurrence, position or movement; the
  /// asset catalog and the exchange rates are still there, they are not the
  /// user's. The onboarding fills it.
  MockRepository.newUser({DateTime? now, String mainCurrency = 'EUR'})
    : this(
        now: now,
        mainCurrency: mainCurrency,
        accounts: const [],
        categories: const [],
        subcategories: const [],
        recurring: (_) => const [],
        transactions: (_, _) => const [],
        budgets: (_, _) => const [],
        investments: (_, _) => (holdings: const [], movements: const []),
      );

  /// The moment the data is relative to.
  final DateTime now;
  DateTime get today => dateOnly(now);

  final List<Account> _accounts;
  final List<Category> _categories;
  final List<Subcategory> _subcategories;
  int _accountSeq = 1;
  int _transactionSeq = 1;
  int _recurringSeq = 1;
  int _categorySeq = 1;
  int _subcategorySeq = 1;
  int _budgetSeq = 1;
  late final List<RecurringTransaction> _recurring;
  late final List<Transaction> _transactions;
  late final List<Budget> _budgets;
  late final Map<String, List<PricePoint>> _priceHistories;
  late final Map<String, List<PricePoint>> _intradayPrices;
  final DateTime Function() _clock;
  late DateTime _pricesUpdatedAt;
  int _refreshCount = 0;
  late final List<Holding> _allHoldings;
  final Map<String, double> _opening = {};
  int _idSeq = 1;
  Map<String, List<({DateTime date, double units, double cost})>>? _eventsCache;
  late final List<InvestmentMovement> _movements;
  late final List<ExchangeRate> _exchangeRates;

  // User

  User get user => mockUser;

  String _mainCurrency;

  /// The user's main currency (ISO 4217): totals are shown in it. The data
  /// is generated in EUR; the other currencies are shown by converting
  /// with the fixed rates.
  String get mainCurrency => _mainCurrency;

  /// Currencies the main one can be changed to: EUR and those with a rate.
  List<String> get supportedCurrencies => [
    'EUR',
    for (final r in _exchangeRates) r.currency,
  ];

  /// Changes the main currency and tells the listeners, so the screens and
  /// controllers that keep results read them again.
  void setMainCurrency(String currency) {
    if (currency == _mainCurrency || !supportedCurrencies.contains(currency)) {
      return;
    }
    _mainCurrency = currency;
    notifyListeners();
  }

  // Accounts

  List<Account> get accounts => List.unmodifiable(_accounts);

  Account account(String id) => _accounts.firstWhere((a) => a.id == id);

  /// The main account (the default of the forms); null with no accounts.
  Account? get mainAccount => _accounts.where((a) => a.isMain).firstOrNull;

  /// Exactly one main account when there is any: the first one if none (or
  /// several) says so.
  static List<Account> _withOneMain(List<Account> list) {
    if (list.isEmpty) return list;
    final main = list.indexWhere((a) => a.isMain);
    final keep = main < 0 ? 0 : main;
    return [
      for (final (i, a) in list.indexed)
        a.isMain == (i == keep) ? a : a.copyWith(isMain: i == keep),
    ];
  }

  /// Makes [id] the main account; the previous one loses the flag.
  void setMainAccount(String id) {
    if (!_accounts.any((a) => a.id == id)) return;
    for (var i = 0; i < _accounts.length; i++) {
      final isMain = _accounts[i].id == id;
      if (_accounts[i].isMain != isMain) {
        _accounts[i] = _accounts[i].copyWith(isMain: isMain);
      }
    }
    notifyListeners();
  }

  /// Initial balance plus all transactions up to today, in the account
  /// currency.
  double accountBalance(String accountId) => accountBalanceAt(accountId, null);

  /// The balance before [before] (the start of that day): the initial balance
  /// plus the transactions dated earlier. Null: all of them.
  double accountBalanceAt(String accountId, DateTime? before) {
    var balance =
        account(accountId).initialBalance +
        (_opening[accountId] ?? 0) +
        _movementCash(accountId, before);
    for (final t in _transactions) {
      if (before != null && !t.date.isBefore(before)) continue;
      if (t.accountId == accountId) {
        balance += t.type == TransactionType.income ? t.amount : -t.amount;
      }
      if (t.toAccountId == accountId) balance += t.toAmount ?? t.amount;
    }
    return round2(balance);
  }

  /// Every account with its balance and how it changed this month (today's
  /// balance minus the balance at the start of the 1st), in the account's
  /// own currency.
  List<AccountChange> accountsWithChange() {
    final monthStart = DateTime(today.year, today.month);
    return List.unmodifiable([
      for (final a in _accounts)
        AccountChange(
          account: a,
          balance: accountBalance(a.id),
          change: round2(
            accountBalance(a.id) - accountBalanceAt(a.id, monthStart),
          ),
        ),
    ]);
  }

  /// Sum of all account balances, in the main currency.
  double get totalBalance => round2(
    _accounts.fold(
      0.0,
      (sum, a) => sum + toMain(accountBalance(a.id), a.currency),
    ),
  );

  /// Whether another account already has [name] (capitals and the spaces
  /// around it do not count). [excluding] is the account being edited.
  bool accountNameTaken(String name, {String? excluding}) {
    final wanted = name.trim().toLowerCase();
    return _accounts.any(
      (a) => a.id != excluding && a.name.trim().toLowerCase() == wanted,
    );
  }

  /// Whether something refers to the account: transactions (either side of
  /// a transfer), recurrences or movements.
  bool accountInUse(String id) =>
      _transactions.any((t) => t.accountId == id || t.toAccountId == id) ||
      _recurring.any((r) => r.accountId == id || r.toAccountId == id) ||
      _movements.any((m) => m.accountId == id);

  AccountFailure? _checkAccount(AccountDraft d, {String? excluding}) {
    if (d.name.trim().isEmpty) return AccountFailure.invalidName;
    if (accountNameTaken(d.name, excluding: excluding)) {
      return AccountFailure.duplicateName;
    }
    if (!d.initialBalance.isFinite) return AccountFailure.invalidAmount;
    if (!supportedCurrencies.contains(d.currency)) {
      return AccountFailure.invalidCurrency;
    }
    return null;
  }

  /// Creates an account (the name is unique, capitals aside) and tells the
  /// listeners. The balance may be zero or negative.
  AccountResult addAccount(AccountDraft draft) {
    final failure = _checkAccount(draft);
    if (failure != null) return AccountResult.failed(failure);
    final account = Account(
      id: 'acc_new_${_accountSeq++}',
      name: draft.name.trim(),
      type: draft.type,
      initialBalance: round2(draft.initialBalance),
      currency: draft.currency,
      color: draft.color,
      icon: draft.icon,
      isMain: _accounts.isEmpty || draft.isMain,
    );
    if (account.isMain) {
      for (var i = 0; i < _accounts.length; i++) {
        _accounts[i] = _accounts[i].copyWith(isMain: false);
      }
    }
    _accounts.add(account);
    notifyListeners();
    return AccountResult.ok(account);
  }

  /// Changes name, balance, currency, color and icon of an account. The
  /// currency of an account in use cannot change: its amounts would mean
  /// something else.
  AccountResult updateAccount(String id, AccountDraft draft) {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index < 0) return const AccountResult.failed(AccountFailure.notFound);
    final failure = _checkAccount(draft, excluding: id);
    if (failure != null) return AccountResult.failed(failure);
    final current = _accounts[index];
    if (draft.currency != current.currency && accountInUse(id)) {
      return const AccountResult.failed(AccountFailure.inUse);
    }
    final account = current.copyWith(
      name: draft.name.trim(),
      initialBalance: round2(draft.initialBalance),
      currency: draft.currency,
      color: draft.color,
      icon: draft.icon,
      // The main account stays main until another is chosen.
      isMain: current.isMain || draft.isMain,
    );
    if (account.isMain && !current.isMain) {
      for (var i = 0; i < _accounts.length; i++) {
        _accounts[i] = _accounts[i].copyWith(isMain: false);
      }
    }
    _accounts[index] = account;
    notifyListeners();
    return AccountResult.ok(account);
  }

  /// Deletes an account nothing refers to.
  AccountResult deleteAccount(String id) {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index < 0) return const AccountResult.failed(AccountFailure.notFound);
    if (accountInUse(id)) {
      return const AccountResult.failed(AccountFailure.inUse);
    }
    final account = _accounts.removeAt(index);
    _opening.remove(id);
    // The first account left takes the place of the main one.
    if (account.isMain && _accounts.isNotEmpty) {
      _accounts[0] = _accounts[0].copyWith(isMain: true);
    }
    notifyListeners();
    return AccountResult.ok(account);
  }

  // Adding transactions

  /// [amount] of [from] converted into [to] with the mock rates (rounded to
  /// cents): what a transfer between two currencies proposes as received.
  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    final eur = toEur(amount, from);
    return round2(to == 'EUR' ? eur : eur / toEur(1, to));
  }

  /// Checks a draft and returns what is wrong with it, or null.
  TransactionFailure? _checkTransaction(TransactionDraft d) {
    if (!d.amount.isFinite || d.amount <= 0) {
      return TransactionFailure.invalidAmount;
    }
    if (!_accounts.any((a) => a.id == d.accountId)) {
      return TransactionFailure.accountNotFound;
    }
    final recurrence = d.recurrence;
    if (recurrence == null && dateOnly(d.date).isAfter(today)) {
      return TransactionFailure.futureDate;
    }
    if (d.type == TransactionType.transfer) {
      final to = d.toAccountId;
      if (to == null || !_accounts.any((a) => a.id == to)) {
        return TransactionFailure.accountNotFound;
      }
      if (to == d.accountId) return TransactionFailure.sameAccount;
      if (d.toAmount != null && (!d.toAmount!.isFinite || d.toAmount! <= 0)) {
        return TransactionFailure.invalidAmount;
      }
    } else {
      final category = _categories
          .where((c) => c.id == d.categoryId)
          .firstOrNull;
      final wanted = d.type == TransactionType.expense
          ? CategoryType.expense
          : CategoryType.income;
      if (category == null || category.type != wanted) {
        return TransactionFailure.invalidCategory;
      }
      if (d.subcategoryId != null &&
          !_subcategories.any(
            (s) => s.id == d.subcategoryId && s.categoryId == category.id,
          )) {
        return TransactionFailure.invalidCategory;
      }
    }
    if (recurrence != null) {
      final start = dateOnly(recurrence.startDate);
      switch (recurrence.end) {
        case RecurrenceEnd.never:
          break;
        case RecurrenceEnd.onDate:
          if (recurrence.endDate == null ||
              dateOnly(recurrence.endDate!).isBefore(start)) {
            return TransactionFailure.invalidEnd;
          }
        case RecurrenceEnd.afterCount:
          if (recurrence.count == null || recurrence.count! < 1) {
            return TransactionFailure.invalidEnd;
          }
      }
    }
    return null;
  }

  /// Adds an expense, an income or a transfer. The amount is positive and in
  /// the currency of the account; a transfer between two currencies carries
  /// what arrives (the converted amount when the draft has none). With a
  /// [TransactionDraft.recurrence] it also creates the recurring transaction:
  /// when it starts today or before, the first transaction too (dated at the
  /// start); when it starts later, only the planned recurrence. Everything
  /// that reads the data (balances, lists, charts, budgets, digest) follows,
  /// because the listeners are notified once.
  TransactionResult addTransaction(TransactionDraft d) {
    final failure = _checkTransaction(d);
    if (failure != null) return TransactionResult.failed(failure);
    final account = this.account(d.accountId);
    final isTransfer = d.type == TransactionType.transfer;
    final amount = round2(d.amount);
    double? toAmount;
    if (isTransfer) {
      final to = this.account(d.toAccountId!);
      if (to.currency != account.currency) {
        toAmount = round2(
          d.toAmount ?? convert(amount, account.currency, to.currency),
        );
      }
    }
    final description = d.description.trim();
    final recurrence = d.recurrence;
    String? recurringId;
    var date = dateOnly(d.date);
    String? transactionId;
    if (recurrence != null) {
      final start = dateOnly(recurrence.startDate);
      final first = !start.isAfter(today);
      recurringId = 'rec_new_${_recurringSeq++}';
      final next = first
          ? _firstAfterToday(recurrence.frequency, start)
          : start;
      DateTime? end = switch (recurrence.end) {
        RecurrenceEnd.never => null,
        RecurrenceEnd.onDate => dateOnly(recurrence.endDate!),
        RecurrenceEnd.afterCount => recurrence.frequency.step(
          start,
          recurrence.count! - 1,
        ),
      };
      _recurring.add(
        RecurringTransaction(
          id: recurringId,
          type: d.type,
          amount: amount,
          currency: account.currency,
          description: description.isNotEmpty
              ? description
              : _recurringTitle(d),
          frequency: recurrence.frequency,
          nextDate: next,
          anchorDay: start.day,
          status: RecurringStatus.active,
          accountId: d.accountId,
          toAccountId: isTransfer ? d.toAccountId : null,
          categoryId: isTransfer ? null : d.categoryId,
          subcategoryId: isTransfer ? null : d.subcategoryId,
          endDate: end,
        ),
      );
      date = start;
      if (first) {
        transactionId = _insertTransaction(
          d,
          date,
          amount,
          toAmount,
          recurringId,
        );
      }
    } else {
      transactionId = _insertTransaction(d, date, amount, toAmount, null);
    }
    notifyListeners();
    return TransactionResult.ok(
      AddedTransaction(transactionId: transactionId, recurringId: recurringId),
    );
  }

  DateTime _firstAfterToday(RecurrenceFrequency f, DateTime start) {
    var next = start;
    for (var k = 1; !next.isAfter(today); k++) {
      next = f.step(start, k);
    }
    return next;
  }

  /// A title for a recurrence with no description: the category, or the two
  /// accounts of a transfer.
  String _recurringTitle(TransactionDraft d) {
    if (d.type == TransactionType.transfer) {
      return '${account(d.accountId).name} → ${account(d.toAccountId!).name}';
    }
    return category(d.categoryId!).name;
  }

  String _insertTransaction(
    TransactionDraft d,
    DateTime date,
    double amount,
    double? toAmount,
    String? recurringId,
  ) {
    final isTransfer = d.type == TransactionType.transfer;
    final id = 'tx_new_${_transactionSeq++}';
    final transaction = Transaction(
      id: id,
      type: d.type,
      amount: amount,
      currency: account(d.accountId).currency,
      date: date,
      description: d.description.trim(),
      accountId: d.accountId,
      toAccountId: isTransfer ? d.toAccountId : null,
      categoryId: isTransfer ? null : d.categoryId,
      subcategoryId: isTransfer ? null : d.subcategoryId,
      recurringId: recurringId,
      toAmount: toAmount,
    );
    // The list stays in date order; on the same day the new one is the last.
    var at = _transactions.length;
    while (at > 0 && _transactions[at - 1].date.isAfter(date)) {
      at--;
    }
    _transactions.insert(at, transaction);
    return id;
  }

  /// Takes back what [addTransaction] created: the transaction and the
  /// recurring transaction, if any. Listeners are notified once.
  void undoAdded(AddedTransaction added) {
    _transactions.removeWhere((t) => t.id == added.transactionId);
    _recurring.removeWhere((r) => r.id == added.recurringId);
    notifyListeners();
  }

  /// Deletes one transaction. Returns whether it existed.
  bool deleteTransaction(String id) {
    final before = _transactions.length;
    _transactions.removeWhere((t) => t.id == id);
    if (_transactions.length == before) return false;
    notifyListeners();
    return true;
  }

  // Suggestions for the form of a transaction

  /// The categories of [type] by how much they were used in the last 90
  /// days (the transactions of that type, most used first); the ones used
  /// the same, or not at all (a new user), in the order they were created.
  List<Category> categoriesByUsage(CategoryType type) {
    final since = addDays(today, -90);
    final wanted = type == CategoryType.expense
        ? TransactionType.expense
        : TransactionType.income;
    final uses = <String, int>{};
    for (final t in _transactions) {
      if (t.type != wanted || t.categoryId == null) continue;
      if (dateOnly(t.date).isBefore(since)) continue;
      uses[t.categoryId!] = (uses[t.categoryId!] ?? 0) + 1;
    }
    final list = _categories.where((c) => c.type == type).toList();
    final order = {for (final (i, c) in list.indexed) c.id: i};
    list.sort((a, b) {
      final byUse = (uses[b.id] ?? 0).compareTo(uses[a.id] ?? 0);
      return byUse != 0 ? byUse : order[a.id]!.compareTo(order[b.id]!);
    });
    return List.unmodifiable(list);
  }

  static String _normalize(String text) =>
      text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// The category of the past transactions of [type] with the same
  /// description (capitals and extra spaces aside): the most frequent one,
  /// the most recent on a tie, with the subcategory most often used in it.
  /// Null when the description is empty or never used.
  CategorySuggestion? suggestCategory(String description, CategoryType type) {
    final wanted = _normalize(description);
    if (wanted.isEmpty) return null;
    final txType = type == CategoryType.expense
        ? TransactionType.expense
        : TransactionType.income;
    final counts = <String, int>{};
    final last = <String, int>{};
    final subs = <String, Map<String, int>>{};
    for (final (i, t) in _transactions.indexed) {
      if (t.type != txType || t.categoryId == null) continue;
      if (_normalize(t.description) != wanted) continue;
      counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1;
      last[t.categoryId!] = i;
      if (t.subcategoryId != null) {
        final m = subs.putIfAbsent(t.categoryId!, () => {});
        m[t.subcategoryId!] = (m[t.subcategoryId!] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    final best = counts.keys.reduce((a, b) {
      final c = counts[a]!.compareTo(counts[b]!);
      if (c != 0) return c > 0 ? a : b;
      return last[a]! > last[b]! ? a : b;
    });
    final subCounts = subs[best];
    String? sub;
    if (subCounts != null) {
      sub = subCounts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    }
    return CategorySuggestion(best, sub);
  }

  /// Past descriptions of expenses or income (not transfers) that start with
  /// or contain [query] (capitals aside), most used first, at most [limit].
  /// The description typed in full is not proposed again.
  List<String> pastDescriptions(String query, {int limit = 3}) {
    final q = _normalize(query);
    if (q.isEmpty) return const [];
    final counts = <String, int>{};
    final shown = <String, String>{};
    for (final t in _transactions) {
      if (t.type == TransactionType.transfer) continue;
      final n = _normalize(t.description);
      if (n.isEmpty || n == q || !n.contains(q)) continue;
      counts[n] = (counts[n] ?? 0) + 1;
      shown[n] = t.description.trim().replaceAll(RegExp(r'\s+'), ' ');
    }
    final keys = counts.keys.toList()
      ..sort((a, b) {
        final starts = (b.startsWith(q) ? 1 : 0) - (a.startsWith(q) ? 1 : 0);
        if (starts != 0) return starts;
        final c = counts[b]!.compareTo(counts[a]!);
        return c != 0 ? c : a.compareTo(b);
      });
    return [for (final k in keys.take(limit)) shown[k]!];
  }

  // Categories

  List<Category> categories({CategoryType? type}) => List.unmodifiable(
    _categories.where((c) => type == null || c.type == type),
  );

  Category category(String id) => _categories.firstWhere((c) => c.id == id);

  List<Subcategory> subcategoriesOf(String categoryId) => List.unmodifiable(
    _subcategories.where((s) => s.categoryId == categoryId),
  );

  Subcategory subcategory(String id) =>
      _subcategories.firstWhere((s) => s.id == id);

  /// The parent category, which holds icon and color of the subcategory.
  Category parentOf(Subcategory subcategory) =>
      category(subcategory.categoryId);

  /// Whether another category of [type] already has [name] (capitals and the
  /// spaces around it do not count). [excluding] is the category being edited.
  bool categoryNameTaken(String name, CategoryType type, {String? excluding}) {
    final wanted = name.trim().toLowerCase();
    return _categories.any(
      (c) =>
          c.id != excluding &&
          c.type == type &&
          c.name.trim().toLowerCase() == wanted,
    );
  }

  /// Whether another subcategory of [categoryId] already has [name].
  /// [excluding] is the subcategory being edited.
  bool subcategoryNameTaken(
    String categoryId,
    String name, {
    String? excluding,
  }) {
    final wanted = name.trim().toLowerCase();
    return _subcategories.any(
      (s) =>
          s.id != excluding &&
          s.categoryId == categoryId &&
          s.name.trim().toLowerCase() == wanted,
    );
  }

  /// Whether the category already has a budget on [period]. [excluding] is
  /// the budget being edited.
  bool budgetPeriodTaken(
    String categoryId,
    BudgetPeriod period, {
    String? excluding,
  }) => _budgets.any(
    (b) =>
        b.id != excluding && b.categoryId == categoryId && b.period == period,
  );

  /// Whether transactions or recurrences refer to the category, or to one of
  /// its subcategories.
  bool categoryInUse(String id) {
    final subs = {
      for (final s in _subcategories)
        if (s.categoryId == id) s.id,
    };
    return _transactions.any(
          (t) =>
              t.categoryId == id ||
              (t.subcategoryId != null && subs.contains(t.subcategoryId)),
        ) ||
        _recurring.any(
          (r) =>
              r.categoryId == id ||
              (r.subcategoryId != null && subs.contains(r.subcategoryId)),
        );
  }

  bool subcategoryInUse(String id) =>
      _transactions.any((t) => t.subcategoryId == id) ||
      _recurring.any((r) => r.subcategoryId == id);

  /// Creates a category with its subcategories and budgets, all or nothing.
  CategoryResult addCategory(CategorySave save) => _saveCategory(save);

  /// Changes a category and replaces its subcategories and budgets by the
  /// ones in [save] (the ones left out are deleted), all or nothing. The
  /// type of a category in use cannot change; a category that becomes income
  /// must have no budgets in [save].
  CategoryResult updateCategory(String id, CategorySave save) =>
      _saveCategory(save, id: id);

  CategoryResult _saveCategory(CategorySave save, {String? id}) {
    final categories = List.of(_categories);
    final subcategories = List.of(_subcategories);
    final budgets = List.of(_budgets);
    final categorySeq = _categorySeq;
    final subcategorySeq = _subcategorySeq;
    final budgetSeq = _budgetSeq;
    final result = _applyCategorySave(save, id);
    if (!result.ok) {
      _categories
        ..clear()
        ..addAll(categories);
      _subcategories
        ..clear()
        ..addAll(subcategories);
      _budgets
        ..clear()
        ..addAll(budgets);
      _categorySeq = categorySeq;
      _subcategorySeq = subcategorySeq;
      _budgetSeq = budgetSeq;
      return result;
    }
    notifyListeners();
    return result;
  }

  CategoryResult _applyCategorySave(CategorySave save, String? id) {
    CategoryResult fail(CategoryFailure f) => CategoryResult.failed(f);
    final d = save.category;
    if (d.name.trim().isEmpty) return fail(CategoryFailure.invalidName);
    if (categoryNameTaken(d.name, d.type, excluding: id)) {
      return fail(CategoryFailure.duplicateName);
    }
    final Category category;
    if (id == null) {
      category = Category(
        id: 'cat_new_${_categorySeq++}',
        type: d.type,
        name: d.name.trim(),
        icon: d.icon,
        color: d.color,
      );
      _categories.add(category);
    } else {
      final index = _categories.indexWhere((c) => c.id == id);
      if (index < 0) return fail(CategoryFailure.notFound);
      final current = _categories[index];
      if (current.type != d.type && categoryInUse(id)) {
        return fail(CategoryFailure.inUse);
      }
      category = current.copyWith(
        type: d.type,
        name: d.name.trim(),
        icon: d.icon,
        color: d.color,
      );
      _categories[index] = category;
    }

    // Subcategories: the ones listed stay (renamed or new), the others go.
    final names = <String>{};
    for (final s in save.subcategories) {
      if (s.name.trim().isEmpty) return fail(CategoryFailure.invalidName);
      if (!names.add(s.name.trim().toLowerCase())) {
        return fail(CategoryFailure.duplicateName);
      }
    }
    final keptSubs = {
      for (final s in save.subcategories)
        if (s.id != null) s.id,
    };
    for (final s in _subcategories.where(
      (s) => s.categoryId == category.id && !keptSubs.contains(s.id),
    )) {
      if (subcategoryInUse(s.id)) return fail(CategoryFailure.inUse);
    }
    _subcategories.removeWhere(
      (s) => s.categoryId == category.id && !keptSubs.contains(s.id),
    );
    for (final s in save.subcategories) {
      if (s.id == null) {
        _subcategories.add(
          Subcategory(
            id: 'sub_new_${_subcategorySeq++}',
            categoryId: category.id,
            name: s.name.trim(),
          ),
        );
      } else {
        final i = _subcategories.indexWhere(
          (x) => x.id == s.id && x.categoryId == category.id,
        );
        if (i < 0) return fail(CategoryFailure.notFound);
        _subcategories[i] = Subcategory(
          id: s.id!,
          categoryId: category.id,
          name: s.name.trim(),
        );
      }
    }

    // Budgets: only on expense categories, one per period.
    if (category.type == CategoryType.income && save.budgets.isNotEmpty) {
      return fail(CategoryFailure.budgetOnIncome);
    }
    final periods = <BudgetPeriod>{};
    for (final b in save.budgets) {
      if (!b.amount.isFinite || b.amount <= 0) {
        return fail(CategoryFailure.invalidAmount);
      }
      if (!periods.add(b.period)) return fail(CategoryFailure.duplicatePeriod);
    }
    final keptBudgets = {
      for (final b in save.budgets)
        if (b.id != null) b.id,
    };
    _budgets.removeWhere(
      (b) => b.categoryId == category.id && !keptBudgets.contains(b.id),
    );
    for (final b in save.budgets) {
      if (b.id == null) {
        _budgets.add(
          Budget(
            id: 'bud_new_${_budgetSeq++}',
            categoryId: category.id,
            amount: round2(b.amount),
            currency: mainCurrency,
            period: b.period,
            limitAlert: b.limitAlert,
            countForOverall: b.countForOverall,
          ),
        );
      } else {
        final i = _budgets.indexWhere(
          (x) => x.id == b.id && x.categoryId == category.id,
        );
        if (i < 0) return fail(CategoryFailure.notFound);
        _budgets[i] = _budgets[i].copyWith(
          amount: round2(fromMain(b.amount, _budgets[i].currency)),
          period: b.period,
          limitAlert: b.limitAlert,
          countForOverall: b.countForOverall,
        );
      }
    }
    return CategoryResult.ok(category);
  }

  /// Deletes a category nothing refers to, with its subcategories and
  /// budgets.
  CategoryResult deleteCategory(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    if (categoryInUse(id)) {
      return const CategoryResult.failed(CategoryFailure.inUse);
    }
    final category = _categories.removeAt(index);
    _subcategories.removeWhere((s) => s.categoryId == id);
    _budgets.removeWhere((b) => b.categoryId == id);
    notifyListeners();
    return CategoryResult.ok(category);
  }

  /// Adds a subcategory to a category.
  CategoryResult addSubcategory(String categoryId, String name) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    if (name.trim().isEmpty) {
      return const CategoryResult.failed(CategoryFailure.invalidName);
    }
    if (subcategoryNameTaken(categoryId, name)) {
      return const CategoryResult.failed(CategoryFailure.duplicateName);
    }
    _subcategories.add(
      Subcategory(
        id: 'sub_new_${_subcategorySeq++}',
        categoryId: categoryId,
        name: name.trim(),
      ),
    );
    notifyListeners();
    return CategoryResult.ok(_categories[index]);
  }

  /// Renames a subcategory.
  CategoryResult updateSubcategory(String id, String name) {
    final index = _subcategories.indexWhere((s) => s.id == id);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    final current = _subcategories[index];
    if (name.trim().isEmpty) {
      return const CategoryResult.failed(CategoryFailure.invalidName);
    }
    if (subcategoryNameTaken(current.categoryId, name, excluding: id)) {
      return const CategoryResult.failed(CategoryFailure.duplicateName);
    }
    _subcategories[index] = Subcategory(
      id: id,
      categoryId: current.categoryId,
      name: name.trim(),
    );
    notifyListeners();
    return CategoryResult.ok(category(current.categoryId));
  }

  /// Deletes a subcategory nothing refers to.
  CategoryResult deleteSubcategory(String id) {
    final index = _subcategories.indexWhere((s) => s.id == id);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    if (subcategoryInUse(id)) {
      return const CategoryResult.failed(CategoryFailure.inUse);
    }
    final removed = _subcategories.removeAt(index);
    notifyListeners();
    return CategoryResult.ok(category(removed.categoryId));
  }

  /// The categories the onboarding suggests that the user does not have yet
  /// (same name and type, capitals aside), in the order of the suggestions.
  List<SuggestedCategory> suggestedCategoriesLeft() => List.unmodifiable(
    suggestedCategories.where((s) => !categoryNameTaken(s.name, s.type)),
  );

  /// Creates a suggested category (with no subcategories).
  CategoryResult addSuggestedCategory(SuggestedCategory suggested) =>
      addCategory(
        CategorySave(
          category: CategoryDraft(
            type: suggested.type,
            name: suggested.name,
            icon: suggested.icon,
            color: suggested.color,
          ),
        ),
      );

  // Transactions

  /// All transactions, newest first.
  List<Transaction> get transactions =>
      List.unmodifiable(_transactions.reversed);

  /// The [count] most recent transactions (transfers included), newest
  /// first.
  List<Transaction> latestTransactions(int count, {TransactionType? type}) =>
      List.unmodifiable(
        _transactions.reversed
            .where((t) => type == null || t.type == type)
            .take(count),
      );

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

  /// Search, filter and paginate the transaction list. All the logic of the
  /// Finance > Transactions list lives here; the UI only passes [filter]
  /// and [page] (1-based, clamped to the existing pages).
  TransactionPage searchTransactions(
    TransactionFilter filter, {
    int page = 1,
    int pageSize = 20,
  }) {
    final matches = [
      for (final t in _transactions.reversed)
        if (_matchesFilter(t, filter)) t,
    ];
    final pageCount = matches.isEmpty
        ? 1
        : (matches.length + pageSize - 1) ~/ pageSize;
    final current = page.clamp(1, pageCount);
    final items = matches
        .skip((current - 1) * pageSize)
        .take(pageSize)
        .toList();
    final days = {for (final t in items) dateOnly(t.date)};
    final netByDay = <DateTime, double>{};
    for (final t in matches) {
      final day = dateOnly(t.date);
      if (!days.contains(day) || t.type == TransactionType.transfer) continue;
      final sign = t.type == TransactionType.income ? 1 : -1;
      netByDay[day] =
          (netByDay[day] ?? 0) + sign * toMain(t.amount, t.currency);
    }
    return TransactionPage(
      items: List.unmodifiable(items),
      page: current,
      pageSize: pageSize,
      total: matches.length,
      netByDay: {for (final e in netByDay.entries) e.key: round2(e.value)},
    );
  }

  /// Everything the Finance > Transactions > Charts view shows: totals for
  /// the range and for the previous one of the same length, the amount per
  /// top-level category, and the same amounts per week or month.
  /// Transfers are left out, amounts are converted to the main currency and
  /// subcategories count in their parent. [accountIds] and [categoryIds]
  /// are optional multi-select filters (empty = all). A [granularity] that
  /// does not suit the range falls back to its default.
  TransactionBreakdown transactionBreakdown({
    required TransactionTimeRange range,
    required TransactionKind kind,
    Set<String> accountIds = const {},
    Set<String> categoryIds = const {},
    TransactionGranularity? granularity,
  }) {
    final period = range.resolve(today);
    final previous = period.previous;
    final effective =
        granularity != null && period.allowedGranularities.contains(granularity)
        ? granularity
        : period.defaultGranularity;
    final type = kind == TransactionKind.expense
        ? TransactionType.expense
        : TransactionType.income;

    // Money is added up in cents so that the total, the categories and the
    // buckets agree to the cent.
    int cents(Transaction t) => (toMain(t.amount, t.currency) * 100).round();
    bool counts(Transaction t) =>
        t.type == type &&
        t.categoryId != null &&
        (accountIds.isEmpty || accountIds.contains(t.accountId)) &&
        (categoryIds.isEmpty || categoryIds.contains(t.categoryId));

    final inPeriod = [
      for (final t in _transactions)
        if (counts(t) && period.contains(t.date)) t,
    ];
    var previousCents = 0;
    for (final t in _transactions) {
      if (counts(t) && previous.contains(t.date)) previousCents += cents(t);
    }

    final byCategory = <String, int>{};
    for (final t in inPeriod) {
      byCategory[t.categoryId!] = (byCategory[t.categoryId!] ?? 0) + cents(t);
    }
    final categories = [
      for (final e in byCategory.entries)
        if (e.value > 0) CategoryAmount(e.key, e.value / 100),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final bounds = _bucketBounds(period, effective);
    final bucketCents = [for (final _ in bounds) <String, int>{}];
    for (final t in inPeriod) {
      final day = dateOnly(t.date);
      final i = bounds.indexWhere(
        (b) => !day.isBefore(b.start) && !day.isAfter(b.end),
      );
      bucketCents[i][t.categoryId!] =
          (bucketCents[i][t.categoryId!] ?? 0) + cents(t);
    }

    return TransactionBreakdown(
      range: period,
      previousRange: previous,
      kind: kind,
      granularity: effective,
      total: byCategory.values.fold(0, (a, b) => a + b) / 100,
      previousTotal: previousCents / 100,
      categories: categories,
      buckets: [
        for (final (i, b) in bounds.indexed)
          BreakdownBucket(
            start: b.start,
            end: b.end,
            amounts: {
              for (final e in bucketCents[i].entries)
                if (e.value > 0) e.key: e.value / 100,
            },
          ),
      ],
    );
  }

  /// Weeks (Monday to Sunday) or calendar months covering [period], the
  /// first and last one cut to it.
  List<DateRange> _bucketBounds(
    DateRange period,
    TransactionGranularity granularity,
  ) {
    final bounds = <DateRange>[];
    var start = period.start;
    while (!start.isAfter(period.end)) {
      final DateTime naturalEnd = granularity == TransactionGranularity.weekly
          ? DateTime(
              start.year,
              start.month,
              start.day + (DateTime.sunday - start.weekday),
            )
          : DateTime(start.year, start.month + 1, 0);
      final end = naturalEnd.isAfter(period.end) ? period.end : naturalEnd;
      bounds.add(DateRange(start, end));
      start = DateTime(end.year, end.month, end.day + 1);
    }
    return bounds;
  }

  bool _matchesFilter(Transaction t, TransactionFilter f) {
    final day = dateOnly(t.date);
    if (f.from != null && day.isBefore(dateOnly(f.from!))) return false;
    if (f.to != null && day.isAfter(dateOnly(f.to!))) return false;
    if (f.types.isNotEmpty && !f.types.contains(t.type)) return false;
    if (f.categoryIds.isNotEmpty && !f.categoryIds.contains(t.categoryId)) {
      return false;
    }
    if (f.accountIds.isNotEmpty &&
        !f.accountIds.contains(t.accountId) &&
        !f.accountIds.contains(t.toAccountId)) {
      return false;
    }
    if (f.hasAmountRange) {
      final eur = toMain(t.amount, t.currency);
      if (f.minAmount != null && eur < f.minAmount!) return false;
      if (f.maxAmount != null && eur > f.maxAmount!) return false;
    }
    final query = f.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      final fields = [
        t.description,
        account(t.accountId).name,
        if (t.toAccountId != null) account(t.toAccountId!).name,
        if (t.categoryId != null) category(t.categoryId!).name,
        if (t.subcategoryId != null) subcategory(t.subcategoryId!).name,
      ];
      if (!fields.any((v) => v.toLowerCase().contains(query))) return false;
    }
    return true;
  }

  double totalIncome(DateTime start, DateTime end) =>
      _sum(transactionsInPeriod(start, end, type: TransactionType.income));

  double totalExpenses(DateTime start, DateTime end) =>
      _sum(transactionsInPeriod(start, end, type: TransactionType.expense));

  /// Expenses per top-level category in the period, in the main currency.
  Map<String, double> expensesByCategory(DateTime start, DateTime end) {
    final totals = <String, double>{};
    for (final t in transactionsInPeriod(
      start,
      end,
      type: TransactionType.expense,
    )) {
      totals[t.categoryId!] =
          (totals[t.categoryId!] ?? 0) + toMain(t.amount, t.currency);
    }
    return totals.map((k, v) => MapEntry(k, round2(v)));
  }

  /// Income minus expenses in [start, end), in the main currency.
  /// Transfers excluded.
  double netResult(DateTime start, DateTime end) =>
      round2(totalIncome(start, end) - totalExpenses(start, end));

  /// Cumulative net (income minus expenses, main currency) at the end of each day in
  /// [start, end): one value per calendar day, transfers excluded.
  List<double> cumulativeNetByDay(DateTime start, DateTime end) {
    final days = <DateTime>[
      for (
        var d = dateOnly(start);
        d.isBefore(end);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        d,
    ];
    final indexOfDay = {for (final (i, d) in days.indexed) d: i};
    final perDay = List.filled(days.length, 0.0);
    for (final t in transactionsInPeriod(start, end)) {
      if (t.type == TransactionType.transfer) continue;
      final sign = t.type == TransactionType.income ? 1 : -1;
      perDay[indexOfDay[dateOnly(t.date)]!] +=
          sign * toMain(t.amount, t.currency);
    }
    var running = 0.0;
    return [for (final amount in perDay) round2(running += amount)];
  }

  /// Net of the month containing [on] (default today) day by day up to
  /// [on], with the whole previous month for comparison. In the main currency.
  BalanceTrend balanceTrend({DateTime? on}) {
    final day = on == null ? today : dateOnly(on);
    final start = DateTime(day.year, day.month);
    final previousStart = DateTime(day.year, day.month - 1);
    final end = DateTime(day.year, day.month, day.day + 1);
    return BalanceTrend(
      periodStart: start,
      daysInPeriod: daysInMonth(day.year, day.month),
      currency: mainCurrency,
      current: cumulativeNetByDay(
        start,
        DateTime(day.year, day.month, day.day + 1),
      ),
      previous: cumulativeNetByDay(previousStart, start),
      income: totalIncome(start, end),
      expenses: totalExpenses(start, end),
    );
  }

  double _sum(Iterable<Transaction> list) =>
      round2(list.fold(0.0, (sum, t) => sum + toMain(t.amount, t.currency)));

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

  /// Every date of the recurring transactions in a month, by date. Past
  /// ones are the real transactions linked to the recurring one; the rest
  /// are projected from [RecurringTransaction.nextDate] with the frequency
  /// (so quarterly or yearly ones appear only in the months they fall in,
  /// and one on the 31st falls on the last day of shorter months). A paused
  /// recurring transaction has no projected dates, only the past ones.
  /// Same-day dates keep the order of the recurring transactions.
  List<RecurringOccurrence> recurringOccurrences(int year, int month) {
    final first = DateTime(year, month);
    final last = DateTime(year, month + 1, 0);
    final all = <RecurringOccurrence>[
      for (final r in _recurring) ..._occurrencesIn(r, first, last),
    ];
    // Stable sort by date.
    final indexed = all.indexed.toList()
      ..sort((a, b) {
        final c = a.$2.date.compareTo(b.$2.date);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
    return List.unmodifiable([for (final e in indexed) e.$2]);
  }

  /// The kinds of recurring transaction on each day of the month (the key
  /// is the day of the month, 1-based): the dots of the calendar.
  Map<int, Set<TransactionType>> recurringDayTypes(int year, int month) {
    final types = <int, Set<TransactionType>>{};
    for (final o in recurringOccurrences(year, month)) {
      types.putIfAbsent(o.date.day, () => {}).add(o.type);
    }
    return types;
  }

  List<RecurringOccurrence> _occurrencesIn(
    RecurringTransaction r,
    DateTime first,
    DateTime last,
  ) {
    final out = <RecurringOccurrence>[];
    for (final t in _transactions) {
      if (t.recurringId != r.id) continue;
      final d = dateOnly(t.date);
      if (d.isBefore(first) || d.isAfter(last)) continue;
      out.add(
        RecurringOccurrence(
          recurringId: r.id,
          date: d,
          type: t.type,
          amount: t.amount,
          currency: t.currency,
          transactionId: t.id,
        ),
      );
    }
    if (r.status == RecurringStatus.active) {
      // Never before tomorrow: what happened is in the transactions.
      var date = r.nextDate;
      for (var k = 1; !date.isAfter(last); k++) {
        if (r.endDate != null && date.isAfter(r.endDate!)) break;
        if (date.isAfter(today) && !date.isBefore(first)) {
          out.add(
            RecurringOccurrence(
              recurringId: r.id,
              date: date,
              type: r.type,
              amount: r.amount,
              currency: r.currency,
            ),
          );
        }
        date = r.frequency.step(r.nextDate, k, anchorDay: r.anchorDay);
      }
    }
    return out;
  }

  /// The transactions a recurring transaction has generated, newest first,
  /// grouped by year, within [range] (as of today). Each year carries its
  /// total in the main currency.
  List<RecurringYearGroup> recurringHistory(
    String recurringId, {
    RecurringHistoryRange range = RecurringHistoryRange.last6Months,
  }) {
    final months = range.months;
    final from = months == null
        ? null
        : DateTime(today.year, today.month - (months - 1));
    final items =
        _transactions
            .where(
              (t) =>
                  t.recurringId == recurringId &&
                  (from == null || !dateOnly(t.date).isBefore(from)),
            )
            .toList()
          ..sort((a, b) {
            final c = b.date.compareTo(a.date);
            return c != 0 ? c : b.id.compareTo(a.id);
          });
    final byYear = <int, List<Transaction>>{};
    for (final t in items) {
      byYear.putIfAbsent(t.date.year, () => []).add(t);
    }
    return List.unmodifiable([
      for (final e in byYear.entries)
        RecurringYearGroup(
          year: e.key,
          total: round2(
            e.value.fold(0.0, (sum, t) {
              final v = toMain(t.amount, t.currency);
              return sum + (t.type == TransactionType.expense ? -v : v);
            }),
          ),
          transactions: List.unmodifiable(e.value),
        ),
    ]);
  }

  /// Changes a recurring transaction. The change counts for the dates that
  /// have not happened yet: the past transactions stay as they are. The
  /// amount is in the recurring transaction's own currency and has to be a
  /// positive number (ArgumentError otherwise). A new frequency starts from
  /// the next date; turning a paused one back on makes sure that date is
  /// after today. Listeners are notified.
  void updateRecurring(
    String id, {
    double? amount,
    RecurrenceFrequency? frequency,
    RecurringStatus? status,
  }) {
    if (amount != null && (!amount.isFinite || amount <= 0)) {
      throw ArgumentError.value(amount, 'amount', 'must be a positive number');
    }
    final i = _recurring.indexWhere((r) => r.id == id);
    var r = _recurring[i];
    var next = r.nextDate;
    var anchor = r.anchorDay;
    if (frequency != null && frequency != r.frequency) {
      anchor = next.day;
    }
    final newFrequency = frequency ?? r.frequency;
    for (var k = 1; !next.isAfter(today); k++) {
      next = newFrequency.step(r.nextDate, k, anchorDay: anchor);
    }
    r = r.copyWith(
      amount: amount == null ? null : round2(amount),
      frequency: frequency,
      status: status,
      nextDate: next,
      anchorDay: anchor,
    );
    _recurring[i] = r;
    notifyListeners();
  }

  /// Removes a recurring transaction. Its past transactions stay in the
  /// list, no longer linked to it. Listeners are notified.
  void deleteRecurring(String id) {
    _recurring.removeWhere((r) => r.id == id);
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].recurringId == id) {
        _transactions[i] = _transactions[i].withoutRecurring();
      }
    }
    notifyListeners();
  }

  /// The recurring transactions still to come this month (after today),
  /// soonest first, at most [limit]. Same dates as the Recurring tab.
  List<RecurringOccurrence> upcomingRecurrencesThisMonth({int limit = 5}) =>
      upcomingRecurrences(
        limit: limit,
        until: DateTime(today.year, today.month + 1, 0),
      );

  /// The next dates of the active recurring transactions, soonest first, at
  /// most [limit], through [until] (default: a year from today). Same dates
  /// and amounts as the Recurring tab. With [includeToday] an occurrence
  /// dated today counts too, whether it already happened or not; paused
  /// recurring transactions are left out then.
  List<RecurringOccurrence> upcomingRecurrences({
    int limit = 5,
    DateTime? until,
    bool includeToday = false,
    TransactionType? type,
  }) {
    final end = dateOnly(
      until ?? DateTime(today.year + 1, today.month, today.day),
    );
    final out = <RecurringOccurrence>[];
    var month = DateTime(today.year, today.month);
    while (!month.isAfter(end) && out.length < limit) {
      for (final o in recurringOccurrences(month.year, month.month)) {
        if (o.date.isAfter(end)) continue;
        if (type != null && o.type != type) continue;
        final counts =
            o.isPlanned ||
            (includeToday &&
                o.date == today &&
                recurring(o.recurringId).status == RecurringStatus.active);
        if (!counts) continue;
        out.add(o);
        if (out.length == limit) break;
      }
      month = DateTime(month.year, month.month + 1);
    }
    return List.unmodifiable(out);
  }

  // Finance Overview

  /// The month so far, day by day, up to today.
  /// Cumulative income, expenses and balance in the main currency;
  /// transfers excluded. Summed in cents.
  CashFlow cashFlow() {
    final start = DateTime(today.year, today.month);
    final elapsed = today.day;
    final income = List.filled(elapsed, 0);
    final expenses = List.filled(elapsed, 0);
    for (final t in transactionsInPeriod(
      start,
      DateTime(today.year, today.month, today.day + 1),
    )) {
      if (t.type == TransactionType.transfer) continue;
      final cents = (toMain(t.amount, t.currency) * 100).round();
      final i = t.date.day - 1;
      if (t.type == TransactionType.income) {
        income[i] += cents;
      } else {
        expenses[i] += cents;
      }
    }
    final inc = <double>[], exp = <double>[], bal = <double>[];
    var ci = 0, ce = 0;
    for (var i = 0; i < elapsed; i++) {
      ci += income[i];
      ce += expenses[i];
      inc.add(ci / 100);
      exp.add(ce / 100);
      bal.add((ci - ce) / 100);
    }
    return CashFlow(
      periodStart: start,
      daysInPeriod: daysInMonth(today.year, today.month),
      currency: mainCurrency,
      income: inc,
      expenses: exp,
      balance: bal,
    );
  }

  /// The budgets whose current period includes today, as in the Budget tab
  /// (same statuses), by relevance: see [budgetsByRelevance].
  List<BudgetStatus> monthBudgets() => budgetsByRelevance();

  /// Every budget on its own current period, most relevant first: the
  /// exceeded ones (the highest usage first), then the ones at risk (from
  /// 80%) by usage, then all the others by usage; on a tie the shortest
  /// period goes first. [period] keeps only the budgets of that period,
  /// [limit] cuts the list. Feeds the Finance Overview and the Dashboard
  /// "Budget status" widget.
  List<BudgetStatus> budgetsByRelevance({BudgetPeriod? period, int? limit}) {
    int tier(BudgetState s) => switch (s) {
      BudgetState.exceeded => 0,
      BudgetState.warning => 1,
      BudgetState.ok => 2,
    };
    final list = [
      for (final b in _budgets)
        if (period == null || b.period == period) budgetStatus(b),
    ];
    list.sort((a, b) {
      final t = tier(a.state).compareTo(tier(b.state));
      if (t != 0) return t;
      final c = b.usage.compareTo(a.usage);
      if (c != 0) return c;
      final p = a.budget.period.index.compareTo(b.budget.period.index);
      return p != 0 ? p : a.budget.id.compareTo(b.budget.id);
    });
    return List.unmodifiable(limit == null ? list : list.take(limit));
  }

  /// From which day of the month the comparisons of the digest are shown.
  static const int digestFirstComparisonDay = 4;

  /// Digest of the month: at most three messages, by priority (exceeded
  /// budgets, budgets at risk, spending against the average, large
  /// recurrences, a category that grew), or one neutral message when no rule
  /// applies. Each rule is also a method of its own.
  List<DigestMessage> financeDigest() {
    final messages = [
      ...digestExceededBudgets(),
      ...digestBudgetsAtRisk(),
      ?digestSpendingVsAverage(),
      ?digestLargeRecurrences(),
      ?digestCategoryGrowth(),
    ];
    if (messages.isEmpty) {
      return const [
        DigestMessage(rule: DigestRule.allGood, tone: DigestTone.info),
      ];
    }
    return List.unmodifiable(messages.take(3));
  }

  /// Rule a: one message per budget over its limit in its current period,
  /// the biggest overshoot first (error).
  List<DigestMessage> digestExceededBudgets() {
    final exceeded = [
      for (final b in _budgets)
        if (budgetStatus(b) case final s when s.state == BudgetState.exceeded)
          s,
    ]..sort((a, b) => b.overBy.compareTo(a.overBy));
    return [
      for (final s in exceeded)
        DigestMessage(
          rule: DigestRule.budgetExceeded,
          tone: DigestTone.error,
          categoryId: s.budget.categoryId,
          amount: s.overBy,
        ),
    ];
  }

  /// Rule b: budgets from 80% to the limit with more than 3 days left in
  /// their period, the most used first (warning).
  List<DigestMessage> digestBudgetsAtRisk() {
    final entries = <(BudgetStatus, int)>[];
    for (final b in _budgets) {
      final s = budgetStatus(b);
      if (s.state != BudgetState.warning) continue;
      final left = DateTime.utc(
        s.periodEnd.year,
        s.periodEnd.month,
        s.periodEnd.day,
      ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
      if (left > 3) entries.add((s, left));
    }
    entries.sort((a, b) => b.$1.usage.compareTo(a.$1.usage));
    return [
      for (final (s, left) in entries)
        DigestMessage(
          rule: DigestRule.budgetAtRisk,
          tone: DigestTone.warning,
          categoryId: s.budget.categoryId,
          percent: s.usage,
          days: left,
        ),
    ];
  }

  /// Expenses in the first [days] days of the month starting at [start],
  /// cut to the length of that month; in cents.
  int _expenseCents(DateTime start, int days) {
    final length = days < daysInMonth(start.year, start.month)
        ? days
        : daysInMonth(start.year, start.month);
    var cents = 0;
    for (final t in transactionsInPeriod(
      start,
      DateTime(start.year, start.month, start.day + length),
      type: TransactionType.expense,
    )) {
      cents += (toMain(t.amount, t.currency) * 100).round();
    }
    return cents;
  }

  /// Rule c: spending of the month so far against the average of the same
  /// days of the last three months. At least 10% under: success; at least
  /// 10% over: warning; else none. Not shown in the first 3 days, nor when
  /// there is nothing to compare with.
  DigestMessage? digestSpendingVsAverage() {
    if (today.day < digestFirstComparisonDay) return null;
    final current = _expenseCents(DateTime(today.year, today.month), today.day);
    var total = 0;
    for (var k = 1; k <= 3; k++) {
      total += _expenseCents(DateTime(today.year, today.month - k), today.day);
    }
    final average = total / 3;
    if (average <= 0) return null;
    final ratio = (current - average) / average;
    // Compared in cents so a limit case is not lost to rounding.
    if (ratio.abs() < 0.1 - 1e-9) return null;
    return DigestMessage(
      rule: DigestRule.spendingVsAverage,
      tone: ratio < 0 ? DigestTone.success : DigestTone.warning,
      amount: round2((current - average).abs() / 100),
      isBelow: ratio < 0,
    );
  }

  /// Rule d: expense recurrences above [threshold] (main currency) in the
  /// next [days] days, as one message with their number and total (info).
  DigestMessage? digestLargeRecurrences({
    double threshold = 100,
    int days = 7,
  }) {
    final limit = DateTime(today.year, today.month, today.day + days);
    final found = <(RecurringOccurrence, double)>[];
    for (final month in {
      DateTime(today.year, today.month),
      DateTime(limit.year, limit.month),
    }) {
      for (final o in recurringOccurrences(month.year, month.month)) {
        if (!o.isPlanned || o.date.isAfter(limit)) continue;
        if (o.type != TransactionType.expense) continue;
        final value = toMain(o.amount, o.currency);
        if (value > threshold) found.add((o, value));
      }
    }
    if (found.isEmpty) return null;
    return DigestMessage(
      rule: DigestRule.largeRecurrences,
      tone: DigestTone.info,
      count: found.length,
      amount: round2(found.fold(0.0, (sum, e) => sum + e.$2)),
      days: days,
      description: found.length == 1
          ? recurring(found.single.$1.recurringId).description
          : null,
    );
  }

  /// Rule e: the category whose spending so far is more than 50% above the
  /// same days of last month (the biggest increase wins), when it is at
  /// least [minimum] (main currency) and last month had some. Not shown in
  /// the first 3 days (warning).
  DigestMessage? digestCategoryGrowth({double minimum = 30}) {
    if (today.day < digestFirstComparisonDay) return null;
    final previousStart = DateTime(today.year, today.month - 1);
    final window =
        today.day < daysInMonth(previousStart.year, previousStart.month)
        ? today.day
        : daysInMonth(previousStart.year, previousStart.month);
    final current = expensesByCategory(
      DateTime(today.year, today.month),
      DateTime(today.year, today.month, today.day + 1),
    );
    final previous = expensesByCategory(
      previousStart,
      DateTime(
        previousStart.year,
        previousStart.month,
        previousStart.day + window,
      ),
    );
    String? best;
    var bestIncrease = 0.0;
    for (final e in current.entries) {
      final before = previous[e.key] ?? 0;
      if (before <= 0 || e.value < minimum || e.value <= before * 1.5) continue;
      if (e.value - before > bestIncrease) {
        best = e.key;
        bestIncrease = e.value - before;
      }
    }
    if (best == null) return null;
    final before = previous[best]!;
    return DigestMessage(
      rule: DigestRule.categoryGrowth,
      tone: DigestTone.warning,
      categoryId: best,
      percent: (current[best]! - before) / before,
      amount: round2(bestIncrease),
    );
  }

  // Budgets

  List<Budget> get budgets => List.unmodifiable(_budgets);

  Budget budget(String id) => _budgets.firstWhere((b) => b.id == id);

  /// The budgets of a category (one per period), shortest period first.
  List<Budget> budgetsForCategory(String categoryId) => List.unmodifiable(
    _budgets.where((b) => b.categoryId == categoryId).toList()
      ..sort((a, b) => a.period.index.compareTo(b.period.index)),
  );

  /// Spending against [budget] in its period containing [on] (default
  /// today): only expenses of the category (its subcategories' expenses
  /// carry the parent category), converted to the main currency.
  /// With [amountInMain] the limit is that one (in the main currency)
  /// instead of the stored one: a preview of an edit, nothing is saved.
  BudgetStatus budgetStatus(
    Budget budget, {
    DateTime? on,
    double? amountInMain,
  }) {
    final range = budget.period.rangeContaining(on ?? today);
    var cents = 0;
    for (final t in transactionsInPeriod(
      range.start,
      range.end,
      categoryId: budget.categoryId,
      type: TransactionType.expense,
    )) {
      cents += (toMain(t.amount, t.currency) * 100).round();
    }
    return BudgetStatus(
      budget: budget,
      amount: amountInMain != null
          ? round2(amountInMain)
          : round2(toMain(budget.amount, budget.currency)),
      spent: cents / 100,
      currency: mainCurrency,
      periodStart: range.start,
      periodEnd: range.end,
    );
  }

  List<BudgetStatus> budgetStatuses({DateTime? on}) =>
      List.unmodifiable(_budgets.map((b) => budgetStatus(b, on: on)));

  /// The Budget tab for [period]: the budgets on that period, each over its
  /// own current period, with the totals and the parts of the segmented bar
  /// (the spending of each budget over the whole bar, which is the total).
  BudgetOverview budgetOverview(BudgetPeriod period, {DateTime? on}) {
    final items = [
      for (final b in _budgets)
        if (b.period == period) budgetStatus(b, on: on),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    final total = round2(items.fold(0.0, (sum, s) => sum + s.amount));
    final spent = round2(items.fold(0.0, (sum, s) => sum + s.spent));
    final counted = items.where((s) => s.budget.countForOverall).toList();
    return BudgetOverview(
      period: period,
      currency: mainCurrency,
      items: List.unmodifiable(items),
      total: total,
      spent: spent,
      overallCount: counted.length,
      overallTotal: round2(counted.fold(0.0, (sum, s) => sum + s.amount)),
      overallSpent: round2(counted.fold(0.0, (sum, s) => sum + s.spent)),
      segments: [
        for (final s in items)
          if (s.spent > 0)
            BudgetSegment(
              budgetId: s.budget.id,
              categoryId: s.budget.categoryId,
              // The whole bar is the total budget; when the total is
              // exceeded the bar is full and the parts share it.
              share: s.spent / (spent > total ? spent : total),
              exceeded: s.state == BudgetState.exceeded,
            ),
      ],
    );
  }

  /// The filter that selects the expenses counted by [budgetId] in its
  /// current period: that category, expenses only, from the first to the
  /// last day of the period. Add search, accounts or amounts with the
  /// filter's own methods and read it with [searchTransactions].
  TransactionFilter budgetTransactionFilter(String budgetId, {DateTime? on}) {
    final b = budget(budgetId);
    final range = b.period.rangeContaining(on ?? today);
    return TransactionFilter(
      from: range.start,
      to: DateTime(range.end.year, range.end.month, range.end.day - 1),
      types: const {TransactionType.expense},
      categoryIds: {b.categoryId},
    );
  }

  /// The day the spending of [budgetId] went over its limit in its period
  /// containing [on] (default today): the date of the expense that took the
  /// running total past the limit (same cents arithmetic as [budgetStatus],
  /// same-day expenses in insertion order). Null when the budget is not
  /// exceeded in that period.
  DateTime? budgetExceededOn(String budgetId, {DateTime? on}) {
    final b = budget(budgetId);
    final status = budgetStatus(b, on: on);
    if (status.state != BudgetState.exceeded) return null;
    final limit = (status.amount * 100).round();
    var running = 0;
    for (final t in _transactions) {
      if (t.type != TransactionType.expense || t.categoryId != b.categoryId) {
        continue;
      }
      if (t.date.isBefore(status.periodStart) ||
          !t.date.isBefore(status.periodEnd)) {
        continue;
      }
      running += (toMain(t.amount, t.currency) * 100).round();
      if (running > limit) return dateOnly(t.date);
    }
    return null;
  }

  /// How many expenses a category had from [from] (included) to [to]
  /// (excluded) and their average, in the main currency. Transfers and
  /// income do not count. Feeds the "unusual expense" insight.
  ({int count, double average}) categoryExpenseStats(
    String categoryId, {
    required DateTime from,
    required DateTime to,
  }) {
    var count = 0;
    var cents = 0;
    for (final t in transactionsInPeriod(
      from,
      to,
      categoryId: categoryId,
      type: TransactionType.expense,
    )) {
      count++;
      cents += (toMain(t.amount, t.currency) * 100).round();
    }
    return (count: count, average: count == 0 ? 0 : cents / 100 / count);
  }

  /// The date of the newest transaction of any type, or null when the user
  /// has none yet.
  DateTime? get lastTransactionDate {
    DateTime? last;
    for (final t in _transactions) {
      final d = dateOnly(t.date);
      if (last == null || d.isAfter(last)) last = d;
    }
    return last;
  }

  /// Sets the limit of a budget, given in the main currency (as the user
  /// sees it); it is stored in the budget's own currency. Throws for an
  /// amount that is not a positive number. Listeners are notified.
  void updateBudgetAmount(String budgetId, double amountInMainCurrency) {
    if (!amountInMainCurrency.isFinite || amountInMainCurrency <= 0) {
      throw ArgumentError.value(
        amountInMainCurrency,
        'amountInMainCurrency',
        'must be a positive number',
      );
    }
    final i = _budgets.indexWhere((b) => b.id == budgetId);
    final b = _budgets[i];
    _budgets[i] = b.withAmount(
      round2(fromMain(amountInMainCurrency, b.currency)),
    );
    notifyListeners();
  }

  /// Adds a budget to an expense category: one per period, an amount above
  /// zero (in the main currency, where the budget is stored).
  CategoryResult addBudget(String categoryId, BudgetDraft draft) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    final category = _categories[index];
    if (category.type != CategoryType.expense) {
      return const CategoryResult.failed(CategoryFailure.budgetOnIncome);
    }
    if (!draft.amount.isFinite || draft.amount <= 0) {
      return const CategoryResult.failed(CategoryFailure.invalidAmount);
    }
    if (budgetPeriodTaken(categoryId, draft.period)) {
      return const CategoryResult.failed(CategoryFailure.duplicatePeriod);
    }
    _budgets.add(
      Budget(
        id: 'bud_new_${_budgetSeq++}',
        categoryId: categoryId,
        amount: round2(draft.amount),
        currency: mainCurrency,
        period: draft.period,
        limitAlert: draft.limitAlert,
        countForOverall: draft.countForOverall,
      ),
    );
    notifyListeners();
    return CategoryResult.ok(category);
  }

  /// Changes period, amount (in the main currency) and flags of a budget.
  CategoryResult updateBudget(String budgetId, BudgetDraft draft) {
    final index = _budgets.indexWhere((b) => b.id == budgetId);
    if (index < 0) return const CategoryResult.failed(CategoryFailure.notFound);
    final current = _budgets[index];
    if (!draft.amount.isFinite || draft.amount <= 0) {
      return const CategoryResult.failed(CategoryFailure.invalidAmount);
    }
    if (budgetPeriodTaken(
      current.categoryId,
      draft.period,
      excluding: budgetId,
    )) {
      return const CategoryResult.failed(CategoryFailure.duplicatePeriod);
    }
    _budgets[index] = current.copyWith(
      amount: round2(fromMain(draft.amount, current.currency)),
      period: draft.period,
      limitAlert: draft.limitAlert,
      countForOverall: draft.countForOverall,
    );
    notifyListeners();
    return CategoryResult.ok(category(current.categoryId));
  }

  /// Removes a budget. Listeners are notified.
  void deleteBudget(String budgetId) {
    _budgets.removeWhere((b) => b.id == budgetId);
    notifyListeners();
  }

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

  /// Daily prices of the last five years, oldest first, in the asset
  /// currency.
  List<PricePoint> priceHistory(String assetId) =>
      List.unmodifiable(_priceHistories[assetId]!);

  /// Latest price, in the asset currency.
  double latestPrice(String assetId) => _priceHistories[assetId]!.last.price;

  /// When prices were last refreshed (simulated), at first a few minutes
  /// before [now]; [refreshPrices] sets it to the current time.
  DateTime get pricesUpdatedAt => _pricesUpdatedAt;

  /// The current time, for "updated X ago" labels.
  DateTime get currentTime => _clock();

  // Holdings

  /// The positions held: a sold out one is not in the list.
  List<Holding> get _open => [
    for (final h in _allHoldings)
      if (!h.isClosed) h,
  ];

  List<Holding> get holdings => List.unmodifiable(_open);

  /// A position, sold out ones included (their movements still point to it).
  Holding holding(String id) => _allHoldings.firstWhere((h) => h.id == id);

  /// What the movements of an account move, up to today (before [before]
  /// when given), in the account currency.
  double _movementCash(String accountId, DateTime? before) {
    final to = account(accountId).currency;
    var sum = 0.0;
    for (final m in _movements) {
      if (m.accountId != accountId || m.date.isAfter(today)) continue;
      if (before != null && !m.date.isBefore(before)) continue;
      sum += _between(m.cashEffect, m.currency, to);
    }
    return sum;
  }

  /// Converts [amount] from a currency to another, through EUR.
  double _between(double amount, String from, String to) {
    if (from == to) return amount;
    final inEur = toEur(amount, from);
    return to == 'EUR' ? inEur : inEur / toEur(1, to);
  }

  /// Current value of a position, in the main currency.
  double holdingValue(String holdingId) {
    final h = holding(holdingId);
    if (h.isManual) return round2(toMain(h.manualValue!, h.currency));
    return round2(toMain(h.quantity * latestPrice(h.assetId!), h.currency));
  }

  /// Purchase cost of the units still held (quantity x PMC), in the main
  /// currency.
  double holdingCost(String holdingId) {
    final h = holding(holdingId);
    return round2(toMain(h.quantity * h.averageCost, h.currency));
  }

  double holdingGain(String holdingId) =>
      round2(holdingValue(holdingId) - holdingCost(holdingId));

  double get portfolioValue =>
      round2(_open.fold(0.0, (sum, h) => sum + holdingValue(h.id)));

  double get portfolioCost =>
      round2(_open.fold(0.0, (sum, h) => sum + holdingCost(h.id)));

  double get portfolioGain => round2(portfolioValue - portfolioCost);

  /// Accounts plus investments, in the main currency. The liquidity of the
  /// broker accounts is in the account balances and not in [portfolioValue]
  /// (positions at market value only), so it is counted once.
  double get netWorth => round2(totalBalance + portfolioValue);

  /// The first day with data (the earliest transaction or purchase), or null
  /// with neither. Before it the accounts stand at their starting balance.
  DateTime? get netWorthHistoryStart {
    var first = _firstPurchase;
    for (final t in _transactions) {
      final d = dateOnly(t.date);
      if (first == null || d.isBefore(first)) first = d;
    }
    return first;
  }

  /// Where [period] starts (today minus the months or years; for
  /// [NetWorthPeriod.all] the start of the history, today without any).
  DateTime netWorthPeriodStart(NetWorthPeriod period) => switch (period) {
    NetWorthPeriod.threeMonths => DateTime(
      today.year,
      today.month - 3,
      today.day,
    ),
    NetWorthPeriod.sixMonths => DateTime(
      today.year,
      today.month - 6,
      today.day,
    ),
    // The last day of the previous year: the change is against its close.
    NetWorthPeriod.yearToDate => DateTime(today.year - 1, 12, 31),
    NetWorthPeriod.year => DateTime(today.year - 1, today.month, today.day),
    NetWorthPeriod.threeYears => DateTime(
      today.year - 3,
      today.month,
      today.day,
    ),
    NetWorthPeriod.fiveYears => DateTime(
      today.year - 5,
      today.month,
      today.day,
    ),
    NetWorthPeriod.all => netWorthHistoryStart ?? today,
  };

  /// Whether the history reaches back to the start of [period] ("All" only
  /// needs some data).
  bool netWorthPeriodAvailable(NetWorthPeriod period) {
    final start = netWorthHistoryStart;
    if (start == null) return false;
    return period == NetWorthPeriod.all ||
        !start.isAfter(netWorthPeriodStart(period));
  }

  /// Net worth at the end of [day]: the account balances (main currency) plus
  /// the positions held then at the price of the last trading day. Today or
  /// later it is [netWorth]. A transfer between accounts, or to a broker
  /// account, does not change it.
  double netWorthAt(DateTime day) {
    final d = dateOnly(day);
    if (!d.isBefore(today)) return netWorth;
    final next = addDays(d, 1);
    var accounts = 0.0;
    for (final a in _accounts) {
      accounts += toMain(accountBalanceAt(a.id, next), a.currency);
    }
    final days = _tradingDays;
    var i = days.length - 1;
    while (i >= 0 && days[i].isAfter(d)) {
      i--;
    }
    final positions = i < 0
        ? 0.0
        : _portfolioAt(d, days[i], (id) => _priceHistories[id]![i].price).value;
    return round2(round2(accounts) + positions);
  }

  /// The highest net worth of the [days] days before [day] (the previous
  /// [days] end-of-day values), or null when the history does not reach back
  /// that far (a young account has no meaningful "high"). Feeds the
  /// "net worth at a high" insight.
  double? netWorthHighBefore(DateTime day, {required int days}) {
    final d = dateOnly(day);
    final start = netWorthHistoryStart;
    if (start == null || start.isAfter(addDays(d, -days))) return null;
    double? high;
    for (var i = 1; i <= days; i++) {
      final v = netWorthAt(addDays(d, -i));
      if (high == null || v > high) high = v;
    }
    return high;
  }

  /// The net worth for [period]: today's value and the series for the chart.
  /// Empty (one point, no change) without history; shorter than the period
  /// when the history is.
  NetWorthSeries netWorthSeries(NetWorthPeriod period) {
    final historyStart = netWorthHistoryStart;
    final current = netWorth;
    final points = <NetWorthPoint>[];
    if (historyStart != null && historyStart.isBefore(today)) {
      var from = netWorthPeriodStart(period);
      if (from.isBefore(historyStart)) from = historyStart;
      final span = today.difference(from).inDays;
      final step = switch (period) {
        NetWorthPeriod.threeMonths || NetWorthPeriod.sixMonths => 1,
        NetWorthPeriod.yearToDate => span > 183 ? 7 : 1,
        NetWorthPeriod.year || NetWorthPeriod.threeYears => 7,
        NetWorthPeriod.fiveYears => 14,
        NetWorthPeriod.all => span > 3 * 365 ? 14 : (span > 365 ? 7 : 1),
      };
      for (var d = from; d.isBefore(today); d = addDays(d, step)) {
        points.add(NetWorthPoint(time: d, value: netWorthAt(d)));
      }
    }
    points.add(NetWorthPoint(time: today, value: current));
    return NetWorthSeries(
      period: period,
      currency: mainCurrency,
      current: current,
      points: List.unmodifiable(points),
    );
  }

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

  // Movements: list, add, change, delete

  InvestmentMovement movement(String id) =>
      _movements.firstWhere((m) => m.id == id);

  /// Accounts the movements can be recorded on: the broker ones or, when the
  /// user has none (a new user who only made ordinary accounts), any account.
  List<Account> get brokerAccounts {
    final brokers = [
      for (final a in _accounts)
        if (a.type == AccountType.broker) a,
    ];
    return brokers.isEmpty ? List.of(_accounts) : brokers;
  }

  String? get _defaultBroker =>
      brokerAccounts.isEmpty ? null : brokerAccounts.first.id;

  /// Where the list of a [MovementPeriod] starts; null: no limit.
  DateTime? movementPeriodStart(MovementPeriod p) => switch (p) {
    MovementPeriod.currentMonth => DateTime(today.year, today.month),
    MovementPeriod.last3Months => DateTime(today.year, today.month - 2),
    MovementPeriod.currentYear => DateTime(today.year),
    MovementPeriod.last12Months => DateTime(today.year, today.month - 11),
    MovementPeriod.all => null,
  };

  PositionKind? _kindOfHolding(Holding h) => _kindOf(h);

  /// Full name of a position: the asset's, or the manual asset's.
  String holdingName(String holdingId) {
    final h = holding(holdingId);
    return h.isManual ? h.manualName! : asset(h.assetId!).name;
  }

  /// The kind of a position (ETF, stock, bond or manual).
  PositionKind kindOfHolding(String holdingId) => _kindOf(holding(holdingId));

  /// A movement with the name, ticker and ISIN of its position.
  MovementEntry movementEntry(InvestmentMovement m) {
    final id = m.holdingId;
    if (id == null) {
      return MovementEntry(movement: m, currency: m.currency);
    }
    final h = holding(id);
    final a = h.isManual ? null : asset(h.assetId!);
    return MovementEntry(
      movement: m,
      currency: m.currency,
      kind: _kindOfHolding(h),
      name: h.isManual ? h.manualName : a!.name,
      ticker: a?.ticker,
      isin: a?.isin,
      holdingOpen: !h.isClosed,
    );
  }

  /// The positions a movement can be about, with the movements to show them
  /// by: every position that has any, sold out ones included.
  List<({String holdingId, String label})> movementAssets() {
    final ids = {for (final m in _movements) ?m.holdingId};
    return [
      for (final h in _allHoldings)
        if (ids.contains(h.id))
          (
            holdingId: h.id,
            label: h.isManual ? h.manualName! : asset(h.assetId!).name,
          ),
    ]..sort((a, b) => a.label.compareTo(b.label));
  }

  /// The movements of the list. What is expected ("Up next": dividends dated
  /// after today, soonest first) follows the search and the filters but not
  /// the period. The rest is what already happened, in the period, grouped by
  /// day, the newest first. Costs without an asset only match a search, a
  /// type and a period; any asset filter leaves them out.
  MovementList movementList(MovementFilter f) {
    final q = f.query.trim().toLowerCase();
    final start = movementPeriodStart(f.period);
    final upNext = <MovementEntry>[];
    final past = <MovementEntry>[];
    for (final m in _movements) {
      if (f.types.isNotEmpty && !f.types.contains(m.type)) continue;
      if (f.holdingId != null && m.holdingId != f.holdingId) continue;
      final e = movementEntry(m);
      if (f.kinds.isNotEmpty && !f.kinds.contains(e.kind)) continue;
      if (q.isNotEmpty &&
          !(e.name?.toLowerCase().contains(q) ?? false) &&
          !(e.ticker?.toLowerCase().contains(q) ?? false) &&
          !(e.isin?.toLowerCase().contains(q) ?? false) &&
          !(m.description?.toLowerCase().contains(q) ?? false)) {
        continue;
      }
      if (m.date.isAfter(today)) {
        if (m.type == MovementType.dividend) upNext.add(e);
        continue;
      }
      if (start != null && m.date.isBefore(start)) continue;
      past.add(e);
    }
    upNext.sort((a, b) => a.movement.date.compareTo(b.movement.date));
    past.sort((a, b) {
      final c = b.movement.date.compareTo(a.movement.date);
      return c != 0 ? c : b.movement.id.compareTo(a.movement.id);
    });
    final byDay = <DateTime, List<MovementEntry>>{};
    for (final e in past) {
      byDay.putIfAbsent(dateOnly(e.movement.date), () => []).add(e);
    }
    return MovementList(
      upNext: List.unmodifiable(upNext),
      days: List.unmodifiable([
        for (final e in byDay.entries)
          MovementDay(day: e.key, entries: List.unmodifiable(e.value)),
      ]),
    );
  }

  /// A movement made of what the form collected, or null when something is
  /// missing or not valid.
  InvestmentMovement? _movementFrom(MovementDraft d, String id) {
    final isTrade = d.type == MovementType.buy || d.type == MovementType.sell;
    if (d.fee < 0 || !d.fee.isFinite) return null;
    // What has to have happened already.
    if (d.type != MovementType.dividend && dateOnly(d.date).isAfter(today)) {
      return null;
    }
    final holding = d.holdingId == null
        ? null
        : _allHoldings.where((h) => h.id == d.holdingId).firstOrNull;
    if (d.holdingId != null && holding == null) return null;
    // An opening buy has no account: it never moves the liquidity.
    final opening = d.isOpening && d.type == MovementType.buy;
    final accountId = opening
        ? null
        : d.accountId ?? holding?.accountId ?? _defaultBroker;
    if (!opening) {
      if (accountId == null) return null;
      if (!_accounts.any((a) => a.id == accountId)) return null;
    }
    final accountCurrency = opening
        ? mainCurrency
        : account(accountId!).currency;
    String? holdingId = holding?.id;
    var currency = holding?.currency ?? accountCurrency;
    if (holdingId == null && d.type == MovementType.buy) {
      // A position to create, or a closed one to bring back.
      if (d.assetId != null) {
        final known = _allHoldings
            .where((h) => h.assetId == d.assetId)
            .firstOrNull;
        holdingId = known?.id ?? 'hld_${d.assetId!.substring(4)}';
        currency = asset(d.assetId!).currency;
      } else if (d.manualName != null && d.manualName!.trim().isNotEmpty) {
        holdingId = 'hld_manual_$_idSeq';
      } else {
        return null;
      }
    }
    if (d.type != MovementType.cost && holdingId == null) return null;
    if (isTrade) {
      final q = d.quantity, p = d.price;
      if (q == null || p == null || !(q > 0) || !(p > 0)) return null;
      if (!q.isFinite || !p.isFinite) return null;
    } else {
      final a = d.amount;
      if (a == null || !(a > 0) || !a.isFinite) return null;
    }
    return InvestmentMovement(
      id: id,
      holdingId: holdingId,
      accountId: accountId,
      type: d.type,
      date: dateOnly(d.date),
      quantity: isTrade ? d.quantity : d.quantity,
      price: isTrade ? d.price : d.price,
      isOpening: opening,
      fee: isTrade && !opening ? round2(d.fee) : 0,
      amount: isTrade ? round2(d.quantity! * d.price!) : round2(d.amount!),
      currency: currency,
      description: d.description?.trim().isEmpty ?? true
          ? null
          : d.description!.trim(),
    );
  }

  /// Plays [next] for the positions in [touched] and, unless [dryRun], makes
  /// it the movements: quantity and average cost are those of the whole
  /// history, a position with no movements goes, one sold out stays closed.
  /// Nothing changes when a sell would go below zero at some date.
  MovementResult _applyMovements(
    List<InvestmentMovement> next,
    Set<String> touched, {
    Holding Function(String id, InvestmentMovement first)? create,
    required bool dryRun,
    String? movementId,
  }) {
    final updated = <String, Holding?>{};
    for (final id in touched) {
      final moves = [
        for (final m in next)
          if (m.holdingId == id) m,
      ];
      if (moves.isEmpty) {
        updated[id] = null;
        continue;
      }
      final r = replayHolding(moves);
      if (r.state == null) {
        return MovementResult.fail(
          MovementFailure.negativeQuantity,
          failedOn: r.failedOn,
        );
      }
      final existing = _allHoldings.where((h) => h.id == id).firstOrNull;
      final base = existing ?? create!(id, moves.first);
      updated[id] = base.copyWith(
        quantity: r.state!.quantity,
        averageCost: (r.state!.averageCost * 10000).round() / 10000,
      );
    }
    if (dryRun) return MovementResult.ok(movementId: movementId);
    for (final e in updated.entries) {
      final i = _allHoldings.indexWhere((h) => h.id == e.key);
      if (e.value == null) {
        if (i >= 0) _allHoldings.removeAt(i);
      } else if (i >= 0) {
        _allHoldings[i] = e.value!;
      } else {
        _allHoldings.add(e.value!);
      }
    }
    _movements
      ..clear()
      ..addAll(next);
    _movements.sort((a, b) => a.date.compareTo(b.date));
    _eventsCache = null;
    notifyListeners();
    return MovementResult.ok(movementId: movementId);
  }

  /// Records a movement. A buy of an asset not held creates the position;
  /// a buy of one held updates its quantity and average cost (commission
  /// included); a sell cannot be more than what is held on that date and does
  /// not change the average cost. The liquidity of the account follows.
  /// With [dryRun] only checks it.
  MovementResult addMovement(MovementDraft d, {bool dryRun = false}) {
    final id = 'mov_u$_idSeq';
    final m = _movementFrom(d, id);
    if (m == null) return const MovementResult.fail(MovementFailure.invalid);
    final created =
        m.holdingId != null && !_allHoldings.any((h) => h.id == m.holdingId);
    if (created && m.type != MovementType.buy) {
      return const MovementResult.fail(MovementFailure.notFound);
    }
    final result = _applyMovements(
      [..._movements, m],
      {?m.holdingId},
      create: created
          ? (hid, first) => d.assetId != null
                ? Holding(
                    id: hid,
                    accountId: first.accountId,
                    assetId: d.assetId,
                    quantity: 0,
                    averageCost: 0,
                    currency: first.currency,
                    countsForNetWorth: d.countsForNetWorth,
                  )
                : Holding(
                    id: hid,
                    manualName: d.manualName!.trim(),
                    manualType: d.manualType ?? ManualAssetType.other,
                    manualValue: first.amount,
                    manualValuedAt: first.date,
                    quantity: 0,
                    averageCost: 0,
                    currency: first.currency,
                    countsForNetWorth: d.countsForNetWorth,
                  )
          : null,
      dryRun: dryRun,
      movementId: id,
    );
    if (result.ok && !dryRun) _idSeq++;
    return result;
  }

  /// Changes what can be changed of a movement (not its type or position):
  /// the date, the account, the quantity, the price, the commission, the
  /// amount and the description of the same kind. The quantity and the
  /// average cost of the position are worked out again from its whole
  /// history, the liquidity follows.
  MovementResult updateMovement(
    String id, {
    required MovementDraft changes,
    bool dryRun = false,
  }) {
    final i = _movements.indexWhere((m) => m.id == id);
    if (i < 0) return const MovementResult.fail(MovementFailure.notFound);
    final old = _movements[i];
    final draft = MovementDraft(
      type: old.type,
      date: changes.date,
      holdingId: old.holdingId,
      accountId: changes.accountId ?? old.accountId,
      quantity: changes.quantity ?? old.quantity,
      price: changes.price ?? old.price,
      fee: old.isOpening ? 0 : changes.fee,
      amount: changes.amount ?? old.amount,
      description: changes.description,
      isOpening: old.isOpening,
    );
    final m = _movementFrom(draft, id);
    if (m == null) return const MovementResult.fail(MovementFailure.invalid);
    final next = [..._movements]..[i] = m;
    return _applyMovements(
      next,
      {?old.holdingId},
      dryRun: dryRun,
      movementId: id,
    );
  }

  /// Removes a movement, working the position out again; refused if a later
  /// sell depended on it. A position left with no movements disappears.
  MovementResult deleteMovement(String id, {bool dryRun = false}) {
    final old = _movements.where((m) => m.id == id).firstOrNull;
    if (old == null) return const MovementResult.fail(MovementFailure.notFound);
    return _applyMovements(
      [
        for (final m in _movements)
          if (m.id != id) m,
      ],
      {?old.holdingId},
      dryRun: dryRun,
    );
  }

  // Assets of the onboarding (opening buys)

  /// The positions entered as opening buys, in order of creation.
  List<Holding> get openingAssets {
    final list = <Holding>[];
    for (final m in _movements) {
      if (!m.isOpening || m.holdingId == null) continue;
      final h = _allHoldings.where((h) => h.id == m.holdingId).firstOrNull;
      if (h != null) list.add(h);
    }
    return List.unmodifiable(list);
  }

  /// The opening buy of a position; null when it has none.
  InvestmentMovement? openingMovementOf(String holdingId) => _movements
      .where((m) => m.isOpening && m.holdingId == holdingId)
      .firstOrNull;

  /// Whether the catalog asset is already a position (sold out ones count:
  /// they come back with a buy, not with a second position).
  bool assetHeld(String assetId) =>
      _allHoldings.any((h) => h.assetId == assetId);

  /// Whether a manual asset has [name] already (capitals and the spaces
  /// around do not count). [excluding] is the position being edited.
  bool manualAssetNameTaken(String name, {String? excluding}) {
    final wanted = name.trim().toLowerCase();
    return _allHoldings.any(
      (h) =>
          h.id != excluding &&
          h.isManual &&
          h.manualName!.trim().toLowerCase() == wanted,
    );
  }

  /// Adds a position as an opening buy dated today: [quantity] units at
  /// [averageCost] (in the currency of the asset, the main one for a manual
  /// asset), no commission, no account. A catalog asset is [assetId], a
  /// manual one [manualName]. Fails with [MovementFailure.duplicate] when the
  /// asset is already there.
  MovementResult addOpeningAsset({
    String? assetId,
    String? manualName,
    ManualAssetType manualType = ManualAssetType.other,
    required double quantity,
    required double averageCost,
    bool countsForNetWorth = true,
  }) {
    if ((assetId != null) == (manualName != null)) {
      return const MovementResult.fail(MovementFailure.invalid);
    }
    if (assetId != null && assetHeld(assetId)) {
      return const MovementResult.fail(MovementFailure.duplicate);
    }
    if (manualName != null && manualAssetNameTaken(manualName)) {
      return const MovementResult.fail(MovementFailure.duplicate);
    }
    return addMovement(
      MovementDraft(
        type: MovementType.buy,
        date: today,
        assetId: assetId,
        manualName: manualName,
        manualType: manualName == null ? null : manualType,
        quantity: quantity,
        price: averageCost,
        isOpening: true,
        countsForNetWorth: countsForNetWorth,
      ),
    );
  }

  /// Changes quantity, average cost and the net worth flag of an opening
  /// asset (not the asset itself).
  MovementResult updateOpeningAsset(
    String holdingId, {
    required double quantity,
    required double averageCost,
    required bool countsForNetWorth,
  }) {
    final m = openingMovementOf(holdingId);
    if (m == null) return const MovementResult.fail(MovementFailure.notFound);
    final result = updateMovement(
      m.id,
      changes: MovementDraft(
        type: MovementType.buy,
        date: m.date,
        quantity: quantity,
        price: averageCost,
      ),
    );
    if (!result.ok) return result;
    final i = _allHoldings.indexWhere((h) => h.id == holdingId);
    var h = _allHoldings[i].copyWith(countsForNetWorth: countsForNetWorth);
    // A manual asset is worth what it cost until the user says otherwise.
    if (h.isManual) h = h.copyWith(manualValue: round2(quantity * averageCost));
    _allHoldings[i] = h;
    notifyListeners();
    return result;
  }

  /// Deletes an opening asset: its opening buy goes and, with no other
  /// movement left, the position with it. Refused when a later sell depends
  /// on the buy.
  MovementResult deleteOpeningAsset(String holdingId) {
    final m = openingMovementOf(holdingId);
    if (m == null) return const MovementResult.fail(MovementFailure.notFound);
    return deleteMovement(m.id);
  }

  /// What the liquidity would be (main currency) with [d] recorded, or with
  /// the movement [replacing] changed to it. Null when [d] is not valid.
  double? liquidityAfter(MovementDraft d, {String? replacing}) {
    final m = _movementFrom(d, replacing ?? 'preview');
    if (m == null) return null;
    var cash = liquidity;
    if (replacing != null) {
      final old = movement(replacing);
      if (_movesCash(old)) cash -= toMain(old.cashEffect, old.currency);
    }
    if (_movesCash(m)) cash += toMain(m.cashEffect, m.currency);
    return round2(cash);
  }

  /// It reaches the liquidity: on a broker account and already happened.
  bool _movesCash(InvestmentMovement m) =>
      !m.date.isAfter(today) &&
      m.accountId != null &&
      brokerAccounts.any((a) => a.id == m.accountId);

  // Investments overview

  /// Cash in the broker accounts, in the main currency.
  double get liquidity => round2(
    _accounts
        .where((a) => a.type == AccountType.broker)
        .fold(0.0, (sum, a) => sum + toMain(accountBalance(a.id), a.currency)),
  );

  /// What the portfolio is worth now: the positions at market value plus the
  /// liquidity, with the unrealized gain of the positions against their cost
  /// (quantity x average cost), liquidity excluded. Main currency.
  PortfolioSummary portfolioSummary() => PortfolioSummary(
    currency: mainCurrency,
    marketValue: portfolioValue,
    liquidity: liquidity,
    cost: portfolioCost,
  );

  /// Buys and sells of each position in date order, as changes of the units
  /// and of the capital invested at cost (in the position's currency, buy
  /// commissions included). A sell takes out the units at the running
  /// average cost. Sold out positions are in it too: they were held.
  Map<String, List<({DateTime date, double units, double cost})>>
  get _holdingEvents => _eventsCache ??= () {
    final result =
        <String, List<({DateTime date, double units, double cost})>>{};
    for (final h in _allHoldings) {
      final events = <({DateTime date, double units, double cost})>[];
      var units = 0.0, cost = 0.0;
      final moves = [
        for (final m in _movements)
          if (m.holdingId == h.id &&
              (m.type == MovementType.buy || m.type == MovementType.sell))
            m,
      ];
      final ordered = moves.indexed.toList()
        ..sort((a, b) {
          final c = a.$2.date.compareTo(b.$2.date);
          return c != 0 ? c : a.$1.compareTo(b.$1);
        });
      for (final (_, m) in ordered) {
        final q = m.quantity!;
        if (m.type == MovementType.buy) {
          final paid = m.amount + m.fee;
          events.add((date: dateOnly(m.date), units: q, cost: paid));
          units += q;
          cost += paid;
        } else {
          final taken = units == 0 ? 0.0 : cost / units * q;
          events.add((date: dateOnly(m.date), units: -q, cost: -taken));
          units -= q;
          cost -= taken;
        }
      }
      result[h.id] = events;
    }
    return result;
  }();

  /// The day of the first purchase, or null with no positions.
  DateTime? get _firstPurchase {
    DateTime? first;
    for (final events in _holdingEvents.values) {
      if (events.isEmpty) continue;
      if (first == null || events.first.date.isBefore(first)) {
        first = events.first.date;
      }
    }
    return first;
  }

  /// Market value and invested capital of the whole portfolio with the units
  /// held on [heldOn] and the prices given by [priceOf] (asset id to price),
  /// valuing manual assets as of [valuedOn]. Main currency.
  ({double value, double invested}) _portfolioAt(
    DateTime heldOn,
    DateTime valuedOn,
    double Function(String assetId) priceOf,
  ) {
    var value = 0.0, invested = 0.0;
    for (final h in _allHoldings) {
      var units = 0.0, cost = 0.0;
      for (final e in _holdingEvents[h.id]!) {
        if (e.date.isAfter(heldOn)) break;
        units += e.units;
        cost += e.cost;
      }
      if (units <= 1e-9) continue;
      invested += round2(toMain(cost, h.currency));
      if (h.isManual) {
        final valued = h.manualValuedAt;
        final current = valued != null && !valuedOn.isBefore(dateOnly(valued));
        value += round2(toMain(current ? h.manualValue! : cost, h.currency));
      } else {
        value += round2(toMain(units * priceOf(h.assetId!), h.currency));
      }
    }
    return (value: round2(value), invested: round2(invested));
  }

  /// The trading days (the calendar every price history shares).
  List<DateTime> get _tradingDays =>
      _priceHistories.values.first.map((p) => p.date).toList();

  /// The chart series of the portfolio for [period], in the main currency:
  /// market value of the positions (liquidity excluded) and invested capital.
  /// Intraday periods have a point every 15 minutes, the others one per
  /// trading day; the series starts at the first purchase when the period is
  /// longer than the history of the portfolio. Its last point is the current
  /// market value of the positions.
  ValueSeries marketValueSeries(ValuePeriod period) {
    final first = _firstPurchase;
    final days = _tradingDays;
    final last = days.length - 1;
    final points = <ValuePoint>[];
    if (first != null) {
      if (period == ValuePeriod.day || period == ValuePeriod.fiveDays) {
        final count = period == ValuePeriod.day ? 1 : 5;
        for (var d = 0; d < count; d++) {
          final dayIndex = last - (count - 1) + d;
          if (days[dayIndex].isBefore(first)) continue;
          final held = dayIndex == last ? today : days[dayIndex];
          for (var j = 0; j < intradayPointsPerDay; j++) {
            final at = d + (5 - count);
            final state = _portfolioAt(
              held,
              days[dayIndex],
              (id) => _intradayPrices[id]![at * intradayPointsPerDay + j].price,
            );
            points.add(
              ValuePoint(
                time: _intradayPrices
                    .values
                    .first[at * intradayPointsPerDay + j]
                    .date,
                value: state.value,
                invested: state.invested,
              ),
            );
          }
        }
      } else {
        final from = switch (period) {
          ValuePeriod.month => DateTime(today.year, today.month - 1, today.day),
          ValuePeriod.sixMonths => DateTime(
            today.year,
            today.month - 6,
            today.day,
          ),
          ValuePeriod.yearToDate => DateTime(today.year),
          ValuePeriod.year => DateTime(today.year - 1, today.month, today.day),
          _ => DateTime(today.year - 5, today.month, today.day),
        };
        for (var i = 0; i <= last; i++) {
          if (days[i].isBefore(from) || days[i].isBefore(first)) continue;
          final held = i == last ? today : days[i];
          final state = _portfolioAt(
            held,
            days[i],
            (id) => _priceHistories[id]![i].price,
          );
          points.add(
            ValuePoint(
              time: days[i],
              value: state.value,
              invested: state.invested,
            ),
          );
        }
      }
    }
    return ValueSeries(
      period: period,
      currency: mainCurrency,
      points: List.unmodifiable(points),
    );
  }

  /// The close of trading day [i] as a chart point (the last day is today,
  /// with the current prices and the units held now).
  ValuePoint _closePoint(int i) {
    final days = _tradingDays;
    final state = _portfolioAt(
      i == days.length - 1 ? today : days[i],
      days[i],
      (id) => _priceHistories[id]![i].price,
    );
    return ValuePoint(
      time: days[i],
      value: state.value,
      invested: state.invested,
    );
  }

  /// Performance from [from] to [to]: the change of (value - invested), so
  /// buys and sells do not count. The base of the percentage is the value at
  /// the start plus what was invested in between.
  InvestmentChange _performance(ValuePoint from, ValuePoint to) {
    final amount = round2(
      (to.value - to.invested) - (from.value - from.invested),
    );
    final base = from.value + (to.invested - from.invested);
    return InvestmentChange(
      amount: amount,
      percent: base > 0 ? amount / base : null,
    );
  }

  /// Everything of the Dashboard "Investments" widget for [period]: the value
  /// (positions + liquidity, as the Overview), the daily change against the
  /// previous close, the year-to-date change, the change of [period] and the
  /// Overview's market value series. Changes are market performance (see
  /// [InvestmentChange]); the Overview's own P&L is against the average cost.
  InvestmentsSnapshot investmentsSnapshot(ValuePeriod period) {
    final summary = portfolioSummary();
    final series = marketValueSeries(period);
    final first = _firstPurchase;
    final days = _tradingDays;
    final last = days.length - 1;
    InvestmentChange? daily, ytd;
    if (first != null && last >= 1 && !days[last - 1].isBefore(first)) {
      daily = _performance(_closePoint(last - 1), _closePoint(last));
    }
    if (first != null) {
      final start = days.lastIndexWhere((d) => d.year < today.year);
      DateTime? from;
      if (start >= 0 && !days[start].isBefore(first)) from = days[start];
      from ??= first;
      final startIndex = days.indexWhere((d) => !d.isBefore(from!));
      if (startIndex >= 0 && startIndex < last) {
        ytd = _performance(_closePoint(startIndex), _closePoint(last));
      }
    }
    final points = series.points;
    final periodChange = switch (period) {
      ValuePeriod.day => daily,
      ValuePeriod.yearToDate => ytd,
      _ => points.length < 2 ? null : _performance(points.first, points.last),
    };
    return InvestmentsSnapshot(
      period: period,
      currency: mainCurrency,
      hasPositions: holdings.isNotEmpty,
      totalValue: summary.totalValue,
      daily: daily,
      yearToDate: ytd,
      periodChange: periodChange,
      series: series,
    );
  }

  /// How the portfolio is split, largest first with the liquidity last as a
  /// slice of its own; shares are of positions plus liquidity. By asset class
  /// (ETF, stocks, bonds, other = manual assets) or by single asset (the
  /// first five, the rest together as "other"). Empty when it is all zero.
  List<AllocationSlice> assetAllocation(
    AllocationMode mode, {
    int topAssets = 5,
  }) {
    final cash = liquidity;
    final total = portfolioValue + cash;
    if (total <= 0) return const [];
    double share(double v) => v / total;
    final slices = <AllocationSlice>[];
    if (mode == AllocationMode.assetClass) {
      final byClass = <AssetClass, double>{};
      for (final h in _open) {
        final cls = h.isManual
            ? AssetClass.other
            : switch (asset(h.assetId!).type) {
                AssetType.etf => AssetClass.etf,
                AssetType.stock => AssetClass.stock,
                AssetType.bond => AssetClass.bond,
              };
        byClass[cls] = (byClass[cls] ?? 0) + holdingValue(h.id);
      }
      final entries = byClass.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in entries) {
        slices.add(
          AllocationSlice(
            kind: AllocationKind.assetClass,
            assetClass: e.key,
            value: round2(e.value),
            share: share(e.value),
          ),
        );
      }
    } else {
      final held = [
        for (final h in _open)
          if (holdingValue(h.id) > 0) (h.id, holdingValue(h.id)),
      ]..sort((a, b) => b.$2.compareTo(a.$2));
      for (final (id, value) in held.take(topAssets)) {
        slices.add(
          AllocationSlice(
            kind: AllocationKind.asset,
            holdingId: id,
            value: value,
            share: share(value),
          ),
        );
      }
      final rest = held.skip(topAssets).fold(0.0, (sum, e) => sum + e.$2);
      if (rest > 0) {
        slices.add(
          AllocationSlice(
            kind: AllocationKind.other,
            value: round2(rest),
            share: share(rest),
          ),
        );
      }
    }
    if (cash > 0) {
      slices.add(
        AllocationSlice(
          kind: AllocationKind.liquidity,
          value: cash,
          share: share(cash),
        ),
      );
    }
    return List.unmodifiable(slices);
  }

  /// [assetAllocation] as the Dashboard "Allocation" widget shows it: at most
  /// [maxRows] slices as they are (single mode: the first six assets), the rest
  /// summed in one "other" row (a lone leftover slice stays what it is), and
  /// whole percentages that add up to exactly 100 (largest remainder).
  List<AllocationRow> allocationBreakdown(AllocationMode mode, {int? maxRows}) {
    final all = assetAllocation(mode, topAssets: 6);
    var slices = all;
    if (maxRows != null && all.length > maxRows + 1) {
      final rest = all.skip(maxRows);
      slices = [
        ...all.take(maxRows),
        AllocationSlice(
          kind: AllocationKind.other,
          value: round2(rest.fold(0.0, (s, e) => s + e.value)),
          share: rest.fold(0.0, (s, e) => s + e.share),
        ),
      ];
    }
    final percents = _wholePercents([for (final s in slices) s.share]);
    return List.unmodifiable([
      for (final (i, s) in slices.indexed)
        AllocationRow(slice: s, percent: percents[i]),
    ]);
  }

  /// Rounds [shares] (fractions that add up to 1) to whole percentages that
  /// add up to 100.
  @visibleForTesting
  static List<int> debugWholePercents(List<double> shares) =>
      _wholePercents(shares);

  static List<int> _wholePercents(List<double> shares) {
    if (shares.isEmpty) return const [];
    final total = shares.fold(0.0, (s, e) => s + e);
    final exact = [for (final s in shares) s / total * 100];
    final floors = [for (final e in exact) e.floor()];
    var missing = 100 - floors.fold(0, (s, e) => s + e);
    final order = List.generate(exact.length, (i) => i)
      ..sort((a, b) => (exact[b] - floors[b]).compareTo(exact[a] - floors[a]));
    for (final i in order) {
      if (missing <= 0) break;
      floors[i]++;
      missing--;
    }
    return floors;
  }

  /// Intraday prices (every 15 minutes) of the last five trading days,
  /// oldest first, in the asset currency.
  List<PricePoint> intradayPrices(String assetId) =>
      List.unmodifiable(_intradayPrices[assetId]!);

  /// Sets the latest price of an asset (daily and intraday close). For tests.
  @visibleForTesting
  void debugSetLastPrice(String assetId, double price) {
    for (final list in [_priceHistories[assetId]!, _intradayPrices[assetId]!]) {
      final p = list.last;
      list[list.length - 1] = PricePoint(date: p.date, price: price);
    }
  }

  /// Simulates a price refresh: every price moves a little (at most 0.4%,
  /// bonds 0.05%), the last point of the daily and intraday series follows,
  /// and [pricesUpdatedAt] becomes the current time. Listeners are notified.
  void refreshPrices() {
    _refreshCount++;
    for (final (i, id) in _priceHistories.keys.toList().indexed) {
      final random = math.Random(9000 + _refreshCount * 100 + i);
      final a = asset(id);
      final move =
          (random.nextDouble() * 2 - 1) *
          (a.type == AssetType.bond ? 0.0005 : 0.004);
      final decimals = _priceHistories[id]!.last.price < 10 ? 1000 : 100;
      for (final list in [_priceHistories[id]!, _intradayPrices[id]!]) {
        final p = list.last;
        list[list.length - 1] = PricePoint(
          date: p.date,
          price: (p.price * (1 + move) * decimals).round() / decimals,
        );
      }
    }
    _pricesUpdatedAt = _clock();
    notifyListeners();
  }

  // Investments positions

  PositionKind _kindOf(Holding h) => h.isManual
      ? PositionKind.manual
      : switch (asset(h.assetId!).type) {
          AssetType.etf => PositionKind.etf,
          AssetType.stock => PositionKind.stock,
          AssetType.bond => PositionKind.bond,
        };

  /// The prices of the last month of an asset, in the main currency.
  List<double> _monthPrices(Holding h) {
    final from = DateTime(today.year, today.month - 1, today.day);
    return [
      for (final p in _priceHistories[h.assetId!]!)
        if (!p.date.isBefore(from)) toMain(p.price, h.currency),
    ];
  }

  Position _position(Holding h, double totalValue) {
    final kind = _kindOf(h);
    final a = h.isManual ? null : asset(h.assetId!);
    final month = h.isManual ? const <double>[] : _monthPrices(h);
    final value = holdingValue(h.id);
    return Position(
      holdingId: h.id,
      kind: kind,
      manualType: h.manualType,
      name: h.isManual ? h.manualName! : a!.name,
      ticker: a?.ticker,
      isin: a?.isin,
      exchange: a?.exchange,
      value: value,
      cost: holdingCost(h.id),
      weight: totalValue <= 0 ? 0 : value / totalValue,
      monthPrices: month,
      monthChange: month.length < 2 || month.first == 0
          ? null
          : month.last / month.first - 1,
    );
  }

  /// The positions, the heaviest first (weight over positions plus
  /// liquidity). [query] matches name, ticker and ISIN (case and accents
  /// ignored not needed: plain case-insensitive); [kinds], when not empty,
  /// keeps only those kinds. The weight does not depend on the filter.
  List<Position> searchPositions({
    String query = '',
    Set<PositionKind> kinds = const {},
  }) {
    final total = portfolioValue + liquidity;
    final q = query.trim().toLowerCase();
    final list =
        [
            for (final h in _open)
              if (kinds.isEmpty || kinds.contains(_kindOf(h)))
                _position(h, total),
          ].where((p) {
            if (q.isEmpty) return true;
            return p.name.toLowerCase().contains(q) ||
                (p.ticker?.toLowerCase().contains(q) ?? false) ||
                (p.isin?.toLowerCase().contains(q) ?? false);
          }).toList()
          ..sort((a, b) {
            final c = b.value.compareTo(a.value);
            return c != 0 ? c : a.holdingId.compareTo(b.holdingId);
          });
    return List.unmodifiable(list);
  }

  /// The positions split by region or sector of the asset, heaviest first
  /// with "other" (name null: bonds, manual assets, whatever has none) last.
  /// Shares are of the value of the positions; the liquidity is not in it.
  List<BreakdownRow> portfolioBreakdown(BreakdownBy by) {
    final total = portfolioValue;
    if (total <= 0) return const [];
    final totals = <String?, double>{};
    for (final h in _open) {
      final a = h.isManual ? null : asset(h.assetId!);
      final key = by == BreakdownBy.region ? a?.region : a?.sector;
      totals[key] = (totals[key] ?? 0) + holdingValue(h.id);
    }
    final named = totals.entries.where((e) => e.key != null).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final other = totals[null];
    return List.unmodifiable([
      for (final e in named)
        BreakdownRow(
          name: e.key,
          value: round2(e.value),
          share: e.value / total,
        ),
      if (other != null && other > 0)
        BreakdownRow(name: null, value: round2(other), share: other / total),
    ]);
  }

  /// Everything the page of a position shows. Operations are the buys, sells
  /// and dividends already happened (fees and expected dividends left out),
  /// grouped by day, the newest first.
  PositionDetail positionDetail(String holdingId) {
    final h = holding(holdingId);
    final total = portfolioValue + liquidity;
    final a = h.isManual ? null : asset(h.assetId!);
    double? price, todayChange;
    if (a != null) {
      final history = _priceHistories[a.id]!;
      price = history.last.price;
      final previous = history[history.length - 2].price;
      todayChange = previous == 0 ? null : price / previous - 1;
    }
    final byDay = <DateTime, List<Operation>>{};
    final moves =
        _movements
            .where(
              (m) =>
                  m.holdingId == h.id &&
                  m.type != MovementType.cost &&
                  !m.date.isAfter(today),
            )
            .toList()
          ..sort((x, y) => y.date.compareTo(x.date));
    for (final m in moves) {
      byDay
          .putIfAbsent(dateOnly(m.date), () => [])
          .add(
            Operation(
              type: m.type,
              date: m.date,
              amount: m.amount,
              currency: m.currency,
              quantity: m.quantity,
              price: m.price,
            ),
          );
    }
    return PositionDetail(
      position: _position(h, total),
      assetCurrency: h.currency,
      quantity: h.quantity,
      averageCost: h.averageCost,
      averageCostMain: round2(toMain(h.averageCost, h.currency)),
      price: price,
      priceMain: price == null ? null : toMain(price, h.currency),
      todayChange: todayChange,
      type: a?.type,
      sector: a?.sector,
      region: a?.region,
      asset: a,
      paysIncome: a?.paysIncome ?? false,
      operations: List.unmodifiable([
        for (final e in byDay.entries)
          OperationDay(day: e.key, operations: List.unmodifiable(e.value)),
      ]),
    );
  }

  /// The price of a position over [period], in the main currency, as a
  /// series whose "invested" is the average cost (a flat line). Same points
  /// as [marketValueSeries]: intraday for 1D and 5D, daily for the rest.
  /// Empty for manual assets.
  ValueSeries priceSeries(String holdingId, ValuePeriod period) {
    final h = holding(holdingId);
    if (h.isManual) {
      return ValueSeries(
        period: period,
        currency: mainCurrency,
        points: const [],
      );
    }
    final cost = toMain(h.averageCost, h.currency);
    final id = h.assetId!;
    final points = <ValuePoint>[];
    if (period == ValuePeriod.day || period == ValuePeriod.fiveDays) {
      final intraday = _intradayPrices[id]!;
      final skip = period == ValuePeriod.day
          ? intraday.length - intradayPointsPerDay
          : 0;
      for (final p in intraday.skip(skip)) {
        points.add(
          ValuePoint(
            time: p.date,
            value: toMain(p.price, h.currency),
            invested: cost,
          ),
        );
      }
    } else {
      final from = switch (period) {
        ValuePeriod.month => DateTime(today.year, today.month - 1, today.day),
        ValuePeriod.sixMonths => DateTime(
          today.year,
          today.month - 6,
          today.day,
        ),
        ValuePeriod.yearToDate => DateTime(today.year),
        ValuePeriod.year => DateTime(today.year - 1, today.month, today.day),
        _ => DateTime(today.year - 5, today.month, today.day),
      };
      for (final p in _priceHistories[id]!) {
        if (p.date.isBefore(from)) continue;
        points.add(
          ValuePoint(
            time: p.date,
            value: toMain(p.price, h.currency),
            invested: cost,
          ),
        );
      }
    }
    return ValueSeries(
      period: period,
      currency: mainCurrency,
      points: List.unmodifiable(points),
    );
  }

  // Investments digest

  /// The change in the value of the positions over the last month, net of
  /// what was invested in it, with the percentage over the value a month
  /// ago. Null when the portfolio was empty then.
  ({double change, double percent})? _lastMonthChange() {
    final days = _tradingDays;
    final last = days.length - 1;
    final monthAgo = DateTime(today.year, today.month - 1, today.day);
    var then = -1;
    for (var i = 0; i <= last; i++) {
      if (days[i].isAfter(monthAgo)) break;
      then = i;
    }
    if (then < 0) return null;
    final before = _portfolioAt(
      days[then],
      days[then],
      (id) => _priceHistories[id]![then].price,
    );
    if (before.value <= 0) return null;
    final now = _portfolioAt(
      today,
      days[last],
      (id) => _priceHistories[id]![last].price,
    );
    final change =
        (now.value - before.value) - (now.invested - before.invested);
    return (change: round2(change), percent: change / before.value);
  }

  /// At most three messages by priority (concentration, drop of the month,
  /// growth of the month, expected dividend), or one neutral message.
  List<InvestmentDigestMessage> investmentDigest() {
    final messages = [
      ?digestConcentration(),
      ?digestMonthDrop(),
      ?digestMonthGrowth(),
      ?digestExpectedDividend(),
    ];
    if (messages.isEmpty) {
      return const [
        InvestmentDigestMessage(rule: InvestmentDigestRule.allGood),
      ];
    }
    return List.unmodifiable(messages.take(3));
  }

  /// Rule a: a single asset is more than [threshold] of the whole portfolio
  /// (positions plus liquidity).
  InvestmentDigestMessage? digestConcentration({double threshold = 0.4}) {
    final total = portfolioValue + liquidity;
    if (total <= 0) return null;
    String? top;
    var topValue = 0.0;
    for (final h in _open) {
      final v = holdingValue(h.id);
      if (v > topValue) {
        top = h.id;
        topValue = v;
      }
    }
    if (top == null || topValue / total <= threshold) return null;
    return InvestmentDigestMessage(
      rule: InvestmentDigestRule.concentration,
      holdingId: top,
      percent: topValue / total,
    );
  }

  /// Rule b: the positions lost more than [threshold] in the last month,
  /// net of what was invested in it (warning).
  InvestmentDigestMessage? digestMonthDrop({double threshold = 0.05}) {
    final m = _lastMonthChange();
    if (m == null || m.percent >= -threshold) return null;
    return InvestmentDigestMessage(
      rule: InvestmentDigestRule.monthDrop,
      amount: -m.change,
      percent: -m.percent,
    );
  }

  /// Rule c: the positions gained in the last month, net of what was
  /// invested in it (success).
  InvestmentDigestMessage? digestMonthGrowth() {
    final m = _lastMonthChange();
    if (m == null || m.change <= 0) return null;
    return InvestmentDigestMessage(
      rule: InvestmentDigestRule.monthGrowth,
      amount: m.change,
      percent: m.percent,
    );
  }

  /// Rule d: dividends expected in the next [days] days, as one message with
  /// their total (info).
  InvestmentDigestMessage? digestExpectedDividend({int days = 7}) {
    final limit = DateTime(today.year, today.month, today.day + days);
    final due = [
      for (final m in expectedDividends)
        if (!dateOnly(m.date).isAfter(limit)) m,
    ];
    if (due.isEmpty) return null;
    return InvestmentDigestMessage(
      rule: InvestmentDigestRule.expectedDividend,
      count: due.length,
      amount: round2(due.fold(0.0, (s, m) => s + toMain(m.amount, m.currency))),
      holdingId: due.length == 1 ? due.single.holdingId : null,
      days: days,
    );
  }

  // Exchange rates

  List<ExchangeRate> get exchangeRates => List.unmodifiable(_exchangeRates);

  DateTime get ratesUpdatedAt => _exchangeRates.first.updatedAt;

  /// Converts [amount] from [currency] to EUR with the fixed rates.
  double toEur(double amount, String currency) {
    if (currency == 'EUR') return amount;
    return amount *
        _exchangeRates.firstWhere((r) => r.currency == currency).toEur;
  }

  /// Converts [amount] from the main currency to [currency], through EUR.
  double fromMain(double amount, String currency) {
    if (currency == _mainCurrency) return amount;
    final inEur = _mainCurrency == 'EUR'
        ? amount
        : toEur(amount, _mainCurrency);
    return currency == 'EUR' ? inEur : inEur / toEur(1, currency);
  }

  /// Converts [amount] from [currency] to the main currency, through EUR.
  double toMain(double amount, String currency) {
    if (currency == _mainCurrency) return amount;
    final inEur = toEur(amount, currency);
    return _mainCurrency == 'EUR' ? inEur : inEur / toEur(1, _mainCurrency);
  }
}
