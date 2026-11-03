import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_geometry.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';

const s = DashboardWidgetSize.s;
const m = DashboardWidgetSize.m;
const l = DashboardWidgetSize.l;

DashboardItem _item(String id, DashboardWidgetSize size) =>
    DashboardItem(id: id, widgetId: 'w', size: size);

List<List<String>> _rows(DashboardLayout layout) => [
  for (final row in layout.rows) [for (final i in row.items) i.id],
];

void main() {
  // These tests count on one widget on the Dashboard.
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  group('layout operations', () {
    test('add appends; an S joins a lone S, others start a new row', () {
      var layout = DashboardLayout([_item('a', s)]);
      layout = layout.add(_item('b', s));
      expect(_rows(layout), [
        ['a', 'b'],
      ]);
      layout = layout.add(_item('c', s));
      expect(_rows(layout), [
        ['a', 'b'],
        ['c'],
      ]);
      layout = DashboardLayout([_item('a', s)]).add(_item('b', m));
      expect(_rows(layout), [
        ['a'],
        ['b'],
      ]);
    });

    test('remove drops the item and re-wraps the others', () {
      final layout = DashboardLayout([
        _item('a', s),
        _item('b', m),
        _item('c', s),
      ]).remove('b');
      expect(_rows(layout), [
        ['a', 'c'],
      ]);
      expect(layout.remove('a').remove('c').isEmpty, isTrue);
    });

    test('resize changes only that item', () {
      final layout = DashboardLayout([_item('a', s), _item('b', s)])
          .resize('a', l);
      expect(layout.items.map((i) => i.size), [l, s]);
      expect(_rows(layout), [
        ['a'],
        ['b'],
      ]);
    });
  });

  group('geometry', () {
    // width 358, gap 16 -> cell 171.
    DashboardGeometry geometry(List<DashboardItem> items) =>
        computeDashboardGeometry(
          DashboardLayout(items),
          width: 358,
          rowHeight: 170,
          gap: 16,
        );

    test('S, S, M, L', () {
      final g = geometry([
        _item('a', s),
        _item('b', s),
        _item('c', m),
        _item('d', l),
      ]);
      Rect rect(String id) =>
          g.placements.firstWhere((p) => p.item.id == id).rect;
      expect(rect('a'), const Rect.fromLTWH(0, 0, 171, 170));
      expect(rect('b'), const Rect.fromLTWH(187, 0, 171, 170));
      expect(rect('c'), const Rect.fromLTWH(0, 186, 358, 170));
      expect(rect('d'), const Rect.fromLTWH(0, 372, 358, 356));
      expect(g.height, 372 + 356);
    });

    test('a lone S stays on the left; empty layout has no height', () {
      final g = geometry([_item('a', s)]);
      expect(g.placements.single.rect, const Rect.fromLTWH(0, 0, 171, 170));
      expect(geometry([]).height, 0);
    });
  });

  group('resize drag', () {
    DashboardWidgetSize drag(
      DashboardWidgetSize start,
      Offset delta, {
      Set<DashboardWidgetSize> supported = const {s, m, l},
    }) => sizeForResizeDrag(
      start: start,
      delta: delta,
      cellWidth: 171,
      rowHeight: 170,
      gap: 16,
      supported: supported,
    );

    test('no movement keeps the size', () {
      for (final size in DashboardWidgetSize.values) {
        expect(drag(size, Offset.zero), size);
      }
    });

    test('S grows to M, then L', () {
      expect(drag(s, const Offset(60, 0)), s);
      expect(drag(s, const Offset(120, 0)), m);
      expect(drag(s, const Offset(120, 120)), l);
    });

    test('L shrinks to M, then S', () {
      expect(drag(l, const Offset(0, -120)), m);
      expect(drag(l, const Offset(-120, -120)), s);
      expect(drag(m, const Offset(-120, 0)), s);
    });

    test('M grows to L going down', () {
      expect(drag(m, const Offset(0, 120)), l);
    });

    test('unsupported sizes are skipped', () {
      // Only S and L: M is not an option, so a diagonal drag lands on L and
      // a purely horizontal one stays on S.
      expect(drag(s, const Offset(120, 120), supported: {s, l}), l);
      expect(drag(s, const Offset(120, 0), supported: {s, l}), s);
      // Only S and M: dragging down from M stays M.
      expect(drag(m, const Offset(0, 170), supported: {s, m}), m);
      // Only one size: nothing to snap to.
      expect(drag(s, const Offset(300, 300), supported: {s}), s);
    });
  });

  group('reordering', () {
    List<String> ids(DashboardLayout l) => [for (final i in l.items) i.id];

    test('move puts the item at the given final index', () {
      final layout = DashboardLayout([
        _item('a', s),
        _item('b', m),
        _item('c', l),
      ]);
      expect(ids(layout.move('a', 2)), ['b', 'c', 'a']);
      expect(ids(layout.move('c', 0)), ['c', 'a', 'b']);
      expect(ids(layout.move('b', 1)), ['a', 'b', 'c']);
      expect(ids(layout.move('b', 99)), ['a', 'c', 'b']);
      expect(ids(layout.move('zzz', 0)), ['a', 'b', 'c']);
    });

    test('M and L never share a row with an S, two S do', () {
      final layout = DashboardLayout([
        _item('a', s),
        _item('b', m),
        _item('c', s),
        _item('d', s),
      ]);
      // Moving the last S before the M puts it beside the first S.
      expect(_rows(layout.move('d', 1)), [
        ['a', 'd'],
        ['b'],
        ['c'],
      ]);
      // Moving the M to the front leaves the three S as a pair and a lone S.
      expect(_rows(layout.move('b', 0)), [
        ['b'],
        ['a', 'c'],
        ['d'],
      ]);
    });

    test('insertion index follows the dragged widget', () {
      final layout = DashboardLayout([
        _item('a', m),
        _item('b', m),
        _item('c', m),
      ]);
      int at(String id, double y) => insertionIndexFor(
        layout: layout,
        itemId: id,
        center: Offset(179, y),
        width: 358,
        rowHeight: 170,
        gap: 16,
      );
      // Rows are 186 apart: centers at 85, 271, 457.
      expect(at('a', 85), 0);
      expect(at('a', 280), 1);
      expect(at('a', 470), 2);
      expect(at('c', 60), 0);
      expect(at('c', 450), 2);
      // Between two slots the current position is kept.
      expect(at('b', 271), 1);
    });

    test('an M moved above another M leaves the pair of S where it is', () {
      final layout = DashboardLayout([
        _item('a', s),
        _item('b', s),
        _item('c', m),
        _item('d', m),
      ]);
      // The second row is where c is now: center y 85 + 186.
      final index = insertionIndexFor(
        layout: layout,
        itemId: 'd',
        center: const Offset(179, 271),
        width: 358,
        rowHeight: 170,
        gap: 16,
      );
      expect(index, 2);
      expect(_rows(layout.move('d', index)), [
        ['a', 'b'],
        ['d'],
        ['c'],
      ]);
    });

    test('an S dragged beside a lone S pairs up with it', () {
      final layout = DashboardLayout([
        _item('a', s),
        _item('b', m),
        _item('c', s),
      ]);
      final index = insertionIndexFor(
        layout: layout,
        itemId: 'c',
        center: const Offset(270, 85),
        width: 358,
        rowHeight: 170,
        gap: 16,
      );
      expect(index, 1);
      expect(_rows(layout.move('c', index)), [
        ['a', 'c'],
        ['b'],
      ]);
    });
  });

  group('controller', () {
    test('starts with the default layout, not editing', () {
      final c = DashboardController();
      expect(c.isEditing, isFalse);
      expect(c.layout.items, isNotEmpty);
    });

    test('edit mode toggles and notifies once per change', () {
      final c = DashboardController();
      var notified = 0;
      c.addListener(() => notified++);
      c.enterEditMode();
      c.enterEditMode();
      expect(c.isEditing, isTrue);
      c.exitEditMode();
      c.exitEditMode();
      expect(c.isEditing, isFalse);
      expect(notified, 2);
    });

    test('add gives unique ids, even for the same widget', () {
      final c = DashboardController();
      c.addWidget('x', s);
      c.addWidget('x', s);
      final ids = c.layout.items.map((i) => i.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('move reorders and notifies', () {
      final c = DashboardController(
        layout: DashboardLayout([_item('a', s), _item('b', s)]),
      );
      var notified = 0;
      c.addListener(() => notified++);
      c.move('a', 1);
      expect(c.layout.items.map((i) => i.id), ['b', 'a']);
      expect(notified, 1);
    });

    test('remove, resize and an empty dashboard', () {
      final c = DashboardController();
      final id = c.layout.items.first.id;
      c.resize(id, l);
      expect(c.layout.items.first.size, l);
      c.remove(id);
      expect(c.layout.isEmpty, isTrue);
      c.addWidget('x', m);
      expect(c.layout.items.single.size, m);
    });
  });
}
