import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  final repo = MockRepository(now: _now);

  test('value and series are the ones of the Investments Overview', () {
    for (final p in ValuePeriod.values) {
      final s = repo.investmentsSnapshot(p);
      expect(s.totalValue, repo.portfolioSummary().totalValue);
      final overview = repo.marketValueSeries(p).points;
      expect(s.series.points.length, overview.length);
      expect(s.series.points.last.value, overview.last.value);
      expect(s.hasPositions, isTrue);
    }
  });

  test('daily change is last close against the previous close', () {
    final s = repo.investmentsSnapshot(ValuePeriod.month);
    final pts = repo.marketValueSeries(ValuePeriod.month).points;
    final a = pts[pts.length - 2], b = pts.last;
    final expected = (b.value - b.invested) - (a.value - a.invested);
    expect(s.daily!.amount, closeTo(expected, 0.011));
    final base = a.value + (b.invested - a.invested);
    expect(s.daily!.percent, closeTo(expected / base, 1e-3));
    // 1D period shows the same change.
    expect(
      repo.investmentsSnapshot(ValuePeriod.day).periodChange!.amount,
      s.daily!.amount,
    );
  });

  test('YTD is against the last close of the previous year', () {
    final s = repo.investmentsSnapshot(ValuePeriod.month);
    final pts = repo.marketValueSeries(ValuePeriod.year).points;
    final from = pts.lastWhere((p) => p.time.year < _now.year);
    final to = pts.last;
    final expected = (to.value - to.invested) - (from.value - from.invested);
    expect(s.yearToDate!.amount, closeTo(expected, 0.011));
    expect(
      repo.investmentsSnapshot(ValuePeriod.yearToDate).periodChange!.amount,
      s.yearToDate!.amount,
    );
  });

  test('a period change ignores buys: net of contributions', () {
    final before = repo.investmentsSnapshot(ValuePeriod.sixMonths);
    final pts = before.series.points;
    final raw = pts.last.value - pts.first.value;
    final performance = before.periodChange!.amount;
    final contributions = pts.last.invested - pts.first.invested;
    expect(performance, closeTo(raw - contributions, 0.011));
  });

  test('new user: no positions, no changes', () {
    final s = MockRepository.newUser(now: _now)
        .investmentsSnapshot(ValuePeriod.month);
    expect(s.hasPositions, isFalse);
    expect(s.daily, isNull);
    expect(s.yearToDate, isNull);
    expect(s.periodChange, isNull);
    expect(s.series.points, isEmpty);
  });

  test('a position bought today: no history, no change, no crash', () {
    final r = MockRepository.newUser(now: _now);
    final asset = r.assetCatalog.first.id;
    final res = r.addOpeningAsset(
      assetId: asset,
      quantity: 2,
      averageCost: 100,
    );
    expect(res.ok, isTrue);
    final s = r.investmentsSnapshot(ValuePeriod.year);
    expect(s.hasPositions, isTrue);
    expect(s.daily, isNull);
    expect(s.periodChange, isNull);
    expect(s.totalValue.isFinite, isTrue);
  });
}
