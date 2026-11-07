// Add-widget bottom sheet, from Figma "1.0.2 - Edit mode - Add widget"
// (node 13:3888) and "1.0.3" (node 13:10736): first the list of available
// widgets, then a preview of the chosen one that can be swiped between its
// sizes, with the "Add widget" button.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import '../registry/dashboard_widget_registry.dart';
import 'add_widget_choice.dart';

/// Opens the sheet and returns what the user chose, or null if dismissed.
Future<AddWidgetChoice?> showAddWidgetSheet(
  BuildContext context, {
  required DashboardWidgetRegistry registry,
}) {
  return showModalBottomSheet<AddWidgetChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => AddWidgetSheet(registry: registry),
  );
}

class AddWidgetSheet extends StatefulWidget {
  const AddWidgetSheet({super.key, required this.registry});

  final DashboardWidgetRegistry registry;

  @override
  State<AddWidgetSheet> createState() => _AddWidgetSheetState();
}

class _AddWidgetSheetState extends State<AddWidgetSheet> {
  /// Null while the list is shown.
  DashboardWidgetDefinition? _selected;
  int _page = 0;

  List<DashboardWidgetSize> get _sizes => [
    for (final s in DashboardWidgetSize.values)
      if (_selected!.supports(s)) s,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: selected == null
          ? SossoldiBottomSheetToolbar.text(
              title: l10n.addWidget,
              closeLabel: l10n.cancel,
              onClose: () => Navigator.of(context).pop(),
            )
          : SossoldiBottomSheetToolbar.text(
              title: selected.name(l10n),
              closeLabel: l10n.back,
              closeIcon: PhosphorIconsRegular.arrowLeft,
              onClose: () => setState(() => _selected = null),
            ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        // Both steps fill the sheet, top-aligned (the default centers them).
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: selected == null
            ? _WidgetList(
                key: const ValueKey('list'),
                registry: widget.registry,
                onSelected: (d) => setState(() {
                  _selected = d;
                  _page = 0;
                }),
              )
            : _Preview(
                key: ValueKey(selected.id),
                definition: selected,
                sizes: _sizes,
                onPageChanged: (i) => _page = i,
                onAdd: () =>
                    Navigator.of(context)
                        .pop(AddWidgetChoice(selected.id, _sizes[_page])),
              ),
      ),
    );
  }
}

class _WidgetList extends StatelessWidget {
  const _WidgetList({
    super.key,
    required this.registry,
    required this.onSelected,
  });

  final DashboardWidgetRegistry registry;
  final ValueChanged<DashboardWidgetDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final definitions = registry.definitions;
    return SingleChildScrollView(
      child: SossoldiList(
        children: [
          for (final d in definitions)
            SossoldiMenuItem(
              label: d.name(l10n),
              leading: Icon(d.icon, size: 24, color: colors.textHigh),
              hasSubitems: true,
              onTap: () => onSelected(d),
            ),
        ],
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({
    super.key,
    required this.definition,
    required this.sizes,
    required this.onPageChanged,
    required this.onAdd,
  });

  final DashboardWidgetDefinition definition;
  final List<DashboardWidgetSize> sizes;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onAdd;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  /// Space between two pages while swiping.
  static const double _pageGap = SossoldiSpacing.xl;

  PageController? _controller;
  double _position = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    // Each page is [_pageGap] wider than the content, so neighbouring
    // widgets stay apart while swiping. The content width is the screen
    // minus the sheet padding.
    final width = MediaQuery.sizeOf(context).width - 2 * SossoldiSpacing.l;
    _controller = PageController(viewportFraction: (width + _pageGap) / width)
      ..addListener(() {
        final page = _controller!.page;
        if (page != null && page != _position) {
          setState(() => _position = page);
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _sizeName(BuildContext context, DashboardWidgetSize size) {
    final l10n = context.l10n;
    return switch (size) {
      DashboardWidgetSize.s => l10n.widgetSizeSmall,
      DashboardWidgetSize.m => l10n.widgetSizeMedium,
      DashboardWidgetSize.l => l10n.widgetSizeLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            clipBehavior: Clip.none,
            itemCount: widget.sizes.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, i) {
              final size = widget.sizes[i];
              return Semantics(
                label: _sizeName(context, size),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final content = constraints.maxWidth - _pageGap;
                    final cell =
                        (content - SossoldiWidgetGrid.gap) /
                        DashboardLayout.columns;
                    final width = size.columns == DashboardLayout.columns
                        ? content
                        : cell;
                    final height = SossoldiWidgetGrid.heightFor(size.rows);
                    // On short screens the preview shrinks to fit.
                    return Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(
                                SossoldiRadius.l,
                              ),
                            ),
                            shadows: SossoldiShadows.m,
                          ),
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: ExcludeSemantics(
                              child: IgnorePointer(
                                child: widget.definition.build(
                                  context,
                                  size,
                                  instance: const DashboardWidgetInstance(
                                    preview: true,
                                  ),
                                )!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: SossoldiSpacing.l),
        if (widget.sizes.length > 1)
          SossoldiPageIndicator(count: widget.sizes.length, index: _position),
        const SizedBox(height: SossoldiSpacing.l),
        SossoldiButton(
          label: l10n.addWidget,
          size: SossoldiButtonSize.large,
          onPressed: widget.onAdd,
        ),
      ],
    );
  }
}
