// Page of one position. Not in Figma: built from the existing components.
// Back and the name (no Edit: the position comes from the movements); the
// type, ticker - ISIN - exchange, the price and its change today; the price
// chart with the average cost as a dashed line; "Your position", "Asset
// info" and "Operations"; Buy, Sell and Add dividend at the bottom (they
// open a placeholder for now). A manual asset has no chart and no asset info.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../app/placeholder_screen.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/asset.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/portfolio.dart';
import '../../finance/transactions/day_title.dart';
import '../investments_texts.dart';
import '../../../mock/models/investment_movement.dart' show MovementType;
import '../movements/movement_form_sheet.dart';
import 'position_detail_controller.dart';

class PositionDetailScreen extends StatefulWidget {
  const PositionDetailScreen({super.key, required this.holdingId});

  final String holdingId;

  @override
  State<PositionDetailScreen> createState() => _PositionDetailScreenState();
}

class _PositionDetailScreenState extends State<PositionDetailScreen> {
  late final PositionDetailController _controller = PositionDetailController(
    AppScope.read(context).repository,
    widget.holdingId,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _placeholder(String title) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PlaceholderScreen(title: title, showBack: true),
    ),
  );

  /// What goes under the three dots: recording a dividend (only for what
  /// pays one) and, for a manual asset, entering its current value.
  List<(IconData, String)> _moreActions(PositionDetail d) {
    final l10n = context.l10n;
    return [
      if (d.paysIncome) (PhosphorIconsRegular.coins, l10n.positionAddDividend),
      if (d.position.isManual)
        (PhosphorIconsRegular.pencilSimple, l10n.positionUpdateValue),
    ];
  }

  Future<void> _openMore(PositionDetail d) async {
    final actions = _moreActions(d);
    final picked = await showSossoldiBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SossoldiList(
        children: [
          for (final (icon, label) in actions)
            SossoldiMenuItem(
              label: label,
              leading: Icon(icon, size: 24, color: context.colors.textHigh),
              onTap: () => Navigator.of(sheetContext).pop(label),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    if (picked == context.l10n.positionAddDividend) {
      await showMovementFormSheet(
        context,
        type: MovementType.dividend,
        holdingId: widget.holdingId,
      );
    } else {
      _placeholder(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final d = _controller.detail;
        if (d == null) {
          // Sold out or removed: there is nothing left to show.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const SizedBox.shrink();
        }
        final p = d.position;
        return Scaffold(
          backgroundColor: colors.surfaceMed,
          body: SafeArea(
            child: Column(
              children: [
                SossoldiBottomSheetToolbar.text(
                  // The name is in the page, once: the bar has only Back.
                  title: '',
                  closeLabel: l10n.back,
                  closeIcon: PhosphorIconsRegular.caretLeft,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: colors.primary.surface,
                    backgroundColor: colors.surfaceHigh,
                    onRefresh: _controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(SossoldiSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: SossoldiSpacing.l,
                        children: [
                          _Header(detail: d),
                          if (!p.isManual) _PriceChart(controller: _controller),
                          _YourPosition(detail: d),
                          if (!p.isManual) _AssetInfo(detail: d),
                          _Operations(detail: d),
                          Row(
                            spacing: SossoldiSpacing.s,
                            children: [
                              Expanded(
                                child: SossoldiButton(
                                  label: l10n.positionBuy,
                                  size: SossoldiButtonSize.large,
                                  expanded: true,
                                  onPressed: () => showMovementFormSheet(
                                    context,
                                    type: MovementType.buy,
                                    holdingId: widget.holdingId,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SossoldiButton(
                                  label: l10n.positionSell,
                                  type: SossoldiButtonType.outline,
                                  size: SossoldiButtonSize.large,
                                  expanded: true,
                                  onPressed: () => showMovementFormSheet(
                                    context,
                                    type: MovementType.sell,
                                    holdingId: widget.holdingId,
                                  ),
                                ),
                              ),
                              if (_moreActions(d).isNotEmpty)
                                SossoldiIconButton(
                                  icon: PhosphorIconsRegular.dotsThree,
                                  type: SossoldiIconButtonType.outline,
                                  size: SossoldiIconButtonSize.large,
                                  semanticLabel: l10n.positionMoreActions,
                                  onPressed: () => _openMore(d),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: SossoldiSpacing.s,
    children: [
      Text(
        title,
        style: context.typography.titleMedium.copyWith(
          color: context.colors.textHigh,
        ),
      ),
      child,
    ],
  );
}

Widget _card(BuildContext context, {required Widget child}) => Container(
  padding: const EdgeInsets.all(SossoldiSpacing.m),
  decoration: ShapeDecoration(
    color: context.colors.surfaceHigh,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(SossoldiRadius.m),
    ),
  ),
  child: child,
);

class _Header extends StatelessWidget {
  const _Header({required this.detail});

  final PositionDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final repo = context.repository;
    final p = detail.position;
    final masked = context.hideAmounts;
    final ident = [?p.ticker, ?p.isin, ?p.exchange].join(' – ');
    final other = !p.isManual && detail.hasOtherCurrency(repo.mainCurrency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiTag(label: positionTypeLabel(context, p), hasStroke: true),
        // The whole name: the toolbar and the list cut long ones.
        Text(
          p.name,
          style: typography.titleMedium.copyWith(color: colors.textHigh),
        ),
        if (ident.isNotEmpty)
          Text(
            ident,
            style: typography.labelMedium.copyWith(color: colors.textMed),
          ),
        if (detail.priceMain != null)
          Row(
            spacing: SossoldiSpacing.s,
            children: [
              SossoldiAmount(
                value: detail.priceMain!,
                currencyCode: repo.mainCurrency,
                masked: masked,
                style: typography.labelBoldXLarge,
              ),
              if (detail.todayChange != null)
                SossoldiChangeTag.percent(value: detail.todayChange!),
            ],
          ),
        if (other)
          Text(
            context.l10n.positionPriceInCurrency(
              masked
                  ? '••••'
                  : SossoldiAmountFormat.money(
                      context,
                      detail.price!,
                      currencyCode: detail.assetCurrency,
                    ),
            ),
            style: typography.labelMedium.copyWith(color: colors.textMed),
          ),
      ],
    );
  }
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({required this.controller});

  final PositionDetailController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final series = controller.series;
    final points = series.points;
    final texts = ValueChartTexts(context, series);
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SossoldiSpacing.m,
        children: [
          SossoldiTabNavigation(
            tabs: [
              for (final p in ValuePeriod.values)
                SossoldiTabData.text(periodLabel(context, p)),
            ],
            selectedIndex: controller.period.index,
            onChanged: (i) => controller.selectPeriod(ValuePeriod.values[i]),
          ),
          SossoldiValueChart(
            key: ValueKey(controller.period),
            values: [for (final p in points) p.value],
            invested: [for (final p in points) p.invested],
            pointLabels: [for (final p in points) texts.label(p.time)],
            pointTitles: [for (final p in points) texts.title(p.time)],
            formatAxis: (v) => v.abs() < 100
                ? NumberFormat('0.#', locale).format(v)
                : compact.format(v),
            formatValue: (v) => SossoldiAmountFormat.money(
              context,
              v,
              currencyCode: series.currency,
            ),
            valueLabel: l10n.positionPrice,
            investedLabel: l10n.positionAverageCost,
            masked: context.hideAmounts,
            semanticLabel: l10n.positionPriceChartSemantics,
          ),
          SossoldiChartLegend(
            items: [
              SossoldiLegendItem(
                color: points.isEmpty || points.last.difference >= 0
                    ? colors.income.onSurface
                    : colors.expense.onSurface,
                label: l10n.positionPrice,
              ),
              SossoldiLegendItem(
                color: colors.shapeMed,
                label: l10n.positionAverageCost,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value);

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Row(
    spacing: SossoldiSpacing.s,
    children: [
      Expanded(
        child: Text(
          label,
          style: context.typography.labelLarge.copyWith(
            color: context.colors.textMed,
          ),
        ),
      ),
      value,
    ],
  );
}

class _YourPosition extends StatelessWidget {
  const _YourPosition({required this.detail});

  final PositionDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typography = context.typography;
    final colors = context.colors;
    final repo = context.repository;
    final p = detail.position;
    final masked = context.hideAmounts;
    Widget money(num v, {bool signed = false}) => SossoldiAmount(
      value: v,
      currencyCode: repo.mainCurrency,
      masked: masked,
      showPlusSign: signed,
      tone: signed ? SossoldiAmountTone.signed : SossoldiAmountTone.neutral,
    );
    Widget text(String t) => Text(
      masked ? '••••' : t,
      style: typography.labelLarge.copyWith(color: colors.textHigh),
    );
    final locale = Localizations.localeOf(context).toString();
    return _Section(
      title: l10n.positionYour,
      child: _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            _KeyValue(l10n.positionMarketValue, money(p.value)),
            if (!p.isManual) ...[
              _KeyValue(
                l10n.positionQuantity,
                text(
                  NumberFormat('#,##0.####', locale).format(detail.quantity),
                ),
              ),
              _KeyValue(
                l10n.positionAverageCost,
                money(detail.averageCostMain),
              ),
            ],
            _KeyValue(l10n.positionInvested, money(p.cost)),
            _KeyValue(
              l10n.positionPnl,
              Row(
                spacing: SossoldiSpacing.s,
                children: [
                  SossoldiChangeTag.percent(value: p.gainPercent),
                  money(p.gain, signed: true),
                ],
              ),
            ),
            _KeyValue(
              l10n.positionWeight,
              Text(
                SossoldiAmountFormat.percent(
                  context,
                  p.weight,
                  showPlusSign: false,
                  decimalDigits: 1,
                ),
                style: typography.labelLarge.copyWith(color: colors.textHigh),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetInfo extends StatelessWidget {
  const _AssetInfo({required this.detail});

  final PositionDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = detail.position;
    final asset = detail.asset!;
    final locale = Localizations.localeOf(context).toString();
    Widget text(String? t) => Text(
      t ?? '–',
      style: context.typography.labelLarge.copyWith(
        color: context.colors.textHigh,
      ),
    );
    String percent(double? v, {int digits = 2}) => v == null
        ? '–'
        : SossoldiAmountFormat.percent(
            context,
            v,
            showPlusSign: false,
            decimalDigits: digits,
          );
    // What is worth knowing depends on the kind of asset.
    final rows = <(String, String?)>[
      (l10n.infoType, positionKindLabel(context, p.kind)),
      ...switch (asset.type) {
        AssetType.etf => [
          (
            l10n.infoDistribution,
            asset.distribution == AssetDistribution.distributing
                ? l10n.distDistributing
                : l10n.distAccumulating,
          ),
          (l10n.infoTer, percent(asset.ter)),
          (l10n.infoRegion, asset.region),
        ],
        AssetType.stock => [
          (l10n.infoSector, asset.sector),
          (l10n.infoRegion, asset.region),
          (l10n.infoDividendYield, percent(asset.dividendYield, digits: 1)),
        ],
        AssetType.bond => [
          (l10n.infoCoupon, percent(asset.coupon)),
          (
            l10n.infoMaturity,
            asset.maturity == null
                ? null
                : DateFormat.yMMMd(locale).format(asset.maturity!),
          ),
          (
            l10n.infoDuration,
            asset.duration == null
                ? null
                : l10n.infoYears(
                    NumberFormat('0.#', locale).format(asset.duration),
                  ),
          ),
        ],
      },
      (l10n.infoCurrency, detail.assetCurrency),
      (l10n.infoExchange, p.exchange),
    ];
    return _Section(
      title: l10n.positionAssetInfo,
      child: _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.m,
          children: [
            for (final (label, value) in rows) _KeyValue(label, text(value)),
          ],
        ),
      ),
    );
  }
}

class _Operations extends StatelessWidget {
  const _Operations({required this.detail});

  final PositionDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final masked = context.hideAmounts;
    final locale = Localizations.localeOf(context).toString();
    final qty = NumberFormat('#,##0.####', locale);
    return _Section(
      title: l10n.positionOperations,
      child: detail.operations.isEmpty
          ? Container(
              decoration: ShapeDecoration(
                color: context.colors.surfaceHigh,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(SossoldiRadius.m),
                ),
              ),
              child: SossoldiEmptyState(
                icon: PhosphorIconsRegular.receipt,
                title: l10n.operationsEmpty,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.m,
              children: [
                for (final day in detail.operations)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: SossoldiSpacing.s,
                    children: [
                      SossoldiDayHeader(title: dayTitle(context, day.day)),
                      SossoldiList(
                        children: [
                          for (final o in day.operations)
                            SossoldiOperationItem(
                              typeLabel: operationTypeLabel(context, o.type),
                              title:
                                  detail.position.ticker ??
                                  detail.position.name,
                              amount: o.amount,
                              currencyCode: o.currency,
                              positive: o.type == MovementType.dividend,
                              masked: masked,
                              details: o.quantity == null || o.price == null
                                  ? null
                                  : l10n.operationDetails(
                                      qty.format(o.quantity),
                                      SossoldiAmountFormat.money(
                                        context,
                                        o.price!,
                                        currencyCode: o.currency,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
