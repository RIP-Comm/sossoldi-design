import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/portfolio.dart';
import '../../finance/filter_check_row.dart';
import '../investments_texts.dart';

/// Opens the filters of the positions list (the kind of asset, several at
/// once) and returns the chosen kinds, or null when cancelled.
Future<Set<PositionKind>?> showPositionFiltersSheet(
  BuildContext context, {
  required Set<PositionKind> kinds,
}) => showSossoldiBottomSheet<Set<PositionKind>>(
  context: context,
  builder: (_) => _FiltersBody(kinds: kinds),
);

IconData _icon(PositionKind k) => switch (k) {
  PositionKind.etf => PhosphorIconsRegular.chartPieSlice,
  PositionKind.stock => PhosphorIconsRegular.chartLineUp,
  PositionKind.bond => PhosphorIconsRegular.certificate,
  PositionKind.manual => PhosphorIconsRegular.pencilSimple,
};

class _FiltersBody extends StatefulWidget {
  const _FiltersBody({required this.kinds});

  final Set<PositionKind> kinds;

  @override
  State<_FiltersBody> createState() => _FiltersBodyState();
}

class _FiltersBodyState extends State<_FiltersBody> {
  late final Set<PositionKind> _draft = {...widget.kinds};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiBottomSheetToolbar.text(
          title: l10n.filters,
          closeLabel: l10n.cancel,
          onClose: () => Navigator.of(context).pop(),
          confirmLabel: l10n.filtersApply,
          onConfirm: () => Navigator.of(context).pop(_draft),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.s,
          children: [
            Text(
              l10n.positionsFilterType,
              style: context.typography.titleMedium.copyWith(
                color: colors.textHigh,
              ),
            ),
            SossoldiList(
              children: [
                for (final k in PositionKind.values)
                  FilterCheckRow(
                    icon: Icon(_icon(k), size: 24, color: colors.textHigh),
                    label: positionKindLabel(context, k),
                    checked: _draft.contains(k),
                    onToggle: () => setState(
                      () =>
                          _draft.contains(k) ? _draft.remove(k) : _draft.add(k),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Center(
          child: SossoldiButton(
            label: l10n.filtersReset,
            type: SossoldiButtonType.ghost,
            onPressed: () => setState(_draft.clear),
          ),
        ),
      ],
    );
  }
}
