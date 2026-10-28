import 'package:flutter/foundation.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/portfolio.dart';
import '../investments_controller.dart';

/// State of the page of one position: the period of the price chart. The
/// numbers come from the repository; a price refresh redraws the page.
class PositionDetailController extends ChangeNotifier {
  PositionDetailController(this.repository, this.holdingId) {
    repository.addListener(notifyListeners);
  }

  final MockRepository repository;
  final String holdingId;

  ValuePeriod _period = ValuePeriod.day;
  ValuePeriod get period => _period;

  /// Null if the position no longer exists.
  PositionDetail? get detail {
    if (!repository.holdings.any((h) => h.id == holdingId)) return null;
    return repository.positionDetail(holdingId);
  }

  ValueSeries get series => repository.priceSeries(holdingId, _period);

  void selectPeriod(ValuePeriod period) {
    if (period == _period) return;
    _period = period;
    notifyListeners();
  }

  /// Pull-to-refresh, as in the Investments page.
  Future<void> refresh() async {
    await Future<void>.delayed(InvestmentsController.refreshDelay);
    repository.refreshPrices();
  }

  @override
  void dispose() {
    repository.removeListener(notifyListeners);
    super.dispose();
  }
}
