import 'package:flutter/foundation.dart';

import '../../mock/mock_repository.dart';
import '../../mock/models/movement_edit.dart';
import '../../mock/models/portfolio.dart';

enum InvestmentsTab { overview, positions, movements }

/// State of the Investments page for the session: the selected tab, the
/// period of the market value chart and how the allocation is split. Kept by
/// the app shell, so it survives tab changes. Every number comes from the
/// repository.
class InvestmentsController extends ChangeNotifier {
  InvestmentsController(this.repository) {
    repository.addListener(notifyListeners);
  }

  final MockRepository repository;

  /// How long the loader of the pull-to-refresh stays on.
  static const Duration refreshDelay = Duration(milliseconds: 900);

  InvestmentsTab _tab = InvestmentsTab.overview;
  ValuePeriod _period = ValuePeriod.day;
  AllocationMode _allocation = AllocationMode.assetClass;
  String _positionsQuery = '';
  Set<PositionKind> _positionKinds = const {};
  BreakdownBy _breakdown = BreakdownBy.region;
  MovementFilter _movementFilter = const MovementFilter();

  InvestmentsTab get tab => _tab;
  ValuePeriod get period => _period;
  AllocationMode get allocation => _allocation;

  /// Search text of the positions list (it does not touch the rest).
  String get positionsQuery => _positionsQuery;

  /// Kinds of asset the positions list is limited to; empty: all.
  Set<PositionKind> get positionKinds => _positionKinds;
  BreakdownBy get breakdown => _breakdown;

  /// Search and filters of the movements list.
  MovementFilter get movementFilter => _movementFilter;

  /// Search or filters are on.
  bool get positionsRefined =>
      _positionsQuery.trim().isNotEmpty || _positionKinds.isNotEmpty;

  @override
  void dispose() {
    repository.removeListener(notifyListeners);
    super.dispose();
  }

  void selectTab(InvestmentsTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  void selectPeriod(ValuePeriod period) {
    if (period == _period) return;
    _period = period;
    notifyListeners();
  }

  void selectAllocation(AllocationMode mode) {
    if (mode == _allocation) return;
    _allocation = mode;
    notifyListeners();
  }

  void setPositionsQuery(String query) {
    if (query == _positionsQuery) return;
    _positionsQuery = query;
    notifyListeners();
  }

  void setPositionKinds(Set<PositionKind> kinds) {
    if (setEquals(kinds, _positionKinds)) return;
    _positionKinds = Set.unmodifiable(kinds);
    notifyListeners();
  }

  /// Back to the whole list.
  void clearPositionsFilters() {
    _positionsQuery = '';
    _positionKinds = const {};
    notifyListeners();
  }

  void setMovementFilter(MovementFilter filter) {
    if (filter == _movementFilter) return;
    _movementFilter = filter;
    notifyListeners();
  }

  void setMovementQuery(String query) =>
      setMovementFilter(_movementFilter.copyWith(query: query));

  /// Back to the default: this year, no search, no filters.
  void clearMovementFilters() => setMovementFilter(const MovementFilter());

  void selectBreakdown(BreakdownBy by) {
    if (by == _breakdown) return;
    _breakdown = by;
    notifyListeners();
  }

  /// Pull-to-refresh, valid on every tab: a short wait, then the prices move
  /// a little and the "updated" time is now.
  Future<void> refresh() async {
    await Future<void>.delayed(refreshDelay);
    repository.refreshPrices();
  }
}
