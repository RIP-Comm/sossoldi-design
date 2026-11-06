import 'package:flutter/widgets.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_shell_scope.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/portfolio.dart';
import '../../investments/investments_texts.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'allocation_card.dart';

/// The allocation of the portfolio (the Investments Overview's: same data,
/// colors and donut), by asset class or by single asset. The view is chosen
/// in L with the selector and stored with the placement, so S and M follow it
/// and it survives reordering and resizing; it is independent of the
/// Investments page. A tap opens Investments > Overview.
class AllocationWidget extends StatelessWidget {
  const AllocationWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// Key of the view in the placement's settings.
  static const modeSetting = 'mode';
  static const defaultMode = AllocationMode.assetClass;

  static AllocationMode modeOf(Map<String, String> settings) {
    for (final m in AllocationMode.values) {
      if (m.name == settings[modeSetting]) return m;
    }
    return defaultMode;
  }

  /// Rows kept before "Other": S 4, M 5, L every class / six assets.
  static int? maxRows(DashboardWidgetSize size) => switch (size) {
    DashboardWidgetSize.s => 4,
    DashboardWidgetSize.m => 5,
    DashboardWidgetSize.l => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final mode = modeOf(instance.settings);
    final breakdown = repo.allocationBreakdown(mode, maxRows: maxRows(size));
    final scope = AppShellScope.maybeOf(context);
    return AllocationCard(
      size: size,
      title: l10n.widgetAllocationName,
      currency: repo.mainCurrency,
      masked: context.hideAmounts,
      hasPositions: repo.holdings.isNotEmpty && breakdown.isNotEmpty,
      emptyText: l10n.investmentsEmptyTitle,
      semanticLabel: l10n.allocationSemantics,
      rows: [
        for (final (i, r) in breakdown.indexed)
          (
            color: allocationColor(context, i, r.slice),
            label: allocationLabel(context, r.slice),
            percentText: r.percent == 0
                ? '<1%'
                : SossoldiAmountFormat.percent(
                    context,
                    r.percent / 100,
                    showPlusSign: false,
                    decimalDigits: 0,
                  ),
            value: r.slice.value,
          ),
      ],
      tabs: [l10n.allocationAssetClass, l10n.allocationSingleAsset],
      selectedTab: mode.index,
      onTabChanged: instance.editing || instance.onSettingChanged == null
          ? null
          : (i) => instance.onSettingChanged!.call(
              modeSetting,
              AllocationMode.values[i].name,
            ),
      onTap: instance.editing ? null : scope?.openInvestmentsOverview,
    );
  }
}
