import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../model/dashboard_layout.dart';

/// What a widget needs to know about its placement: the choices stored with
/// it and how to change them. The "add widget" preview uses the defaults.
@immutable
class DashboardWidgetInstance {
  const DashboardWidgetInstance({
    this.settings = const {},
    this.editing = false,
    this.onSettingChanged,
  });

  final Map<String, String> settings;

  /// Edit mode: the controls of the widget are disabled.
  final bool editing;
  final void Function(String key, String? value)? onSettingChanged;
}

typedef DashboardWidgetBuilder = Widget Function(
  BuildContext context,
  DashboardWidgetInstance instance,
);

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
  Widget? build(
    BuildContext context,
    DashboardWidgetSize size, {
    DashboardWidgetInstance instance = const DashboardWidgetInstance(),
  }) => builders[size]?.call(context, instance);
}
