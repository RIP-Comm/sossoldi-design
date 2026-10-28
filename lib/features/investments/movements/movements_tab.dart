// Investments > Movements, from Figma (node 13:4987). Adapted: one list
// grouped by day instead of the sections Dividend, Costs and Buy and Sell,
// with the expected dividends apart in "Up next", and no floating "Add
// movement" button (the "+" of the bar opens the form). Every number comes
// from the repository.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/movement_edit.dart';
import '../../finance/transactions/day_title.dart';
import '../investments_controller.dart';
import '../investments_texts.dart';
import 'movement_detail_screen.dart';
import 'movement_filters_sheet.dart';

class MovementsTab extends StatefulWidget {
  const MovementsTab({super.key, required this.controller});

  final InvestmentsController controller;

  @override
  State<MovementsTab> createState() => _MovementsTabState();
}

class _MovementsTabState extends State<MovementsTab> {
  late final TextEditingController _search = TextEditingController(
    text: widget.controller.movementFilter.query,
  );

  InvestmentsController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_syncText);
  }

  @override
  void dispose() {
    c.removeListener(_syncText);
    _search.dispose();
    super.dispose();
  }

  /// "Clear filters" empties the search from the controller's side.
  void _syncText() {
    if (_search.text != c.movementFilter.query) {
      _search.text = c.movementFilter.query;
    }
  }

  Future<void> _openFilters() async {
    final chosen = await showMovementFiltersSheet(
      context,
      repository: context.repository,
      filter: c.movementFilter,
    );
    if (chosen != null) {
      c.setMovementFilter(chosen.copyWith(query: c.movementFilter.query));
    }
  }

  void _open(InvestmentMovement m) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MovementDetailScreen(movementId: m.id),
    ),
  );

  Widget _row(BuildContext context, MovementEntry e, {bool expected = false}) {
    final m = e.movement;
    final signed = switch (m.type) {
      MovementType.cost => -e.total,
      _ => e.total,
    };
    return SossoldiMovementItem(
      key: ValueKey(m.id),
      typeLabel: movementTypeLabel(context, m.type),
      typeIcon: movementTypeIcon(m.type),
      tone: movementTone(m.type),
      title: e.name ?? m.description,
      subtitle: e.name == null ? null : movementIdentifier(e),
      // What is expected shows its date; the rest, units and price or the
      // description.
      details: expected
          ? DateFormat.yMMMd(Localizations.localeOf(context).toString())
                .format(m.date)
          : (e.name == null ? null : movementDetails(context, e)),
      amount: signed,
      currencyCode: e.currency,
      masked: context.hideAmounts,
      onTap: () => _open(m),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final list = repo.movementList(c.movementFilter);
    final none = repo.movements().isEmpty;
    Widget title(String t) => Text(
      t,
      style: context.typography.titleMedium.copyWith(color: colors.textHigh),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        Row(
          spacing: SossoldiSpacing.s,
          children: [
            Expanded(
              child: SossoldiSearchField(
                controller: _search,
                placeholder: l10n.movementsSearch,
                clearSemanticLabel: l10n.clearSearch,
                onChanged: c.setMovementQuery,
              ),
            ),
            SossoldiFilterButton(
              semanticLabel: l10n.filters,
              active: c.movementFilter.activeCount > 0,
              onPressed: _openFilters,
            ),
          ],
        ),
        if (list.isEmpty)
          Container(
            decoration: ShapeDecoration(
              color: colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.arrowsLeftRight,
              title: none ? l10n.movementsNoneTitle : l10n.movementsEmptyTitle,
              message: none
                  ? l10n.investmentsEmptyHint
                  : l10n.movementsEmptyHint,
              actionLabel: !none && c.movementFilter.isRefined
                  ? l10n.clearFilters
                  : null,
              onAction: !none && c.movementFilter.isRefined
                  ? c.clearMovementFilters
                  : null,
            ),
          ),
        if (list.upNext.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              title(l10n.movementsUpNext),
              SossoldiList(
                children: [
                  for (final e in list.upNext) _row(context, e, expected: true),
                ],
              ),
            ],
          ),
        for (final day in list.days)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              SossoldiDayHeader(title: dayTitle(context, day.day)),
              SossoldiList(
                children: [for (final e in day.entries) _row(context, e)],
              ),
            ],
          ),
      ],
    );
  }
}
