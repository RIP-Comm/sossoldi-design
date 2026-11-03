import '../registry/dashboard_widget_ids.dart';
import 'dashboard_layout.dart';

/// What the Dashboard shows at the start: Monthly balance and Upcoming
/// recurring side by side (S), then Latest transactions (L) and Monthly
/// balance again (M).
const defaultDashboardLayout = DashboardLayout([
  DashboardItem(
    id: 'item_1',
    widgetId: DashboardWidgetIds.monthlyBalance,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_2',
    widgetId: DashboardWidgetIds.upcomingRecurring,
    size: DashboardWidgetSize.s,
  ),
  DashboardItem(
    id: 'item_3',
    widgetId: DashboardWidgetIds.latestTransactions,
    size: DashboardWidgetSize.l,
  ),
  DashboardItem(
    id: 'item_4',
    widgetId: DashboardWidgetIds.monthlyBalance,
    size: DashboardWidgetSize.m,
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
