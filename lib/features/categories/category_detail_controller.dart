import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../mock/mock_repository.dart';
import '../../mock/models/category.dart';
import '../../mock/models/recurring_transaction.dart';
import '../../mock/models/subcategory.dart';
import '../../mock/models/transaction_filter.dart';
import '../../mock/models/transaction_page.dart';

/// State of the page of one category, or of one of its subcategories (when
/// [subcategoryId] is given): search, filters and page of its transactions, in
/// memory. The category (or subcategory) is fixed and there is no date by
/// default. Nothing is worked out here: the filter comes from
/// [MockRepository.categoryTransactionFilter] and the page from
/// `searchTransactions`.
class CategoryDetailController extends ChangeNotifier {
  CategoryDetailController(
    this.repository,
    this.categoryId, {
    this.subcategoryId,
  }) : baseFilter = repository.categoryTransactionFilter(
         categoryId,
         subcategoryId: subcategoryId,
       ) {
    _filter = baseFilter;
    repository.addListener(_repositoryChanged);
  }

  final MockRepository repository;
  final String categoryId;
  final String? subcategoryId;

  /// The category (and subcategory) alone: what the page can never change.
  final TransactionFilter baseFilter;

  late TransactionFilter _filter;
  int _page = 1;
  TransactionPage? _result;

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }

  /// A change in the data (the category edited, the main currency, ...):
  /// read again.
  void _repositoryChanged() {
    _result = null;
    notifyListeners();
  }

  // Category

  bool get isSubcategory => subcategoryId != null;

  /// Null once the category was deleted.
  Category? get category {
    for (final c in repository.categories()) {
      if (c.id == categoryId) return c;
    }
    return null;
  }

  /// The subcategory of a subcategory page; null on a category page or once
  /// it was deleted.
  Subcategory? get subcategory {
    if (subcategoryId == null) return null;
    for (final s in repository.subcategoriesOf(categoryId)) {
      if (s.id == subcategoryId) return s;
    }
    return null;
  }

  /// The category or the subcategory is gone: the page has nothing to show.
  bool get isDeleted =>
      category == null || (isSubcategory && subcategory == null);

  /// The subcategories of a category page, in order of creation.
  List<Subcategory> get subcategories => repository.subcategoriesOf(categoryId);

  /// The recurring transactions of the category (or of the subcategory).
  List<RecurringTransaction> get recurring =>
      repository.recurringOfCategory(categoryId, subcategoryId: subcategoryId);

  // Transactions

  TransactionFilter get filter => _filter;

  TransactionPage get result =>
      _result ??= repository.searchTransactions(_filter, page: _page);

  int get page => result.page;

  /// Filters applied beyond the category (the dot of the filter button); the
  /// search text is not counted.
  int get activeFilterCount => _filter.activeFilterCount(baseFilter) - 1;

  /// Search text or any filter beyond the category.
  bool get isRefined => _filter != baseFilter;

  void setQuery(String query) => _setFilter(_filter.copyWith(query: query));

  /// Applies the filters chosen in the sheet; the search text stays.
  void applyFilter(TransactionFilter filter) =>
      _setFilter(filter.copyWith(query: _filter.query));

  void removeDate() => _setFilter(_filter.withDateRange(null, null));

  void removeAmount() => _setFilter(_filter.withAmountRange(null, null));

  void removeAccounts() => _setFilter(_filter.copyWith(accountIds: const {}));

  /// Back to the category alone: no search, no filters.
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
