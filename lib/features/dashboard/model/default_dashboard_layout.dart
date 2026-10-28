import '../registry/dashboard_widget_ids.dart';
import 'dashboard_layout.dart';

/// What the Dashboard shows today: a single widget, size S (as in Figma).
const defaultDashboardLayout = DashboardLayout([
  DashboardItem(
    id: 'item_1',
    widgetId: DashboardWidgetIds.monthlyBalance,
    size: DashboardWidgetSize.s,
  ),
]);
