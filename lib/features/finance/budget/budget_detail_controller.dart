import 'package:flutter/foundation.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/budget.dart';
import '../../../mock/models/budget_status.dart';
import '../../../mock/models/transaction_filter.dart';
import '../../../mock/models/transaction_page.dart';

/// Why the amount typed in edit mode cannot be saved.
enum BudgetAmountError { required, notPositive }

/// State of the page of one budget: its expenses (search, filters, page)
/// and the edit mode with the amount being typed. Numbers come from the
/// repository: the status (with a preview of the typed amount), the filter
/// that selects the expenses, and the page of results.
class BudgetDetailController extends ChangeNotifier {
  BudgetDetailController(this.repository, this.budgetId)
    : baseFilter = repository.budgetTransactionFilter(budgetId) {
    _filter = baseFilter;
    repository.addListener(_repositoryChanged);
  }

  final MockRepository repository;
  final String budgetId;

  /// Period, category and "expenses only" of the budget: what the page can
  /// never change.
  final TransactionFilter baseFilter;

  late TransactionFilter _filter;
  int _page = 1;
  TransactionPage? _result;
  bool _editing = false;
  String _draft = '';
  BudgetAmountError? _error;
  bool _deleted = false;

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }

  /// The main currency changed or a budget was edited: read again.
  void _repositoryChanged() {
    _result = null;
    notifyListeners();
  }

  // Budget

  /// Null once the budget was deleted.
  Budget? get budget {
    for (final b in repository.budgets) {
      if (b.id == budgetId) return b;
    }
    return null;
  }

  bool get isDeleted => _deleted || budget == null;

  /// Spending against the budget. In edit mode, with a valid amount typed,
  /// the limit is the typed one (a preview; it is saved with Done).
  BudgetStatus? get status {
    final b = budget;
    if (b == null) return null;
    final typed = _editing ? _parse(_draft) : null;
    return repository.budgetStatus(b, amountInMain: typed);
  }

  // Expenses

  TransactionFilter get filter => _filter;

  TransactionPage get result =>
      _result ??= repository.searchTransactions(_filter, page: _page);

  int get page => result.page;

  /// Accounts or amounts chosen on top of what the budget fixes.
  int get activeFilterCount =>
      (_filter.accountIds.isEmpty ? 0 : 1) + (_filter.hasAmountRange ? 1 : 0);

  /// Search text or filters beyond the budget's own.
  bool get isRefined => _filter != baseFilter;

  void setQuery(String query) => _setFilter(_filter.copyWith(query: query));

  /// Applies the filters chosen in the sheet; the search text stays.
  void applyFilter(TransactionFilter filter) =>
      _setFilter(filter.copyWith(query: _filter.query));

  void removeAccounts() => _setFilter(_filter.copyWith(accountIds: const {}));

  void removeAmount() => _setFilter(_filter.withAmountRange(null, null));

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

  // Edit mode

  bool get isEditing => _editing;
  String get draft => _draft;

  /// Set once Done was tried with an amount that cannot be saved; cleared
  /// when the text changes.
  BudgetAmountError? get amountError => _error;

  /// Starts editing with [initialText] (the current amount) in the field.
  void startEditing(String initialText) {
    _editing = true;
    _draft = initialText;
    _error = null;
    notifyListeners();
  }

  void setDraft(String text) {
    _draft = text;
    _error = null;
    notifyListeners();
  }

  /// Leaves edit mode and forgets what was typed.
  void cancelEditing() {
    _editing = false;
    _error = null;
    notifyListeners();
  }

  /// The field lost focus: checks the typed amount and shows why it cannot be
  /// used, if so. The text stays as typed until Done.
  void checkAmount() {
    if (!_editing) return;
    final error = _validate(_draft);
    if (error != _error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Saves the typed amount and leaves edit mode. With an amount that is
  /// empty, not a number, zero or negative nothing is saved, edit mode stays
  /// and [amountError] says why. Returns whether it was saved.
  bool save() {
    final error = _validate(_draft);
    if (error != null) {
      _error = error;
      notifyListeners();
      return false;
    }
    repository.updateBudgetAmount(budgetId, _parse(_draft)!);
    _editing = false;
    _error = null;
    notifyListeners();
    return true;
  }

  /// Removes the budget; the page has to close.
  void delete() {
    _deleted = true;
    _editing = false;
    repository.deleteBudget(budgetId);
  }

  /// The amount in a text field: a comma or a point as decimal separator.
  /// Null when it is not a number.
  static double? _parse(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value != null && value.isFinite && value > 0 ? value : null;
  }

  static BudgetAmountError? _validate(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite) return BudgetAmountError.required;
    if (value <= 0) return BudgetAmountError.notPositive;
    return null;
  }
}
