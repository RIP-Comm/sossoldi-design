import 'package:flutter/foundation.dart';

import '../model/dashboard_layout.dart';

/// What the user picked in the add-widget sheet.
@immutable
class AddWidgetChoice {
  const AddWidgetChoice(this.widgetId, this.size);

  final String widgetId;
  final DashboardWidgetSize size;
}
