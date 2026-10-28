// The Dashboard grid, in view and edit mode.
//
// Every widget is a Positioned child of one Stack, placed by
// computeDashboardGeometry. When the layout changes the new rectangles are
// animated (AnimatedPositioned), which gives the "other widgets slide into
// place" effect for free when one is removed, resized or added.
//
// The grid is as wide as the screen and insets its content by [padding]
// itself: the remove badge and the resize handle stick out of the widget by
// a few pixels, and a Stack only receives taps inside its own bounds.
//
// Edit mode: widgets wiggle (one shared controller, each widget with its
// own phase, rotation only so the content is not repainted), the remove
// badge sits top-left and the resize handle bottom-right.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'model/dashboard_geometry.dart';
import 'model/dashboard_layout.dart';
import 'registry/dashboard_widget_registry.dart';

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({
    super.key,
    required this.layout,
    required this.registry,
    this.editing = false,
    this.onLongPressWidget,
    this.onRemove,
    this.onResize,
    this.onReorder,
    this.padding = SossoldiSpacing.l,
  });

  final DashboardLayout layout;
  final DashboardWidgetRegistry registry;
  final bool editing;

  /// View mode: long press on a widget (enters edit mode).
  final VoidCallback? onLongPressWidget;
  final ValueChanged<String>? onRemove;
  final void Function(String itemId, DashboardWidgetSize size)? onResize;

  /// Edit mode: a widget was dragged to a new place; [index] is its position
  /// in the new order.
  final void Function(String itemId, int index)? onReorder;

  /// Space around the widgets inside the grid.
  final double padding;

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

/// A widget that was just removed and is still fading out.
class _Ghost {
  _Ghost(this.item, this.rect);

  final DashboardItem item;
  final Rect rect;
}

class _DashboardGridState extends State<DashboardGrid>
    with SingleTickerProviderStateMixin {
  static const _moveDuration = Duration(milliseconds: 280);
  static const _moveCurve = Curves.easeOutCubic;
  static const _wiggleDuration = Duration(milliseconds: 360);

  /// About one degree, "light" as asked.
  static const _wiggleAmplitude = math.pi / 180;

  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: _wiggleDuration,
  );

  final List<_Ghost> _ghosts = [];
  double _contentWidth = 0;

  /// Widgets present at the start do not play the "appear" animation.
  late final Set<String> _initialIds = {
    for (final i in widget.layout.items) i.id,
  };

  final GlobalKey _stackKey = GlobalKey();

  // Reorder drag in progress. While it lasts the grid shows the widgets in
  // [_previewOrder]; the real layout changes only when the widget is dropped.
  String? _dragId;
  List<String> _previewOrder = const [];
  Offset _grab = Offset.zero;
  Offset _pointerGlobal = Offset.zero;
  Rect _dragRect = Rect.zero;
  Timer? _autoScroll;

  // Resize drag in progress.
  String? _resizingId;
  Offset _resizeStartPointer = Offset.zero;
  DashboardWidgetSize _resizeStartSize = DashboardWidgetSize.s;

  @override
  void initState() {
    super.initState();
    _syncWiggle();
  }

  @override
  void didUpdateWidget(DashboardGrid old) {
    super.didUpdateWidget(old);
    if (old.editing != widget.editing) _syncWiggle();
    // Keep removed widgets on screen while they fade out.
    final remaining = {for (final i in widget.layout.items) i.id};
    if (_contentWidth > 0) {
      final before = _geometry(old.layout);
      for (final p in before.placements) {
        if (!remaining.contains(p.item.id)) {
          _ghosts.add(_Ghost(p.item, p.rect));
        }
      }
    }
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _wiggle.dispose();
    super.dispose();
  }

  void _syncWiggle() {
    final reduce = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (widget.editing && !reduce) {
      _wiggle.repeat();
    } else {
      _wiggle.stop();
      _wiggle.value = 0;
    }
  }

  DashboardGeometry _geometry(DashboardLayout layout) =>
      computeDashboardGeometry(
        layout,
        width: _contentWidth,
        rowHeight: SossoldiWidgetGrid.rowHeight,
        gap: SossoldiWidgetGrid.gap,
      );

  double get _cellWidth =>
      (_contentWidth - SossoldiWidgetGrid.gap * (DashboardLayout.columns - 1)) /
      DashboardLayout.columns;

  // Reorder

  DashboardLayout _shownLayout() {
    if (_dragId == null) return widget.layout;
    final byId = {for (final i in widget.layout.items) i.id: i};
    return DashboardLayout([
      for (final id in _previewOrder)
        if (byId[id] != null) byId[id]!,
    ]);
  }

  /// Pointer position in grid content coordinates (inside the padding).
  Offset _toContent(Offset global) {
    final box = _stackKey.currentContext!.findRenderObject()! as RenderBox;
    return box.globalToLocal(global) - Offset(widget.padding, widget.padding);
  }

  void _startDrag(DashboardItem item, Offset global) {
    final placement = _geometry(widget.layout).placements
        .firstWhere((p) => p.item.id == item.id);
    HapticFeedback.mediumImpact();
    setState(() {
      _dragId = item.id;
      _previewOrder = [for (final i in widget.layout.items) i.id];
      _pointerGlobal = global;
      _grab = _toContent(global) - placement.rect.topLeft;
      _dragRect = placement.rect;
    });
    _autoScroll = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _autoScrollTick(),
    );
  }

  void _moveDrag(Offset global) {
    _pointerGlobal = global;
    _updateDrag();
  }

  void _updateDrag() {
    final id = _dragId;
    if (id == null || !mounted) return;
    final rect = (_toContent(_pointerGlobal) - _grab) & _dragRect.size;
    final shown = _shownLayout();
    final index = insertionIndexFor(
      layout: shown,
      itemId: id,
      center: rect.center,
      width: _contentWidth,
      rowHeight: SossoldiWidgetGrid.rowHeight,
      gap: SossoldiWidgetGrid.gap,
    );
    final current = _previewOrder.indexOf(id);
    setState(() {
      _dragRect = rect;
      if (index != current) {
        HapticFeedback.selectionClick();
        _previewOrder = [..._previewOrder]
          ..remove(id)
          ..insert(index, id);
      }
    });
  }

  void _endDrag({required bool commit}) {
    final id = _dragId;
    if (id == null) return;
    _autoScroll?.cancel();
    _autoScroll = null;
    final index = _previewOrder.indexOf(id);
    final changed = index != widget.layout.items.indexWhere((i) => i.id == id);
    setState(() => _dragId = null);
    if (commit && changed) widget.onReorder?.call(id, index);
  }

  /// Scrolls the page while a widget is held near its top or bottom edge.
  void _autoScrollTick() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null || _dragId == null) return;
    final box = scrollable.context.findRenderObject()! as RenderBox;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    const zone = 80.0;
    const maxStep = 14.0;
    var delta = 0.0;
    if (_pointerGlobal.dy < top + zone) {
      delta = -(top + zone - _pointerGlobal.dy) / zone * maxStep;
    } else if (_pointerGlobal.dy > bottom - zone) {
      delta = (_pointerGlobal.dy - (bottom - zone)) / zone * maxStep;
    }
    if (delta == 0) return;
    final position = scrollable.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) {
      position.jumpTo(target);
      _updateDrag();
    }
  }

  // Resize

  void _startResize(DashboardItem item, Offset pointer) {
    _resizingId = item.id;
    _resizeStartPointer = pointer;
    _resizeStartSize = item.size;
    HapticFeedback.selectionClick();
  }

  void _updateResize(Offset pointer) {
    final id = _resizingId;
    if (id == null) return;
    final item = widget.layout.items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    final supported =
        widget.registry.byId(item.widgetId)?.supportedSizes ?? {item.size};
    final size = sizeForResizeDrag(
      start: _resizeStartSize,
      delta: pointer - _resizeStartPointer,
      cellWidth: _cellWidth,
      rowHeight: SossoldiWidgetGrid.rowHeight,
      gap: SossoldiWidgetGrid.gap,
      supported: supported,
    );
    if (size != item.size) {
      HapticFeedback.selectionClick();
      widget.onResize?.call(id, size);
    }
  }

  void _endResize() => _resizingId = null;

  /// For screen readers: step to the next/previous supported size.
  void _stepSize(DashboardItem item, int direction) {
    final supported =
        widget.registry.byId(item.widgetId)?.supportedSizes ?? {item.size};
    final sizes = DashboardWidgetSize.values.where(supported.contains).toList();
    final index = sizes.indexOf(item.size) + direction;
    if (index >= 0 && index < sizes.length) {
      widget.onResize?.call(item.id, sizes[index]);
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : _moveDuration;
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = widget.padding;
        _contentWidth = constraints.maxWidth - 2 * pad;
        final geometry = _geometry(_shownLayout());
        // The dragged widget is drawn last, on top of the others.
        final placements = [
          for (final p in geometry.placements)
            if (p.item.id != _dragId) p,
          for (final p in geometry.placements)
            if (p.item.id == _dragId) p,
        ];
        final height = geometry.height + 2 * pad;
        return TweenAnimationBuilder<double>(
          tween: Tween(end: height),
          duration: duration,
          curve: _moveCurve,
          builder: (context, animatedHeight, _) => SizedBox(
            width: constraints.maxWidth,
            height: animatedHeight,
            child: Stack(
              key: _stackKey,
              clipBehavior: Clip.none,
              children: [
                for (final ghost in _ghosts)
                  Positioned.fromRect(
                    key: ValueKey('ghost_${ghost.item.id}'),
                    rect: ghost.rect.shift(Offset(pad, pad)),
                    child: _FadeOut(
                      onDone: () {
                        if (mounted) setState(() => _ghosts.remove(ghost));
                      },
                      child: _content(context, ghost.item),
                    ),
                  ),
                for (final placement in placements)
                  AnimatedPositioned(
                    key: ValueKey(placement.item.id),
                    // The held widget follows the finger without delay; once
                    // dropped it glides into its slot.
                    duration: placement.item.id == _dragId
                        ? Duration.zero
                        : duration,
                    curve: _moveCurve,
                    // The box is [pad] larger than the widget on every side,
                    // so the badge and handle that stick out are inside it.
                    left: placement.item.id == _dragId
                        ? _dragRect.left
                        : placement.rect.left,
                    top: placement.item.id == _dragId
                        ? _dragRect.top
                        : placement.rect.top,
                    width: placement.rect.width + 2 * pad,
                    height: placement.rect.height + 2 * pad,
                    child: _GridItem(
                      bleed: pad,
                      lifted: placement.item.id == _dragId,
                      onDragStart: (p) => _startDrag(placement.item, p),
                      onDragMove: _moveDrag,
                      onDragEnd: (commit) => _endDrag(commit: commit),
                      item: placement.item,
                      targetSize: placement.rect.size,
                      animateIn: !_initialIds.contains(placement.item.id),
                      editing: widget.editing,
                      wiggle: _wiggle,
                      amplitude: _wiggleAmplitude,
                      content: _content(context, placement.item),
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        widget.onLongPressWidget?.call();
                      },
                      onRemove: () {
                        HapticFeedback.lightImpact();
                        widget.onRemove?.call(placement.item.id);
                      },
                      onResizeStart: (p) => _startResize(placement.item, p),
                      onResizeUpdate: _updateResize,
                      onResizeEnd: _endResize,
                      onStep: (d) => _stepSize(placement.item, d),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, DashboardItem item) {
    final built = widget.registry
        .byId(item.widgetId)
        ?.build(context, item.size);
    assert(
      built != null,
      'No "${item.widgetId}" widget of size ${item.size.name} in the registry',
    );
    return built ?? const SizedBox.shrink();
  }
}

/// One widget on the grid with its edit-mode decorations.
class _GridItem extends StatelessWidget {
  const _GridItem({
    required this.bleed,
    required this.lifted,
    required this.onDragStart,
    required this.onDragMove,
    required this.onDragEnd,
    required this.item,
    required this.targetSize,
    required this.animateIn,
    required this.editing,
    required this.wiggle,
    required this.amplitude,
    required this.content,
    required this.onLongPress,
    required this.onRemove,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onStep,
  });

  /// Space around the widget inside this item's box.
  final double bleed;

  /// Held by the finger for reordering: raised, no wiggle, no controls.
  final bool lifted;
  final ValueChanged<Offset> onDragStart;
  final ValueChanged<Offset> onDragMove;
  final ValueChanged<bool> onDragEnd;
  final DashboardItem item;

  /// Size the widget is moving to; see [_AtTargetSize].
  final Size targetSize;

  /// Plays the appear animation (widgets added after the grid was built).
  final bool animateIn;
  final bool editing;
  final Animation<double> wiggle;
  final double amplitude;
  final Widget content;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;
  final ValueChanged<Offset> onResizeStart;
  final ValueChanged<Offset> onResizeUpdate;
  final VoidCallback onResizeEnd;
  final ValueChanged<int> onStep;

  /// Each widget wiggles out of step with the others.
  double get _phase => (item.id.hashCode & 0xff) / 0xff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Appear: a new widget grows and fades in. TweenAnimationBuilder only
    // uses `begin` the first time, so existing widgets are not affected.
    // The tree above the gesture detector must keep its shape while a widget
    // is held (only values change), or the drag in progress would be lost.
    final body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Long press enters edit mode; in edit mode it picks the widget up.
      onLongPressStart: (d) =>
          editing ? onDragStart(d.globalPosition) : onLongPress(),
      onLongPressMoveUpdate: editing
          ? (d) => onDragMove(d.globalPosition)
          : null,
      onLongPressEnd: editing ? (_) => onDragEnd(true) : null,
      onLongPressCancel: editing ? () => onDragEnd(false) : null,
      child: Transform.scale(
        scale: lifted ? 1.04 : 1,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(SossoldiRadius.l),
            ),
            shadows: lifted ? SossoldiShadows.m : const [],
          ),
          child: RepaintBoundary(
            child: IgnorePointer(
              ignoring: editing,
              child: _AtTargetSize(size: targetSize, child: content),
            ),
          ),
        ),
      ),
    );

    final decorated = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Padding(padding: EdgeInsets.all(bleed), child: body),
        ),
        if (editing && !lifted) ...[
          Positioned(
            // 9px out of the widget's corner (Figma), minus the touch margin
            // of the badge.
            left: bleed - 9 - SossoldiRemoveBadge.slop,
            top: bleed - 9 - SossoldiRemoveBadge.slop,
            child: SossoldiRemoveBadge(
              onPressed: onRemove,
              semanticLabel: l10n.removeWidget,
            ),
          ),
          Positioned(
            // The handle sticks out 7px right and 5px down, plus 8px of touch
            // margin.
            right: bleed - 7 - 8,
            bottom: bleed - 5 - 8,
            child: Semantics(
              label: l10n.resizeWidget,
              onIncrease: () => onStep(1),
              onDecrease: () => onStep(-1),
              child: RawGestureDetector(
                // Wins the gesture arena at once so the page does not scroll
                // while the handle is dragged; the movement itself is read
                // from the raw pointer events below.
                gestures: {
                  EagerGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        EagerGestureRecognizer
                      >(
                        EagerGestureRecognizer.new,
                        (EagerGestureRecognizer instance) {},
                      ),
                },
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) => onResizeStart(e.position),
                  onPointerMove: (e) => onResizeUpdate(e.position),
                  onPointerUp: (_) => onResizeEnd(),
                  onPointerCancel: (_) => onResizeEnd(),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SossoldiResizeHandle(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animateIn ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, appear, child) => Opacity(
        opacity: appear.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.85 + 0.15 * appear, child: child),
      ),
      child: AnimatedBuilder(
        animation: wiggle,
        child: decorated,
        builder: (context, child) {
          if (!editing) return child!;
          // wiggle runs 0..1 over one swing period; the held widget stays
          // still (but keeps the Transform, so the drag is not interrupted).
          final angle = lifted
              ? 0.0
              : math.sin((wiggle.value + _phase) * 2 * math.pi) * amplitude;
          return Transform.rotate(angle: angle, child: child);
        },
      ),
    );
  }
}

/// While a widget is resized its box animates from the old size to the new
/// one, but the content is already the new variant (S, M or L), which only
/// lays out properly at its own size. So the content is laid out at the
/// target size and the animating box reveals (or clips) it, with the same
/// rounded corners as the card.
class _AtTargetSize extends StatelessWidget {
  const _AtTargetSize({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settled =
            (constraints.maxWidth - size.width).abs() < 0.5 &&
            (constraints.maxHeight - size.height).abs() < 0.5;
        if (settled) return child;
        return ClipRSuperellipse(
          borderRadius: BorderRadius.circular(SossoldiRadius.l),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: size.width,
            maxWidth: size.width,
            minHeight: size.height,
            maxHeight: size.height,
            child: child,
          ),
        );
      },
    );
  }
}

/// Fades and shrinks its child away, then calls [onDone].
class _FadeOut extends StatelessWidget {
  const _FadeOut({required this.child, required this.onDone});

  final Widget child;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        onEnd: onDone,
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
        ),
        child: child,
      ),
    );
  }
}
