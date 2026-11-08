import 'package:flutter/foundation.dart';

import '../../mock/mock_repository.dart';
import '../../mock/models/account.dart';
import '../../mock/models/account_series.dart';
import '../../mock/models/net_worth.dart';
import '../../mock/models/transaction_filter.dart';
import '../../mock/models/transaction_page.dart';

/// State of the page of one account, in memory: the period of the balance
/// chart and the search, filters and page of its transactions (not the ones
/// of Finance). Numbers come from the repository ([MockRepository.accountSeries]
/// and `searchTransactions`); nothing is worked out here.
class AccountDetailController extends ChangeNotifier {
  AccountDetailController(this.repository, this.accountId)
    // The account is fixed: no date by default, any type, category or amount.
    : baseFilter = TransactionFilter(accountIds: {accountId}) {
    _filter = baseFilter;
    repository.addListener(_repositoryChanged);
  }

  final MockRepository repository;
  final String accountId;

  /// The account alone: what the page can never change.
  final TransactionFilter baseFilter;

  /// Opens on the repository's choice for this account: year to date, or the
  /// closest period its history covers.
  late NetWorthPeriod _period = repository.accountDefaultPeriod(accountId);
  late TransactionFilter _filter;
  int _page = 1;
  TransactionPage? _result;
  AccountSeries? _series;

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }

  /// A change in the data (the account edited, the main currency, ...): read
  /// again.
  void _repositoryChanged() {
    _result = null;
    _series = null;
    notifyListeners();
  }

  // Account

  /// Null once the account was deleted.
  Account? get account {
    for (final a in repository.accounts) {
      if (a.id == accountId) return a;
    }
    return null;
  }

  bool get isDeleted => account == null;

  // Balance chart

  NetWorthPeriod get period => _period;

  void selectPeriod(NetWorthPeriod period) {
    if (period == _period) return;
    _period = period;
    _series = null;
    notifyListeners();
  }

  /// The balance over the period; call only while the account exists.
  AccountSeries get series =>
      _series ??= repository.accountSeries(accountId, _period);

  /// Periods the account's history does not reach back to.
  Set<NetWorthPeriod> get unavailablePeriods => {
    for (final p in NetWorthPeriod.values)
      if (!repository.accountPeriodAvailable(accountId, p)) p,
  };

  // Transactions

  TransactionFilter get filter => _filter;

  TransactionPage get result =>
      _result ??= repository.searchTransactions(_filter, page: _page);

  int get page => result.page;

  /// Filters applied beyond the account (the dot of the filter button); the
  /// search text is not counted.
  int get activeFilterCount => _filter.activeFilterCount(baseFilter) - 1;

  /// Search text or any filter beyond the account.
  bool get isRefined => _filter != baseFilter;

  void setQuery(String query) => _setFilter(_filter.copyWith(query: query));

  /// Applies the filters chosen in the sheet; the search text stays.
  void applyFilter(TransactionFilter filter) =>
      _setFilter(filter.copyWith(query: _filter.query));

  void removeDate() => _setFilter(_filter.withDateRange(null, null));

  void removeTypes() => _setFilter(_filter.copyWith(types: const {}));

  void removeCategories() =>
      _setFilter(_filter.copyWith(categoryIds: const {}));

  void removeAmount() => _setFilter(_filter.withAmountRange(null, null));

  /// Back to the account alone: no search, no filters.
  void clearAll() => _setFilter(baseFilter);

  void goToPage(int page) {
    _page = page;
    _result = null;
    notifyListeners();
  }

  void _setFilter(TransactionFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    _page = 1;
    _result = null;
    notifyListeners();
  }
}
