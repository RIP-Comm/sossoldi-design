// The phone with the real app inside, at its size in logical pixels (scaled
// down only when the window is too small). In Inspect mode the pointer picks
// boxes instead of tapping them; the mouse wheel still scrolls the app.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../inspect/inspection.dart';
import '../inspect/measure_painter.dart';
import '../inspect/node_properties.dart';
import '../inspector_controller.dart';
import 'device_spec.dart';

class DeviceStage extends StatefulWidget {
  const DeviceStage({super.key, required this.controller});

  final InspectorController controller;

  @override
  State<DeviceStage> createState() => DeviceStageState();
}

class DeviceStageState extends State<DeviceStage>
    with SingleTickerProviderStateMixin {
  final _screenKey = GlobalKey();

  /// Repaints the measures every frame: the app moves (scroll, animations).
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  InspectorController get _c => widget.controller;

  (int, DeviceSpec)? _appFor;
  Widget? _app;

  /// The render tree of the screen; null before the first frame.
  Inspection? get inspection {
    final element = _screenKey.currentContext as Element?;
    return element == null ? null : Inspection(element);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  InspectedNode? _pick(Offset position) =>
      inspection?.pick(position, component: _c.pickComponents);

  Rect? _rect(InspectedNode? node) {
    if (node == null || !node.box.attached) return null;
    return inspection?.rectOf(node);
  }

  EdgeInsets? _padding() {
    final node = _c.selected;
    final i = inspection;
    if (node == null || i == null || !node.box.attached) return null;
    return readProperties(i, node).padding;
  }

  /// The wheel scrolls the scrollable under the pointer, as in Interact mode.
  void _scroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final node = inspection?.pick(event.localPosition);
    final element = node?.element;
    if (element == null) return;
    var state = Scrollable.maybeOf(element);
    while (state != null) {
      final vertical = state.position.axis == Axis.vertical;
      final delta = vertical ? event.scrollDelta.dy : event.scrollDelta.dx;
      if (delta != 0 &&
          (delta > 0
              ? state.position.pixels < state.position.maxScrollExtent
              : state.position.pixels > state.position.minScrollExtent)) {
        state.position.pointerScroll(delta);
        return;
      }
      state = Scrollable.maybeOf(state.context);
    }
  }

  Widget _wrapApp(BuildContext context, Widget? child, DeviceSpec device) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        size: device.size,
        padding: device.padding,
        viewPadding: device.padding,
        viewInsets: EdgeInsets.zero,
      ),
      child: Theme(
        // iOS scrolling, transitions and controls, as on the phone.
        data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
        child: ScrollConfiguration(
          behavior: const _TouchLikeScroll(),
          child: child!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final device = _c.device;
    final inspecting = _c.mode == InspectorMode.inspect;
    const bezel = SossoldiSpacing.m;
    const band = SossoldiSpacing.xs;

    // The same widget while scene and device stay: selecting does not
    // rebuild the app.
    if (_appFor != (_c.generation, device)) {
      _appFor = (_c.generation, device);
      _app = SossoldiApp(
        key: ValueKey('app-${_c.generation}'),
        state: _c.app,
        entry: _c.scene.entry,
        builder: (context, child) => _wrapApp(context, child, device),
      );
    }
    final app = _app!;

    final screen = SizedBox.fromSize(
      size: device.size,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: inspecting,
            child: KeyedSubtree(key: _screenKey, child: app),
          ),
          if (device.island)
            Positioned(
              top: 11,
              left: (device.size.width - 124) / 2,
              child: IgnorePointer(
                child: Container(
                  width: 124,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SossoldiPrimitives.grey5,
                    borderRadius: BorderRadius.circular(SossoldiRadius.max),
                  ),
                ),
              ),
            ),
          if (inspecting)
            Positioned.fill(
              child: Listener(
                onPointerSignal: _scroll,
                child: MouseRegion(
                  cursor: SystemMouseCursors.precise,
                  onHover: (e) => _c.hover(_pick(e.localPosition)),
                  onExit: (_) => _c.hover(null),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (e) => _c.select(_pick(e.localPosition)),
                    child: CustomPaint(
                      painter: MeasurePainter(
                        repaint: _ticker,
                        colors: colors,
                        labelStyle: context.typography.labelBoldSmall,
                        selected: () => _rect(_c.selected),
                        hovered: () => _rect(_c.hovered),
                        padding: _padding,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // As on the phone: a black bezel (the same black as the Dynamic Island)
    // inside a thin titanium band, which stands out on light and dark.
    final outer = device.cornerRadius + bezel + band;
    final framed = Container(
      padding: const EdgeInsets.all(band),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outer),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SossoldiPrimitives.grey80,
            SossoldiPrimitives.grey50,
            SossoldiPrimitives.grey70,
            SossoldiPrimitives.grey40,
          ],
        ),
        boxShadow: SossoldiShadows.m,
      ),
      child: Container(
        padding: const EdgeInsets.all(bezel),
        decoration: BoxDecoration(
          color: SossoldiPrimitives.grey5,
          borderRadius: BorderRadius.circular(outer - band),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(device.cornerRadius),
          // Its own layer: the blur under the status bar (a backdrop filter)
          // reads only the screen, as on the phone, not the frame around it.
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(_identity),
            child: screen,
          ),
        ),
      ),
    );

    final zoom = _c.zoom;
    if (zoom == null) return FittedBox(fit: BoxFit.scaleDown, child: framed);
    const edge = (bezel + band) * 2;
    final size = device.size + const Offset(edge, edge);
    // A fixed zoom may not fit: the stage scrolls.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: SizedBox(
                width: size.width * zoom,
                height: size.height * zoom,
                child: FittedBox(child: framed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _identity = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Mouse drags scroll like a finger, as on the phone.
class _TouchLikeScroll extends ScrollBehavior {
  const _TouchLikeScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.iOS;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
