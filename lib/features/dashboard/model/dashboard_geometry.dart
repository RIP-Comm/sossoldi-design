// Where each widget sits on the grid, and which size a resize drag lands on.
// Pure geometry, no widgets: easy to test and shared by view and edit mode.

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'dashboard_layout.dart';

@immutable
class DashboardPlacement {
  const DashboardPlacement(this.item, this.rect);

  final DashboardItem item;

  /// Position and size in the grid, origin at the top-left of the first
  /// widget.
  final Rect rect;
}

@immutable
class DashboardGeometry {
  const DashboardGeometry(this.placements, this.height);

  final List<DashboardPlacement> placements;

  /// Total height of the grid.
  final double height;
}

/// Lays out [layout] on a grid [width] wide: S takes a column, M and L the
/// whole width; a row is [rowHeight] high (two rows plus a gap for L).
DashboardGeometry computeDashboardGeometry(
  DashboardLayout layout, {
  required double width,
  required double rowHeight,
  required double gap,
}) {
  final columns = DashboardLayout.columns;
  final cellWidth = (width - gap * (columns - 1)) / columns;
  final placements = <DashboardPlacement>[];
  var y = 0.0;
  for (final row in layout.rows) {
    final height = rowHeight * row.rows + gap * (row.rows - 1);
    var x = 0.0;
    for (final item in row.items) {
      final w = item.size.columns * cellWidth + (item.size.columns - 1) * gap;
      placements.add(DashboardPlacement(item, Rect.fromLTWH(x, y, w, height)));
      x += w + gap;
    }
    y += height + gap;
  }
  return DashboardGeometry(placements, layout.rows.isEmpty ? 0 : y - gap);
}

/// The size a widget snaps to while its bottom-right handle is dragged by
/// [delta] from the size it had when the drag started. Only [supported]
/// sizes are candidates; the nearest one wins, and on a tie the starting
/// size is kept.
DashboardWidgetSize sizeForResizeDrag({
  required DashboardWidgetSize start,
  required Offset delta,
  required double cellWidth,
  required double rowHeight,
  required double gap,
  required Set<DashboardWidgetSize> supported,
}) {
  final startWidth = start.columns * cellWidth + (start.columns - 1) * gap;
  final startHeight = start.rows * rowHeight + (start.rows - 1) * gap;
  // The dragged corner, expressed in grid cells.
  final columns = (startWidth + delta.dx + gap) / (cellWidth + gap);
  final rows = (startHeight + delta.dy + gap) / (rowHeight + gap);

  double distance(DashboardWidgetSize s) {
    final dc = s.columns - columns;
    final dr = s.rows - rows;
    return dc * dc + dr * dr;
  }

  var best = supported.contains(start) ? start : supported.first;
  var bestDistance = distance(best);
  for (final size in DashboardWidgetSize.values) {
    if (!supported.contains(size)) continue;
    final d = distance(size);
    if (d < bestDistance - 1e-9) {
      best = size;
      bestDistance = d;
    }
  }
  return best;
}

/// Where a widget dragged to [center] (in grid coordinates) would land:
/// the index it should take among the others. The candidate whose slot is
/// nearest to [center] wins; ties keep the current position, so the layout
/// does not flicker. Which widgets can sit side by side is decided by the
/// layout itself (only two S share a row).
int insertionIndexFor({
  required DashboardLayout layout,
  required String itemId,
  required Offset center,
  required double width,
  required double rowHeight,
  required double gap,
}) {
  final currentIndex = layout.items.indexWhere((i) => i.id == itemId);
  if (currentIndex < 0) return 0;
  final moving = layout.items[currentIndex];
  final others = [
    for (final item in layout.items)
      if (item.id != itemId) item,
  ];

  double distanceAt(int index) {
    final candidate = [...others]..insert(index, moving);
    final geometry = computeDashboardGeometry(
      DashboardLayout(candidate),
      width: width,
      rowHeight: rowHeight,
      gap: gap,
    );
    final rect = geometry.placements
        .firstWhere((p) => p.item.id == itemId)
        .rect;
    return (rect.center - center).distanceSquared;
  }

  var best = currentIndex;
  var bestDistance = distanceAt(currentIndex);
  for (var i = 0; i <= others.length; i++) {
    if (i == currentIndex) continue;
    final d = distanceAt(i);
    if (d < bestDistance - 1e-6) {
      best = i;
      bestDistance = d;
    }
  }
  return best;
}
