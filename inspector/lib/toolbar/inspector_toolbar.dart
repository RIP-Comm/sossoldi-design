// The floating toolbar under the phone, as in Figma: on the left the controls
// (device, language, data, what a click picks, dark mode, reload, zoom), each
// an icon with a caret that opens its menu; on the right the modes, Inspect
// and Interact. What a click picks exists only in Inspect: it disappears in
// Interact and the bar resizes.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../device/device_spec.dart';
import '../inspector_controller.dart';

const _resize = Duration(milliseconds: 220);

class InspectorToolbar extends StatelessWidget {
  const InspectorToolbar({super.key, required this.controller});

  final InspectorController controller;

  static const zoomLevels = [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = controller;
    final inspecting = c.mode == InspectorMode.inspect;
    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiRadius.l),
        border: Border.all(color: colors.strokeMinus1),
        boxShadow: SossoldiShadows.lg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SossoldiSpacing.xs,
        children: [
          _MenuTool<DeviceSpec>(
            title: 'Device',
            icon: PhosphorIconsRegular.deviceMobile,
            value: c.device,
            options: [for (final d in DeviceSpec.all) (d, d.name)],
            onChanged: c.setDevice,
          ),
          _MenuTool<String>(
            title: 'Language',
            icon: PhosphorIconsRegular.translate,
            value: c.locale.languageCode,
            options: const [('en', 'English'), ('it', 'Italiano')],
            onChanged: (code) => c.setLocale(Locale(code)),
          ),
          _MenuTool<bool>(
            title: 'Data',
            icon: PhosphorIconsRegular.database,
            value: c.newUser,
            options: const [(false, 'Demo data'), (true, 'New user')],
            onChanged: c.setNewUser,
          ),
          _ToggleTool(
            tooltip: c.dark ? 'Dark mode on' : 'Dark mode off',
            icon: c.dark ? PhosphorIconsFill.moon : PhosphorIconsRegular.moon,
            active: c.dark,
            onTap: () => c.setDark(!c.dark),
          ),
          _ToggleTool(
            tooltip: 'Reload screen',
            icon: PhosphorIconsRegular.arrowCounterClockwise,
            onTap: c.reload,
          ),
          _MenuTool<double?>(
            title: 'Zoom',
            label: c.zoom == null ? 'Fit' : '${(c.zoom! * 100).round()}%',
            value: c.zoom,
            options: [
              (null, 'Fit to window'),
              for (final z in zoomLevels) (z, '${(z * 100).round()}%'),
            ],
            onChanged: c.setZoom,
          ),
          // Only in Inspect: hidden in Interact, and the bar resizes.
          AnimatedSize(
            duration: _resize,
            curve: Curves.easeOutCubic,
            child: inspecting
                ? _MenuTool<bool>(
                    title: 'Click selects',
                    icon: c.pickComponents
                        ? PhosphorIconsRegular.diamondsFour
                        : PhosphorIconsRegular.selection,
                    value: c.pickComponents,
                    options: const [(false, 'Element'), (true, 'Component')],
                    onChanged: c.setPickComponents,
                  )
                : const SizedBox(height: 40),
          ),
          Container(width: 1, height: 24, color: colors.strokeDefault),
          SossoldiTabNavigation(
            tabs: const [
              SossoldiTabData.icon(
                PhosphorIconsRegular.cursor,
                semanticLabel: 'Inspect',
              ),
              SossoldiTabData.icon(
                PhosphorIconsRegular.handPointing,
                semanticLabel: 'Interact',
              ),
            ],
            selectedIndex: inspecting ? 0 : 1,
            onChanged: (i) => c.setMode(
              i == 0 ? InspectorMode.inspect : InspectorMode.interact,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tool of the bar: rounded, highlighted when [active].
class _ToolFrame extends StatelessWidget {
  const _ToolFrame({required this.child, this.active = false});

  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.s),
      decoration: BoxDecoration(
        color: active ? context.colors.selectedSurface : null,
        borderRadius: BorderRadius.circular(SossoldiRadius.s),
      ),
      child: Center(widthFactor: 1, child: child),
    );
  }
}

/// An icon (or a short label) with a caret; the menu opens above it.
class _MenuTool<T> extends StatelessWidget {
  const _MenuTool({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.label,
  });

  final String title;
  final IconData? icon;

  /// Shown instead of the icon (e.g. the zoom level).
  final String? label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return SossoldiPopover(
      above: true,
      width: 220,
      content: Builder(
        builder: (menuContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SossoldiSpacing.s,
                SossoldiSpacing.xs,
                SossoldiSpacing.s,
                SossoldiSpacing.xs,
              ),
              child: Text(
                title.toUpperCase(),
                style: typography.labelUppercaseBoldSmall.copyWith(
                  color: colors.textLow,
                ),
              ),
            ),
            for (final (v, name) in options)
              SossoldiMenuItem(
                label: name,
                dense: true,
                selected: v == value,
                onTap: () {
                  SossoldiPopover.close(menuContext);
                  onChanged(v);
                },
              ),
          ],
        ),
      ),
      child: Semantics(
        label: title,
        button: true,
        child: _ToolFrame(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: SossoldiSpacing.xs,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: typography.labelBoldMedium.copyWith(
                    color: colors.textHigh,
                  ),
                )
              else
                Icon(icon, size: 20, color: colors.textHigh),
              Icon(
                PhosphorIconsRegular.caretDown,
                size: 12,
                color: colors.textMed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A one-tap tool: a toggle when [active] is given, else an action.
class _ToggleTool extends StatelessWidget {
  const _ToggleTool({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SossoldiTappable(
      onTap: onTap,
      semanticLabel: tooltip,
      child: _ToolFrame(
        active: active,
        child: Icon(
          icon,
          size: 20,
          color: active ? colors.primary.text : colors.textHigh,
        ),
      ),
    );
  }
}
