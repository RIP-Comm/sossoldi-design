// Dashboard layout model: which widgets, in which order and at which size.
// Plain data with no UI, so edit mode can change it later and the grid
// simply redraws it.

import 'package:flutter/foundation.dart';

/// Widget sizes on the 2-column grid: S = 1x1, M = 2x1, L = 2x2.
enum DashboardWidgetSize {
  s(columns: 1, rows: 1),
  m(columns: 2, rows: 1),
  l(columns: 2, rows: 2);

  const DashboardWidgetSize({required this.columns, required this.rows});

  final int columns;
  final int rows;
}

/// One widget placed on the Dashboard.
@immutable
class DashboardItem {
  const DashboardItem({
    required this.id,
    required this.widgetId,
    required this.size,
    this.settings = const {},
  });

  /// Identifies this placement (the same widget may appear twice).
  final String id;

  /// Key of the widget in the registry.
  final String widgetId;
  final DashboardWidgetSize size;

  /// Choices of this placement (e.g. the budget type of Budget status), kept
  /// with the item so they survive reordering and resizing. In memory only.
  final Map<String, String> settings;

  DashboardItem withSize(DashboardWidgetSize size) =>
      DashboardItem(id: id, widgetId: widgetId, size: size, settings: settings);

  /// Sets [key] to [value], or removes it when [value] is null.
  DashboardItem withSetting(String key, String? value) {
    final next = {...settings};
    if (value == null) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    return DashboardItem(
      id: id,
      widgetId: widgetId,
      size: size,
      settings: Map.unmodifiable(next),
    );
  }
}

/// A grid row: one or two items side by side.
@immutable
class DashboardRow {
  const DashboardRow(this.items);

  final List<DashboardItem> items;

  /// Height of the row in grid rows (2 when it holds an L widget).
  int get rows => items.map((i) => i.size.rows).reduce((a, b) => a > b ? a : b);
}

@immutable
class DashboardLayout {
  const DashboardLayout(this.items);

  /// Number of grid columns.
  static const int columns = 2;

  final List<DashboardItem> items;

  bool get isEmpty => items.isEmpty;

  /// Appends [item]. With the row wrapping below, an S after a lone S sits
  /// beside it, anything else starts a new row.
  DashboardLayout add(DashboardItem item) => DashboardLayout([...items, item]);

  DashboardLayout remove(String itemId) => DashboardLayout([
    for (final item in items)
      if (item.id != itemId) item,
  ]);

  /// Moves the item so that it ends up at [index] in the new order.
  DashboardLayout move(String itemId, int index) {
    final moving = items.where((i) => i.id == itemId).firstOrNull;
    if (moving == null) return this;
    final others = [
      for (final item in items)
        if (item.id != itemId) item,
    ];
    others.insert(index.clamp(0, others.length), moving);
    return DashboardLayout(others);
  }

  DashboardLayout setSetting(String itemId, String key, String? value) =>
      DashboardLayout([
        for (final item in items)
          item.id == itemId ? item.withSetting(key, value) : item,
      ]);

  DashboardLayout resize(String itemId, DashboardWidgetSize size) =>
      DashboardLayout([
        for (final item in items)
          item.id == itemId ? item.withSize(size) : item,
      ]);

  /// Items in order, left to right, wrapped into rows: two S widgets in a
  /// row sit side by side, M and L take the whole row, and a lone S stays
  /// on the left.
  List<DashboardRow> get rows {
    final rows = <DashboardRow>[];
    var current = <DashboardItem>[];
    var used = 0;
    for (final item in items) {
      if (used + item.size.columns > columns) {
        rows.add(DashboardRow(current));
        current = [];
        used = 0;
      }
      current.add(item);
      used += item.size.columns;
    }
    if (current.isNotEmpty) rows.add(DashboardRow(current));
    return rows;
  }
}
