// Investments > Positions, from Figma (node 13:4927): the portfolio value
// card, the positions list and the portfolio breakdown. Adapted: the search
// and the filter button sit under the title "Positions" (they only act on
// the list), not at the top of the page. Every number comes from the
// repository; nothing is computed here.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/portfolio.dart';
import '../investments_controller.dart';
import '../investments_texts.dart';
import '../portfolio_value_card.dart';
import 'position_detail_screen.dart';
import 'position_filters_sheet.dart';

class PositionsTab extends StatelessWidget {
  const PositionsTab({super.key, required this.controller});

  final InvestmentsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final empty = repo.holdings.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        const PortfolioValueCard(),
        if (empty)
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.chartLineUp,
              title: l10n.positionsNoneTitle,
              message: l10n.investmentsEmptyHint,
            ),
          )
        else ...[
          _PositionsSection(controller: controller),
          _BreakdownSection(controller: controller),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: context.typography.titleMedium.copyWith(
      color: context.colors.textHigh,
    ),
  );
}

class _PositionsSection extends StatefulWidget {
  const _PositionsSection({required this.controller});

  final InvestmentsController controller;

  @override
  State<_PositionsSection> createState() => _PositionsSectionState();
}

class _PositionsSectionState extends State<_PositionsSection> {
  late final TextEditingController _search = TextEditingController(
    text: widget.controller.positionsQuery,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncText);
    _search.dispose();
    super.dispose();
  }

  /// "Clear filters" empties the search from the controller's side.
  void _syncText() {
    if (_search.text != widget.controller.positionsQuery) {
      _search.text = widget.controller.positionsQuery;
    }
  }

  Future<void> _openFilters() async {
    final chosen = await showPositionFiltersSheet(
      context,
      kinds: widget.controller.positionKinds,
    );
    if (chosen != null) widget.controller.setPositionKinds(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final c = widget.controller;
    final masked = context.hideAmounts;
    final positions = repo.searchPositions(
      query: c.positionsQuery,
      kinds: c.positionKinds,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        _SectionTitle(l10n.positionsTitle),
        Row(
          spacing: SossoldiSpacing.s,
          children: [
            Expanded(
              child: SossoldiSearchField(
                controller: _search,
                placeholder: l10n.positionsSearch,
                clearSemanticLabel: l10n.clearSearch,
                onChanged: c.setPositionsQuery,
              ),
            ),
            SossoldiFilterButton(
              semanticLabel: l10n.filters,
              active: c.positionKinds.isNotEmpty,
              onPressed: _openFilters,
            ),
          ],
        ),
        if (c.positionKinds.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: SossoldiFilterChip(
              name: l10n.positionsFilterType,
              value: [
                for (final k in PositionKind.values)
                  if (c.positionKinds.contains(k))
                    positionKindLabel(context, k),
              ].join(', '),
              onRemove: () => c.setPositionKinds(const {}),
              removeSemanticLabel:
                  '${l10n.removeFilter}: ${l10n.positionsFilterType}',
            ),
          ),
        if (positions.isEmpty)
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.magnifyingGlass,
              title: l10n.positionsEmptyTitle,
              message: l10n.positionsEmptyHint,
              actionLabel: c.positionsRefined ? l10n.clearFilters : null,
              onAction: c.positionsRefined ? c.clearPositionsFilters : null,
            ),
          )
        else
          SossoldiList(
            children: [
              for (final p in positions)
                SossoldiAssetItem(
                  key: ValueKey(p.holdingId),
                  name: p.name,
                  typeLabel: positionTypeLabel(context, p),
                  identifier: positionIdentifier(p),
                  chart: SossoldiRightChart(
                    points: p.monthPrices,
                    value: p.value,
                    currencyCode: repo.mainCurrency,
                    change: p.gainPercent,
                    trend: p.monthChange,
                    masked: masked,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PositionDetailScreen(holdingId: p.holdingId),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.controller});

  final InvestmentsController controller;

  /// Colors of the rows, from the category palette.
  static const _palette = [3, 26, 20, 9, 14, 2, 22, 6];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    final brightness = Theme.of(context).brightness;
    final rows = repo.portfolioBreakdown(controller.breakdown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        _SectionTitle(l10n.breakdownTitle),
        Container(
          padding: const EdgeInsets.all(SossoldiSpacing.m),
          decoration: ShapeDecoration(
            color: colors.surfaceHigh,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(SossoldiRadius.m),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: SossoldiSpacing.s,
            children: [
              SossoldiTabNavigation(
                tabs: [
                  SossoldiTabData.text(l10n.breakdownRegion),
                  SossoldiTabData.text(l10n.breakdownSector),
                ],
                selectedIndex: controller.breakdown.index,
                onChanged: (i) =>
                    controller.selectBreakdown(BreakdownBy.values[i]),
              ),
              for (final (i, r) in rows.indexed)
                SossoldiBreakdownItem(
                  name: breakdownName(context, r),
                  share: r.share,
                  value: r.value,
                  currencyCode: repo.mainCurrency,
                  percentText: SossoldiAmountFormat.percent(
                    context,
                    r.share,
                    showPlusSign: false,
                    decimalDigits: 0,
                  ),
                  color: r.name == null
                      ? colors.shapeMed
                      : CategoryColors.all[_palette[i % _palette.length]].main,
                  trackColor: r.name == null
                      ? colors.surfaceLow
                      : CategoryColors.all[_palette[i % _palette.length]]
                            .tintFor(brightness),
                  masked: context.hideAmounts,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
