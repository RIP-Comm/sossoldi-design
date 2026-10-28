import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../model/dashboard_layout.dart';

typedef DashboardWidgetBuilder = Widget Function(BuildContext context);

/// A widget the user can put on the Dashboard: what the "add widget" list
/// shows (name, icon, sizes) and how to build it for each size.
@immutable
class DashboardWidgetDefinition {
  const DashboardWidgetDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.builders,
  });

  final String id;

  /// Localized name.
  final String Function(AppLocalizations l10n) name;
  final IconData icon;

  /// One builder per implemented size.
  final Map<DashboardWidgetSize, DashboardWidgetBuilder> builders;

  Set<DashboardWidgetSize> get supportedSizes => builders.keys.toSet();

  bool supports(DashboardWidgetSize size) => builders.containsKey(size);

  /// Null when this widget has no variant for [size].
  Widget? build(BuildContext context, DashboardWidgetSize size) =>
      builders[size]?.call(context);
}
