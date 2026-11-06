import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  final repo = MockRepository(now: _now);

  test('percentages add up to exactly 100 in every mode and size', () {
    for (final mode in AllocationMode.values) {
      for (final max in [null, 1, 2, 3, 5]) {
        final rows = repo.allocationBreakdown(mode, maxRows: max);
        expect(
          rows.fold(0, (s, r) => s + r.percent),
          100,
          reason: '$mode $max',
        );
      }
    }
  });

  test('the Overview slices are the ones of the widget (class view)', () {
    final overview = repo.assetAllocation(AllocationMode.assetClass);
    final rows = repo.allocationBreakdown(AllocationMode.assetClass);
    expect(rows.map((r) => r.slice.kind), overview.map((s) => s.kind));
    expect(rows.map((r) => r.slice.value), overview.map((s) => s.value));
  });

  test('Other sums what is beyond the limit', () {
    final all = repo.assetAllocation(AllocationMode.assetClass);
    final rows = repo.allocationBreakdown(
      AllocationMode.assetClass,
      maxRows: 2,
    );
    expect(rows, hasLength(3));
    expect(rows.last.slice.kind, AllocationKind.other);
    expect(
      rows.last.slice.value,
      closeTo(all.skip(2).fold(0.0, (s, e) => s + e.value), 0.011),
    );
    expect(
      rows.last.slice.share,
      closeTo(all.skip(2).fold(0.0, (s, e) => s + e.share), 1e-9),
    );
  });

  test('a lone leftover slice is not renamed Other', () {
    final all = repo.assetAllocation(AllocationMode.assetClass);
    final rows = repo.allocationBreakdown(
      AllocationMode.assetClass,
      maxRows: all.length - 1,
    );
    expect(rows.map((r) => r.slice.kind), all.map((s) => s.kind));
  });

  test('single asset view: the first six assets, then other', () {
    final rows = repo.allocationBreakdown(AllocationMode.singleAsset);
    expect(
      rows.where((r) => r.slice.kind == AllocationKind.asset),
      hasLength(6),
    );
    expect(
      rows.where((r) => r.slice.kind == AllocationKind.other),
      hasLength(1),
    );
  });

  test('a new user has no rows', () {
    final r = MockRepository.newUser(now: _now);
    expect(r.allocationBreakdown(AllocationMode.assetClass), isEmpty);
  });

  test('tiny shares keep the total at 100', () {
    // 0.4% + 0.4% + 99.2%: the small ones can round to 0, the sum stays.
    final p = MockRepository.debugWholePercents([0.004, 0.004, 0.992]);
    expect(p.fold(0, (s, e) => s + e), 100);
    expect(p.last, 99);
  });
}
