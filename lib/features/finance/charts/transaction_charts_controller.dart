import 'package:flutter/foundation.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/category.dart';
import '../../../mock/models/transaction_breakdown.dart';
import '../../../mock/models/transaction_time_range.dart';

/// State of Finance > Transactions > Charts for the session: time range,
/// Expenses/Income, account and category filters, and the granularity of
/// the breakdown over time. The numbers come from
/// [MockRepository.transactionBreakdown]; nothing is computed here.
class TransactionChartsController extends ChangeNotifier {
  TransactionChartsController(this.repository) {
    repository.addListener(_repositoryChanged);
  }

  /// The main currency changed: the amounts have to be read again.
  void _repositoryChanged() {
    _breakdown = null;
    notifyListeners();
  }

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }

  final MockRepository repository;

  TransactionTimeRange _range = TransactionTimeRange.currentMonth;
  TransactionKind _kind = TransactionKind.expense;
  Set<String> _accountIds = const {};
  Set<String> _categoryIds = const {};
  TransactionGranularity? _granularity;
  TransactionBreakdown? _breakdown;

  TransactionTimeRange get range => _range;
  TransactionKind get kind => _kind;
  Set<String> get accountIds => _accountIds;

  /// The selected categories that belong to the current Expenses/Income
  /// choice; the others (picked while looking at the other kind) are kept
  /// but have no effect here.
  Set<String> get categoryIds => {
    for (final id in _categoryIds)
      if (_belongsToKind(id)) id,
  };

  /// All the selected categories, whatever their kind (what the filters
  /// sheet edits).
  Set<String> get allSelectedCategoryIds => _categoryIds;

  /// The granularity actually in use: the user's choice if it suits the
  /// range, otherwise the default for the range.
  TransactionGranularity get granularity => breakdown.granularity;

  /// Which granularities the range allows (the others are disabled).
  List<TransactionGranularity> get allowedGranularities =>
      _range.resolve(repository.today).allowedGranularities;

  /// Number of filters that apply now (the dot on the filter button).
  int get activeFilterCount =>
      (_accountIds.isEmpty ? 0 : 1) + (categoryIds.isEmpty ? 0 : 1);

  TransactionBreakdown get breakdown =>
      _breakdown ??= repository.transactionBreakdown(
        range: _range,
        kind: _kind,
        accountIds: _accountIds,
        categoryIds: categoryIds,
        granularity: _granularity,
      );

  bool _belongsToKind(String categoryId) =>
      repository.category(categoryId).type ==
      (_kind == TransactionKind.expense
          ? CategoryType.expense
          : CategoryType.income);

  /// A new range goes back to its default granularity.
  void setRange(TransactionTimeRange range) {
    if (range == _range) return;
    _update(() {
      _range = range;
      _granularity = null;
    });
  }

  void setKind(TransactionKind kind) {
    if (kind == _kind) return;
    _update(() => _kind = kind);
  }

  void setGranularity(TransactionGranularity granularity) {
    if (!allowedGranularities.contains(granularity)) return;
    if (granularity == this.granularity) return;
    _update(() => _granularity = granularity);
  }

  void applyFilters({
    required Set<String> accountIds,
    required Set<String> categoryIds,
  }) {
    if (setEquals(accountIds, _accountIds) &&
        setEquals(categoryIds, _categoryIds)) {
      return;
    }
    _update(() {
      _accountIds = {...accountIds};
      _categoryIds = {...categoryIds};
    });
  }

  void clearFilters() =>
      applyFilters(accountIds: const {}, categoryIds: const {});

  void _update(VoidCallback change) {
    change();
    _breakdown = null;
    notifyListeners();
  }
}
