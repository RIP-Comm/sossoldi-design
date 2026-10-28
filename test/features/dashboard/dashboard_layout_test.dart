import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_registry.dart';

DashboardItem _item(String id, DashboardWidgetSize size) =>
    DashboardItem(id: id, widgetId: 'w', size: size);

/// Row contents as ids, e.g. [['a', 'b'], ['c']].
List<List<String>> _ids(List<DashboardItem> items) => [
  for (final row in DashboardLayout(items).rows)
    [for (final item in row.items) item.id],
];

void main() {
  const s = DashboardWidgetSize.s;
  const m = DashboardWidgetSize.m;
  const l = DashboardWidgetSize.l;

  group('rows', () {
    test('empty layout has no rows', () {
      expect(const DashboardLayout([]).rows, isEmpty);
    });

    test('two consecutive S sit side by side', () {
      expect(_ids([_item('a', s), _item('b', s)]), [
        ['a', 'b'],
      ]);
    });

    test('a lone S stays alone on the left', () {
      expect(_ids([_item('a', s)]), [
        ['a'],
      ]);
    });

    test('three S make a pair and a lone one', () {
      expect(_ids([_item('a', s), _item('b', s), _item('c', s)]), [
        ['a', 'b'],
        ['c'],
      ]);
    });

    test('M and L take the whole row', () {
      expect(_ids([_item('a', m), _item('b', l), _item('c', m)]), [
        ['a'],
        ['b'],
        ['c'],
      ]);
    });

    test('an S followed by M or L is alone and order is kept', () {
      expect(
        _ids([_item('a', s), _item('b', m), _item('c', s), _item('d', l)]),
        [
          ['a'],
          ['b'],
          ['c'],
          ['d'],
        ],
      );
    });

    test('S, S, M, S, S, L', () {
      expect(
        _ids([
          _item('a', s),
          _item('b', s),
          _item('c', m),
          _item('d', s),
          _item('e', s),
          _item('f', l),
        ]),
        [
          ['a', 'b'],
          ['c'],
          ['d', 'e'],
          ['f'],
        ],
      );
    });

    test('row height is 2 only for L', () {
      final rows = DashboardLayout([
        _item('a', s),
        _item('b', m),
        _item('c', l),
      ]).rows;
      expect(rows.map((r) => r.rows), [1, 1, 2]);
    });
  });

  group('default layout and registry', () {
    test('every default item exists in the registry at a supported size', () {
      for (final item in defaultDashboardLayout.items) {
        final definition = dashboardWidgetRegistry.byId(item.widgetId);
        expect(definition, isNotNull, reason: item.widgetId);
        expect(definition!.supports(item.size), isTrue, reason: item.id);
      }
    });

    test('default layout is one widget, size S', () {
      expect(defaultDashboardLayout.items, hasLength(1));
      expect(defaultDashboardLayout.items.single.size, s);
    });

    test('widget ids and item ids are unique', () {
      final ids = dashboardWidgetRegistry.definitions.map((d) => d.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final itemIds = defaultDashboardLayout.items.map((i) => i.id).toList();
      expect(itemIds.toSet(), hasLength(itemIds.length));
    });

    test('the two designed widgets are registered in S, M and L', () {
      final defs = dashboardWidgetRegistry.definitions;
      expect(defs.map((d) => d.id), ['monthly_balance', 'latest_transactions']);
      for (final d in defs) {
        expect(d.supportedSizes, {
          s,
          DashboardWidgetSize.m,
          DashboardWidgetSize.l,
        });
      }
    });
  });
}
