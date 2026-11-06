// Sossoldi Inspector: the prototype in a phone frame with a dev-mode panel,
// for the developers who rebuild the front end. Menu of screens on the left,
// the app in the middle, sizes, spacing and tokens of what is selected on the
// right. Built with the components of the design system.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import 'device/device_stage.dart';
import 'inspector_controller.dart';
import 'panel/inspect_panel.dart';
import 'sidebar/scene_menu.dart';
import 'toolbar/inspector_toolbar.dart';

void main() {
  runApp(const InspectorApp());
}

/// The theme of the Inspector itself (the sidebar, the panel, the toolbar) is
/// its own: light until the switch in the sidebar says otherwise, whatever the
/// device uses. The theme of the app in the phone is in the toolbar.
class InspectorApp extends StatefulWidget {
  const InspectorApp({super.key});

  @override
  State<InspectorApp> createState() => _InspectorAppState();
}

class _InspectorAppState extends State<InspectorApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sossoldi Inspector',
      debugShowCheckedModeBanner: false,
      theme: SossoldiTheme.light,
      darkTheme: SossoldiTheme.dark,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: InspectorPage(
        dark: _dark,
        onDarkChanged: (value) => setState(() => _dark = value),
      ),
    );
  }
}

class InspectorPage extends StatefulWidget {
  const InspectorPage({super.key, this.dark = false, this.onDarkChanged});

  /// Whether the Inspector itself is dark.
  final bool dark;
  final ValueChanged<bool>? onDarkChanged;

  @override
  State<InspectorPage> createState() => _InspectorPageState();
}

class _InspectorPageState extends State<InspectorPage> {
  final _controller = InspectorController();
  final _stage = GlobalKey<DeviceStageState>();

  static const _panelMin = 320.0;
  static const _panelMax = 520.0;
  double _panelWidth = 360;
  static const _minPageWidth = 1100.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            _controller.select(null),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: colors.surfaceMed,
          // A desktop tool: below this width the page scrolls sideways
          // instead of squeezing the panels.
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth < _minPageWidth
                    ? _minPageWidth
                    : constraints.maxWidth,
                height: constraints.maxHeight,
                child: _page(colors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(SossoldiColors colors) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Side(
            width: 288,
            border: BorderDirectional(
              end: BorderSide(color: colors.strokeMinus1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Brand(dark: widget.dark, onDarkChanged: widget.onDarkChanged),
                Expanded(child: SceneMenu(controller: _controller)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SossoldiSpacing.l,
                      SossoldiSpacing.l,
                      SossoldiSpacing.l,
                      0,
                    ),
                    child: Center(
                      child: DeviceStage(key: _stage, controller: _controller),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(SossoldiSpacing.m),
                  // Scales down instead of overflowing when the middle
                  // column is narrow.
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: InspectorToolbar(controller: _controller),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Side(
            width: _panelWidth,
            border: BorderDirectional(
              start: BorderSide(color: colors.strokeMinus1),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: InspectPanel(
                    controller: _controller,
                    inspection: () => _stage.currentState?.inspection,
                  ),
                ),
                // Drag the left edge to widen or narrow the panel.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: SossoldiSpacing.s,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) => setState(
                        () => _panelWidth = (_panelWidth - d.delta.dx).clamp(
                          _panelMin,
                          _panelMax,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.width, required this.border, required this.child});

  final double width;
  final BorderDirectional border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        border: border,
      ),
      child: child,
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.dark, required this.onDarkChanged});

  final bool dark;
  final ValueChanged<bool>? onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SossoldiSpacing.l,
        SossoldiSpacing.l,
        SossoldiSpacing.l,
        0,
      ),
      child: Row(
        spacing: SossoldiSpacing.s,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sossoldi Inspector',
                  style: typography.titleMedium.copyWith(
                    color: colors.textHigh,
                  ),
                ),
                Text(
                  'V2 prototype',
                  style: typography.labelSmall.copyWith(color: colors.textMed),
                ),
              ],
            ),
          ),
          // Light or dark, for the Inspector only.
          Icon(
            dark ? PhosphorIconsRegular.moon : PhosphorIconsRegular.sun,
            size: 20,
            color: colors.textMed,
          ),
          SossoldiSwitch(
            value: dark,
            onChanged: onDarkChanged,
            semanticLabel: 'Inspector dark mode',
            size: SossoldiSwitchSize.small,
          ),
        ],
      ),
    );
  }
}
