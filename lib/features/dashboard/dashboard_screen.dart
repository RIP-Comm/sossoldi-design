// Dashboard, from Figma "1.0.0 - Dashboard" (node 13:3841) in view mode and
// "1.0.1 - Edit mode" (node 13:3871) in edit mode: action bar on top, then
// the grid of widgets.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../app/top_blur.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'add_widget/add_widget_sheet.dart';
import 'dashboard_controller.dart';
import 'dashboard_grid.dart';
import 'registry/dashboard_widget_registry.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onOpenSettings,
    this.registry,
  });

  final DashboardController controller;
  final VoidCallback onOpenSettings;

  /// Defaults to the app registry.
  final DashboardWidgetRegistry? registry;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scroll = ScrollController();

  DashboardWidgetRegistry get _registry =>
      widget.registry ?? dashboardWidgetRegistry;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _addWidget() async {
    final choice = await showAddWidgetSheet(context, registry: _registry);
    if (choice == null || !mounted) return;
    widget.controller.addWidget(choice.widgetId, choice.size);
    // Bring the new widget into view once the grid has grown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _addFromEmptyState() async {
    widget.controller.enterEditMode();
    await _addWidget();
  }

  @override
  Widget build(BuildContext context) {
    // The shell adds the height of the bottom bar to the bottom padding,
    // so the last widget can scroll above it.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final controller = widget.controller;
    final top = MediaQuery.paddingOf(context).top;
    final barHeight = top + SossoldiHeaderButton.size;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final editing = controller.isEditing;
        return Stack(
          children: [
            // The widgets scroll under the top bar and the status bar.
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.only(top: barHeight, bottom: bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardGrid(
                      layout: controller.layout,
                      registry: _registry,
                      editing: editing,
                      onLongPressWidget: controller.enterEditMode,
                      onRemove: controller.remove,
                      onResize: controller.resize,
                      onReorder: controller.move,
                    ),
                    if (controller.layout.isEmpty)
                      _EmptyState(editing: editing, onAdd: _addFromEmptyState),
                  ],
                ),
              ),
            ),
            // No background: what passes under is blurred (not in Figma).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: barHeight,
              child: const ProgressiveBlur(),
            ),
            Positioned(
              top: top,
              left: 0,
              right: 0,
              child: _TopBar(
                editing: editing,
                onOpenSettings: widget.onOpenSettings,
                onAdd: _addWidget,
                onDone: controller.exitEditMode,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.editing,
    required this.onOpenSettings,
    required this.onAdd,
    required this.onDone,
  });

  final bool editing;
  final VoidCallback onOpenSettings;
  final VoidCallback onAdd;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final hidden = context.hideAmounts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.l),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: editing
            ? Row(
                key: const ValueKey('edit'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SossoldiHeaderButton(
                    icon: PhosphorIconsRegular.plus,
                    semanticLabel: l10n.addWidget,
                    onPressed: onAdd,
                  ),
                  Text(
                    l10n.editHome,
                    style: context.typography.labelLarge.copyWith(
                      color: colors.textMed,
                    ),
                  ),
                  SossoldiHeaderButton(
                    icon: PhosphorIconsRegular.check,
                    semanticLabel: l10n.doneEditing,
                    filled: true,
                    onPressed: onDone,
                  ),
                ],
              )
            : Row(
                key: const ValueKey('view'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SossoldiHeaderButton(
                    icon: hidden
                        ? PhosphorIconsRegular.eyeSlash
                        : PhosphorIconsRegular.eye,
                    semanticLabel: hidden ? l10n.showAmounts : l10n.hideAmounts,
                    onPressed: AppScope.read(context).toggleHideAmounts,
                  ),
                  SossoldiHeaderButton(
                    icon: PhosphorIconsRegular.gearSix,
                    semanticLabel: l10n.settings,
                    onPressed: onOpenSettings,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Shown when every widget has been removed: in view mode with a button to
/// start adding, in edit mode with a hint pointing at the + button.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.editing, required this.onAdd});

  final bool editing;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(SossoldiSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: SossoldiSpacing.xxxl),
          Text(
            editing ? l10n.dashboardEmptyEditHint : l10n.dashboardEmptyTitle,
            textAlign: TextAlign.center,
            style: context.typography.labelLarge.copyWith(
              color: colors.textMed,
            ),
          ),
          if (!editing) ...[
            const SizedBox(height: SossoldiSpacing.l),
            SossoldiButton(
              label: l10n.addWidget,
              iconLeft: PhosphorIconsRegular.plus,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}
