import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/mock_repository.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/movement_edit.dart';
import '../../../mock/models/portfolio.dart';
import '../../finance/filter_check_row.dart';
import '../investments_texts.dart';

/// Opens the filters of the movements list (period, type of movement, type
/// of asset and one asset) and returns the chosen ones, or null when
/// cancelled. The search text of [filter] is kept.
Future<MovementFilter?> showMovementFiltersSheet(
  BuildContext context, {
  required MockRepository repository,
  required MovementFilter filter,
}) => showModalBottomSheet<MovementFilter>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  constraints: sossoldiSheetConstraints(context),
  builder: (_) => _FiltersBody(repository: repository, filter: filter),
);

class _FiltersBody extends StatefulWidget {
  const _FiltersBody({required this.repository, required this.filter});

  final MockRepository repository;
  final MovementFilter filter;

  @override
  State<_FiltersBody> createState() => _FiltersBodyState();
}

class _FiltersBodyState extends State<_FiltersBody> {
  late MovementFilter _draft = widget.filter;

  IconData _kindIcon(PositionKind k) => switch (k) {
    PositionKind.etf => PhosphorIconsRegular.chartPieSlice,
    PositionKind.stock => PhosphorIconsRegular.chartLineUp,
    PositionKind.bond => PhosphorIconsRegular.certificate,
    PositionKind.manual => PhosphorIconsRegular.pencilSimple,
  };

  Set<T> _toggle<T>(Set<T> set, T v) =>
      set.contains(v) ? ({...set}..remove(v)) : {...set, v};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final assets = widget.repository.movementAssets();

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          title,
          style: context.typography.titleMedium.copyWith(
            color: colors.textHigh,
          ),
        ),
        child,
      ],
    );

    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.text(
        title: l10n.filters,
        closeLabel: l10n.cancel,
        onClose: () => Navigator.of(context).pop(),
        confirmLabel: l10n.filtersApply,
        onConfirm: () => Navigator.of(context).pop(_draft),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.xl,
          children: [
            section(
              l10n.movementFilterPeriod,
              Wrap(
                spacing: SossoldiSpacing.s,
                runSpacing: SossoldiSpacing.s,
                children: [
                  for (final p in MovementPeriod.values)
                    SossoldiUnitNavigator(
                      label: movementPeriodLabel(context, p),
                      selected: _draft.period == p,
                      onTap: () =>
                          setState(() => _draft = _draft.copyWith(period: p)),
                    ),
                ],
              ),
            ),
            section(
              l10n.movementFilterType,
              SossoldiList(
                children: [
                  for (final t in MovementType.values)
                    FilterCheckRow(
                      icon: Icon(
                        movementTypeIcon(t),
                        size: 24,
                        color: colors.textHigh,
                      ),
                      label: movementTypeLabel(context, t),
                      checked: _draft.types.contains(t),
                      onToggle: () => setState(
                        () => _draft = _draft.copyWith(
                          types: _toggle(_draft.types, t),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            section(
              l10n.movementFilterAssetType,
              SossoldiList(
                children: [
                  for (final k in PositionKind.values)
                    FilterCheckRow(
                      icon: Icon(
                        _kindIcon(k),
                        size: 24,
                        color: colors.textHigh,
                      ),
                      label: positionKindLabel(context, k),
                      checked: _draft.kinds.contains(k),
                      onToggle: () => setState(
                        () => _draft = _draft.copyWith(
                          kinds: _toggle(_draft.kinds, k),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            section(
              l10n.movementFilterAsset,
              SossoldiSelect<String>(
                value: _draft.holdingId ?? '',
                onChanged: (v) => setState(
                  () => _draft = v.isEmpty
                      ? _draft.copyWith(clearHolding: true)
                      : _draft.copyWith(holdingId: v),
                ),
                items: [
                  SossoldiSelectItem(
                    value: '',
                    label: l10n.movementFilterAnyAsset,
                  ),
                  for (final a in assets)
                    SossoldiSelectItem(value: a.holdingId, label: a.label),
                ],
              ),
            ),
            Center(
              child: SossoldiButton(
                label: l10n.filtersReset,
                type: SossoldiButtonType.ghost,
                onPressed: () => setState(
                  () => _draft = MovementFilter(query: _draft.query),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
