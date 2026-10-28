import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/holding.dart';
import '../../mock/models/investment_movement.dart';
import '../../mock/models/movement_edit.dart';
import '../../mock/models/portfolio.dart';

/// "Updated 4 min ago": how long ago the prices were refreshed.
String investmentsUpdatedText(
  BuildContext context,
  DateTime updatedAt,
  DateTime now,
) {
  final l10n = context.l10n;
  final elapsed = now.difference(updatedAt);
  if (elapsed.inMinutes < 1) return l10n.investmentsUpdatedNow;
  if (elapsed.inHours < 1) {
    return l10n.investmentsUpdatedMinutes(elapsed.inMinutes);
  }
  if (elapsed.inDays < 1) return l10n.investmentsUpdatedHours(elapsed.inHours);
  return l10n.investmentsUpdatedDays(elapsed.inDays);
}

String periodLabel(BuildContext context, ValuePeriod period) {
  final l10n = context.l10n;
  return switch (period) {
    ValuePeriod.day => l10n.periodDay,
    ValuePeriod.fiveDays => l10n.periodFiveDays,
    ValuePeriod.month => l10n.periodMonth,
    ValuePeriod.sixMonths => l10n.periodSixMonths,
    ValuePeriod.yearToDate => l10n.periodYearToDate,
    ValuePeriod.year => l10n.periodYear,
    ValuePeriod.fiveYears => l10n.periodFiveYears,
  };
}

/// Text of the chart: the labels under the axis and the headings of the
/// indicator's card for the points of a [ValueSeries].
class ValueChartTexts {
  ValueChartTexts(BuildContext context, this.series)
    : locale = Localizations.localeOf(context).toString();

  final ValueSeries series;
  final String locale;

  /// Under the axis: the time for a day, the date for a few days or months,
  /// month and year for the long periods.
  String label(DateTime t) => switch (series.period) {
    ValuePeriod.day => DateFormat.Hm(locale).format(t),
    ValuePeriod.fiveDays ||
    ValuePeriod.month ||
    ValuePeriod.sixMonths ||
    ValuePeriod.yearToDate => DateFormat.MMMd(locale).format(t),
    ValuePeriod.year ||
    ValuePeriod.fiveYears => DateFormat.yMMM(locale).format(t),
  };

  /// Heading of the card: the day, with the time for the intraday periods.
  String title(DateTime t) => series.isIntraday
      ? '${DateFormat.MMMd(locale).format(t)}, ${DateFormat.Hm(locale).format(t)}'
      : DateFormat.yMMMd(locale).format(t);
}

String assetClassLabel(BuildContext context, AssetClass c) {
  final l10n = context.l10n;
  return switch (c) {
    AssetClass.etf => l10n.allocationEtf,
    AssetClass.stock => l10n.allocationStocks,
    AssetClass.bond => l10n.allocationBonds,
    AssetClass.other => l10n.allocationOther,
  };
}

/// Short name of a position: the ticker, or the name of a manual asset.
String holdingLabel(BuildContext context, String holdingId) {
  final repo = context.repository;
  final h = repo.holding(holdingId);
  return h.isManual ? h.manualName! : repo.asset(h.assetId!).ticker;
}

String allocationLabel(BuildContext context, AllocationSlice s) {
  final l10n = context.l10n;
  return switch (s.kind) {
    AllocationKind.assetClass => assetClassLabel(context, s.assetClass!),
    AllocationKind.asset => holdingLabel(context, s.holdingId!),
    AllocationKind.other => l10n.allocationOther,
    AllocationKind.liquidity => l10n.allocationLiquidity,
  };
}

/// The title and the sentence of a message of the Investments digest.
/// Amounts are hidden with Hidden Mode; what is between "**" is bold.
({String title, String message}) investmentDigestText(
  BuildContext context,
  InvestmentDigestMessage m,
) {
  final l10n = context.l10n;
  final repo = context.repository;
  String amount(double v) => context.hideAmounts
      ? '••••'
      : SossoldiAmountFormat.money(context, v, currencyCode: repo.mainCurrency);
  String percent(double v) => SossoldiAmountFormat.percent(
    context,
    v,
    showPlusSign: false,
    decimalDigits: 0,
  );
  return switch (m.rule) {
    InvestmentDigestRule.concentration => (
      title: l10n.investmentsDigestConcentrationTitle,
      message: l10n.investmentsDigestConcentration(
        percent(m.percent!),
        holdingLabel(context, m.holdingId!),
      ),
    ),
    InvestmentDigestRule.monthDrop => (
      title: l10n.investmentsDigestDropTitle,
      message: l10n.investmentsDigestDrop(
        amount(m.amount!),
        percent(m.percent!),
      ),
    ),
    InvestmentDigestRule.monthGrowth => (
      title: l10n.investmentsDigestGrowthTitle,
      message: l10n.investmentsDigestGrowth(amount(m.amount!)),
    ),
    InvestmentDigestRule.expectedDividend => (
      title: l10n.investmentsDigestDividendTitle,
      message: m.count == 1
          ? l10n.investmentsDigestDividendOne(
              holdingLabel(context, m.holdingId!),
              amount(m.amount!),
              m.days!,
            )
          : l10n.investmentsDigestDividendMany(
              m.count!,
              amount(m.amount!),
              m.days!,
            ),
    ),
    InvestmentDigestRule.allGood => (
      title: l10n.investmentsDigestAllGoodTitle,
      message: l10n.investmentsDigestAllGood,
    ),
  };
}

SossoldiAlertTone investmentDigestTone(InvestmentDigestRule rule) =>
    switch (rule) {
      InvestmentDigestRule.concentration => SossoldiAlertTone.info,
      InvestmentDigestRule.monthDrop => SossoldiAlertTone.warning,
      InvestmentDigestRule.monthGrowth => SossoldiAlertTone.success,
      InvestmentDigestRule.expectedDividend => SossoldiAlertTone.info,
      InvestmentDigestRule.allGood => SossoldiAlertTone.info,
    };

String positionKindLabel(BuildContext context, PositionKind k) {
  final l10n = context.l10n;
  return switch (k) {
    PositionKind.etf => l10n.kindEtf,
    PositionKind.stock => l10n.kindStock,
    PositionKind.bond => l10n.kindBond,
    PositionKind.manual => l10n.kindManual,
  };
}

String manualTypeLabel(BuildContext context, ManualAssetType t) {
  final l10n = context.l10n;
  return switch (t) {
    ManualAssetType.pensionFund => l10n.manualPension,
    ManualAssetType.collectible => l10n.manualCollectible,
    ManualAssetType.art => l10n.manualArt,
    ManualAssetType.realEstate => l10n.manualRealEstate,
    ManualAssetType.other => l10n.manualOther,
  };
}

/// The tag of a position: its kind, or what kind of manual asset it is.
String positionTypeLabel(BuildContext context, Position p) =>
    p.manualType != null
    ? manualTypeLabel(context, p.manualType!)
    : positionKindLabel(context, p.kind);

/// "VWCE - IE00BK5BQT80"; empty for a manual asset.
String positionIdentifier(Position p) => [?p.ticker, ?p.isin].join(' - ');

String breakdownName(BuildContext context, BreakdownRow r) =>
    r.name ?? context.l10n.allocationOther;

String operationTypeLabel(BuildContext context, MovementType t) {
  final l10n = context.l10n;
  return switch (t) {
    MovementType.buy => l10n.operationBuy,
    MovementType.sell => l10n.operationSell,
    MovementType.dividend => l10n.operationDividend,
    MovementType.cost => '',
  };
}

/// The type of a movement, as a name ("Buy", "Dividend", "Cost").
String movementTypeLabel(BuildContext context, MovementType t) {
  final l10n = context.l10n;
  return switch (t) {
    MovementType.buy => l10n.movementTypeBuy,
    MovementType.sell => l10n.movementTypeSell,
    MovementType.dividend => l10n.movementTypeDividend,
    MovementType.cost => l10n.movementTypeCost,
  };
}

IconData movementTypeIcon(MovementType t) => switch (t) {
  MovementType.buy => PhosphorIconsRegular.arrowDownLeft,
  MovementType.sell => PhosphorIconsRegular.arrowUpRight,
  MovementType.dividend => PhosphorIconsRegular.coins,
  MovementType.cost => PhosphorIconsRegular.receipt,
};

SossoldiMovementTone movementTone(MovementType t) => switch (t) {
  MovementType.buy || MovementType.sell => SossoldiMovementTone.neutral,
  MovementType.dividend => SossoldiMovementTone.income,
  MovementType.cost => SossoldiMovementTone.expense,
};

String movementPeriodLabel(BuildContext context, MovementPeriod p) {
  final l10n = context.l10n;
  return switch (p) {
    MovementPeriod.currentMonth => l10n.movementPeriodCurrentMonth,
    MovementPeriod.last3Months => l10n.movementPeriodLast3Months,
    MovementPeriod.currentYear => l10n.movementPeriodCurrentYear,
    MovementPeriod.last12Months => l10n.movementPeriodLast12Months,
    MovementPeriod.all => l10n.movementPeriodAll,
  };
}

/// Units with the separators of the language, without useless zeros.
String unitsText(BuildContext context, double q) => NumberFormat(
  '#,##0.####',
  Localizations.localeOf(context).toString(),
).format(q);

/// "VWCE – IE00BK5BQT80" of a movement; empty without an asset.
String movementIdentifier(MovementEntry e) => [?e.ticker, ?e.isin].join(' – ');

/// Units and price of a buy or a sell, the description of the rest.
String? movementDetails(BuildContext context, MovementEntry e) {
  final m = e.movement;
  if ((m.type == MovementType.buy || m.type == MovementType.sell) &&
      m.quantity != null &&
      m.price != null) {
    return context.l10n.movementDetails(
      unitsText(context, m.quantity!),
      SossoldiAmountFormat.money(context, m.price!, currencyCode: m.currency),
    );
  }
  return m.description;
}
