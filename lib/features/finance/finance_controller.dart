import 'package:flutter/foundation.dart';

import '../../mock/mock_repository.dart';
import '../../mock/models/budget.dart';
import '../../mock/models/transaction_filter.dart';
import '../../mock/models/transaction_page.dart';
import 'charts/transaction_charts_controller.dart';
import 'recurring/recurring_controller.dart';

enum FinanceTab { overview, transactions, budget, recurring }

enum TransactionsView { list, charts }

/// State of the Finance page for the session: the selected tab and view,
/// and the search, filters and page of the transaction list. Kept by the
/// app shell, so it survives tab changes. The list itself comes from
/// [MockRepository.searchTransactions]; nothing is filtered here.
class FinanceController extends ChangeNotifier {
  FinanceController(this.repository)
    : defaultFilter = TransactionFilter.forMonthOf(repository.today) {
    _filter = defaultFilter;
    charts = TransactionChartsController(repository)
      ..addListener(notifyListeners);
    recurring = RecurringController(repository)..addListener(notifyListeners);
    repository.addListener(_repositoryChanged);
  }

  /// The main currency changed: the amounts have to be read again.
  void _repositoryChanged() {
    _result = null;
    notifyListeners();
  }

  /// State of the Charts view; changes notify this controller too.
  late final TransactionChartsController charts;

  /// State of the Recurring tab; changes notify this controller too.
  late final RecurringController recurring;

  final MockRepository repository;

  /// What the list shows before the user touches anything: current month.
  final TransactionFilter defaultFilter;

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    charts.dispose();
    recurring.dispose();
    super.dispose();
  }

  FinanceTab _tab = FinanceTab.overview;
  TransactionsView _view = TransactionsView.list;
  BudgetPeriod _budgetPeriod = BudgetPeriod.monthly;
  late TransactionFilter _filter;
  int _page = 1;
  TransactionPage? _result;

  FinanceTab get tab => _tab;
  TransactionsView get view => _view;

  /// The period shown in the Budget tab; there is always one.
  BudgetPeriod get budgetPeriod => _budgetPeriod;
  TransactionFilter get filter => _filter;

  /// The current page of results (1-based, as clamped by the repository).
  TransactionPage get result =>
      _result ??= repository.searchTransactions(_filter, page: _page);

  int get page => result.page;

  /// Number of filters applied beyond the default (the dot on the filter
  /// button); the search text is not counted.
  int get activeFilterCount => _filter.activeFilterCount(defaultFilter);

  /// Search text or any filter that differs from the default view.
  bool get isRefined => _filter != defaultFilter;

  void selectTab(FinanceTab tab) => _set(() => _tab = tab, keepResult: true);

  void selectBudgetPeriod(BudgetPeriod period) =>
      _set(() => _budgetPeriod = period, keepResult: true);

  void selectView(TransactionsView view) =>
      _set(() => _view = view, keepResult: true);

  void setQuery(String query) => _setFilter(_filter.copyWith(query: query));

  /// Applies filters chosen in the filters sheet; the search text stays.
  void applyFilter(TransactionFilter filter) =>
      _setFilter(filter.copyWith(query: _filter.query));

  /// Removes the date limit: all transactions, whatever the date.
  void removeDate() => _setFilter(_filter.withDateRange(null, null));

  void removeTypes() => _setFilter(_filter.copyWith(types: const {}));

  void removeCategories() =>
      _setFilter(_filter.copyWith(categoryIds: const {}));

  void removeAmount() => _setFilter(_filter.withAmountRange(null, null));

  void removeAccounts() => _setFilter(_filter.copyWith(accountIds: const {}));

  /// Back to the default view: current month, no search, no filters.
  void clearAll() => _setFilter(defaultFilter);

  void goToPage(int page) => _set(() => _page = page);

  void _setFilter(TransactionFilter filter) {
    if (filter == _filter) return;
    _set(() {
      _filter = filter;
      _page = 1;
    });
  }

  void _set(VoidCallback change, {bool keepResult = false}) {
    change();
    if (!keepResult) _result = null;
    notifyListeners();
  }
}
