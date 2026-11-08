// Where each design system component is shown in Widgetbook: the component
// class and the "Folder/Component" it has in widgetbook/lib/main.dart.
// tool/generate_widget_names.dart checks that every entry exists there and
// lists the components with no entry (they have no link in the panel).
// A component with no entry of its own points to the one that shows it.

import 'package:flutter/foundation.dart';

const widgetbookComponents = <String, String>{
  'SossoldiAccordion': 'Overlays & feedback/Accordion',
  'SossoldiAccountItem': 'Domain/Account',
  'SossoldiAlert': 'Overlays & feedback/Alert',
  'SossoldiAlertCarousel': 'Overlays & feedback/Alert carousel',
  'SossoldiAmount': 'Domain/Amount & change tag',
  'SossoldiAmountInput': 'Components/Amount input',
  'SossoldiAssetItem': 'Domain/Asset',
  'SossoldiAuthCode': 'Overlays & feedback/Auth code',
  'SossoldiAvatar': 'Domain/Avatar',
  'SossoldiBottomSheet': 'Overlays & feedback/Bottom sheet',
  'SossoldiBottomSheetToolbar': 'Overlays & feedback/Bottom sheet',
  'SossoldiBreadcrumb': 'Navigation & hints/Breadcrumb',
  'SossoldiBreakdownItem': 'Finance/Breakdown item',
  'SossoldiBudgetBar': 'Finance/Budget item + bar',
  'SossoldiBudgetItem': 'Finance/Budget item + bar',
  'SossoldiButton': 'Components/Button',
  'SossoldiCalendar': 'Finance/Calendar + month selector',
  'SossoldiCashFlowChart': 'Finance/Cash flow chart',
  'SossoldiCategoryItem': 'Domain/Category',
  'SossoldiChangeTag': 'Domain/Amount & change tag',
  'SossoldiChangeIndicator': 'Domain/Amount & change tag',
  'SossoldiChartLegend': 'Finance/Donut chart + legend',
  'SossoldiCheckbox': 'Components/Checkbox',
  'SossoldiChip': 'Components/Chip',
  'SossoldiColorPicker': 'Components/Color picker',
  'SossoldiDateRangePicker': 'Finance/Date range picker',
  'SossoldiDayHeader': 'Finance/Day header',
  'SossoldiReceipt': 'Finance/Receipt',
  'SossoldiDonutChart': 'Finance/Donut chart + legend',
  'SossoldiDropdown': 'Overlays & feedback/Menu item, List, Dropdown',
  'SossoldiEmptyState': 'Finance/Empty state',
  'SossoldiFieldFrame': 'Components/Text input',
  'SossoldiFilterButton': 'Finance/Filter button',
  'SossoldiFilterChip': 'Components/Chip-Filter',
  'SossoldiHeaderButton': 'App shell & dashboard/Header button',
  'SossoldiIconButton': 'Components/Icon button',
  'SossoldiIconPicker': 'Components/Icon picker',
  'SossoldiList': 'Overlays & feedback/Menu item, List, Dropdown',
  'SossoldiListAddButton': 'Domain/Account',
  'SossoldiLoader': 'Overlays & feedback/Loader & progress',
  'SossoldiMenuItem': 'Overlays & feedback/Menu item, List, Dropdown',
  'SossoldiModal': 'Overlays & feedback/Modal',
  'SossoldiMonthSelector': 'Finance/Calendar + month selector',
  'SossoldiMovementItem': 'Finance/Movement item',
  'SossoldiNavbar': 'App shell & dashboard/Navbar',
  'SossoldiOperationItem': 'Finance/Operation item',
  'SossoldiPageIndicator': 'App shell & dashboard/Edit controls',
  'SossoldiPagination': 'Navigation & hints/Pagination',
  'SossoldiPopover': 'Navigation & hints/Popover',
  'SossoldiPortfolioCard': 'Finance/Portfolio card',
  'SossoldiProgressCircular': 'Overlays & feedback/Loader & progress',
  'SossoldiProgressLinear': 'Overlays & feedback/Loader & progress',
  'SossoldiRadio': 'Components/Radio button',
  'SossoldiRemoveBadge': 'App shell & dashboard/Edit controls',
  'SossoldiResizeHandle': 'App shell & dashboard/Edit controls',
  'SossoldiRightChart': 'Domain/Right chart',
  'SossoldiSearchButton': 'Overlays & feedback/Search',
  'SossoldiSearchField': 'Overlays & feedback/Search',
  'SossoldiSegmentedBar': 'Finance/Segmented bar',
  'SossoldiSelect': 'Components/Select',
  'SossoldiSnackbar': 'Overlays & feedback/Snackbar',
  'SossoldiStackedAreaChart': 'Finance/Stacked area chart',
  'SossoldiSwitch': 'Components/Switch',
  'SossoldiSwitchRow': 'Components/Switch',
  'SossoldiTab': 'Components/Tabs',
  'SossoldiTabNavigation': 'Components/Tab navigation',
  'SossoldiTag': 'Components/Tag',
  'SossoldiTextInput': 'Components/Text input',
  'SossoldiTextarea': 'Components/Textarea',
  'SossoldiTooltip': 'Navigation & hints/Tooltip',
  'SossoldiTooltipTarget': 'Navigation & hints/Tooltip',
  'SossoldiTransactionItem': 'Domain/Transaction item',
  'SossoldiTrendChart': 'App shell & dashboard/Trend chart',
  'SossoldiTrendLegend': 'App shell & dashboard/Trend chart',
  'SossoldiUnitNavigator': 'Components/Unit navigator',
  'SossoldiValueChart': 'Finance/Value chart',
  'SossoldiWidgetCard': 'App shell & dashboard/Widget card',
};

/// Where Widgetbook is served, in this order:
/// 1. `--dart-define=WIDGETBOOK_URL=https://...` at build time;
/// 2. in a debug run (`flutter run`) the local Widgetbook, port 8082;
/// 3. the `widgetbook/` folder next to the Inspector.
String widgetbookBaseUrl() {
  const defined = String.fromEnvironment('WIDGETBOOK_URL');
  if (defined.isNotEmpty) return defined;
  if (kDebugMode) return 'http://localhost:8082/';
  return Uri.base.resolve('widgetbook/').toString();
}

/// The Widgetbook page of the component [widget], or null when it has none.
/// Widgetbook names a node by its names joined with "/", spaces as dashes and
/// lowercase; every component has a single use case, "All variants".
Uri? widgetbookUri(String widget) {
  final component = widgetbookComponents[widget];
  if (component == null) return null;
  final path = '$component/All variants'.replaceAll(' ', '-').toLowerCase();
  final base = widgetbookBaseUrl();
  return Uri.parse(base).replace(queryParameters: {'path': path});
}
