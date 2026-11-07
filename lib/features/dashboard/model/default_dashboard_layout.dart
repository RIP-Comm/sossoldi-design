import '../registry/dashboard_widget_ids.dart';
import 'dashboard_layout.dart';

/// What the Dashboard shows at the start: a use case with every widget, in
/// different sizes. In the first view the Insight of the moment and Monthly
/// balance (S) with Budget status (M) under them; then Net worth (M),
/// Upcoming recurring and Allocation (S), Latest transactions (L) and
/// Investments (L), reached by scrolling.
const defaultDashboardLayout = DashboardLayout([
  DashboardItem(
    id: 'item_1',
    widgetId: DashboardWidgetIds.insight,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_2',
    widgetId: DashboardWidgetIds.monthlyBalance,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_3',
    widgetId: DashboardWidgetIds.budgetStatus,
    size: DashboardWidgetSize.m,
  ),
  DashboardItem(
    id: 'item_4',
    widgetId: DashboardWidgetIds.netWorth,
    size: DashboardWidgetSize.m,
  ),
  DashboardItem(
    id: 'item_5',
    widgetId: DashboardWidgetIds.upcomingRecurring,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_6',
    widgetId: DashboardWidgetIds.allocation,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_7',
    widgetId: DashboardWidgetIds.latestTransactions,
    size: DashboardWidgetSize.l,
  ),
  DashboardItem(
    id: 'item_8',
    widgetId: DashboardWidgetIds.investments,
    size: DashboardWidgetSize.l,
  ),
]);

/// The layout a new [DashboardController] starts from. Tests that count on a
/// single widget set it (and put [defaultDashboardLayout] back).
DashboardLayout startDashboardLayout = defaultDashboardLayout;

/// One widget, size S: what the Dashboard showed before the others were added.
const singleWidgetDashboardLayout = DashboardLayout([
  DashboardItem(
    id: 'item_1',
    widgetId: DashboardWidgetIds.monthlyBalance,
    size: DashboardWidgetSize.s,
  ),
]);
