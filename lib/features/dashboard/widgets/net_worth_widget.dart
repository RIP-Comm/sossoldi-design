import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/net_worth.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'dashboard_type_selector.dart';
import 'net_worth_card.dart';

/// Net worth (accounts + investments) over a period chosen with the chip;
/// the period is a setting of the placement, so it survives reordering and
/// resizing. Periods the history of the repository does not cover are in the
/// menu but disabled.
class NetWorthWidget extends StatelessWidget {
  const NetWorthWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// Key of the period in the placement's settings.
  static const periodSetting = 'period';
  static const defaultPeriod = NetWorthPeriod.yearToDate;

  static NetWorthPeriod periodOf(Map<String, String> settings) {
    for (final p in NetWorthPeriod.values) {
      if (p.name == settings[periodSetting]) return p;
    }
    return defaultPeriod;
  }

  static String periodLabel(AppLocalizations l10n, NetWorthPeriod p) =>
      switch (p) {
        NetWorthPeriod.threeMonths => l10n.netWorthPeriod3M,
        NetWorthPeriod.sixMonths => l10n.netWorthPeriod6M,
        NetWorthPeriod.yearToDate => l10n.netWorthPeriodYtd,
        NetWorthPeriod.year => l10n.netWorthPeriod1Y,
        NetWorthPeriod.threeYears => l10n.netWorthPeriod3Y,
        NetWorthPeriod.fiveYears => l10n.netWorthPeriod5Y,
        NetWorthPeriod.all => l10n.netWorthPeriodAll,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    // S has no chip: it always shows the year to date.
    final period = size == DashboardWidgetSize.s
        ? NetWorthPeriod.yearToDate
        : periodOf(instance.settings);
    final series = repo.netWorthSeries(period);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale);
    return NetWorthCard(
      size: size,
      title: l10n.widgetNetWorthName,
      smallLabel: l10n.netWorthPeriodYtd,
      value: series.current,
      currency: series.currency,
      values: [for (final p in series.points) p.value],
      pointTitles: [for (final p in series.points) date.format(p.time)],
      formatValue: (v) =>
          SossoldiAmountFormat.money(context, v, currencyCode: series.currency),
      change: series.change,
      changePercent: series.changePercent,
      masked: context.hideAmounts,
      noDataText: l10n.widgetNetWorthNoHistory,
      selector: DashboardTypeSelector(
        label: periodLabel(l10n, period),
        options: [
          for (final p in NetWorthPeriod.values)
            (key: p.name, label: periodLabel(l10n, p)),
        ],
        selected: period.name,
        disabledKeys: {
          for (final p in NetWorthPeriod.values)
            if (!repo.netWorthPeriodAvailable(p)) p.name,
        },
        semanticLabel: l10n.netWorthPeriodSemantic,
        enabled: !instance.editing && instance.onSettingChanged != null,
        onSelected: (key) =>
            instance.onSettingChanged?.call(periodSetting, key),
      ),
    );
  }
}
