import 'package:flutter/widgets.dart';

/// What the screens inside the shell can ask of it (the Dashboard widgets
/// open other sections). Absent outside the shell: use [maybeOf].
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.openInvestmentsOverview,
    required super.child,
  });

  /// Goes to the Investments section, on its Overview tab.
  final VoidCallback openInvestmentsOverview;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope old) => false;
}
