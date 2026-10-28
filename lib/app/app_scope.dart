import 'package:flutter/widgets.dart';

import '../mock/mock_repository.dart';
import 'app_state.dart';

/// Provides [AppState] to the widget tree. Widgets that read
/// [AppScopeContext.hideAmounts] rebuild when it changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this context');
    return scope!.notifier!;
  }

  /// Like [of] but without rebuilding when the state changes.
  static AppState read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<AppScope>()
        ?.widget;
    assert(scope != null, 'No AppScope above this context');
    return (scope as AppScope).notifier!;
  }
}

extension AppScopeContext on BuildContext {
  /// The data source. Data is static, so reading it does not subscribe.
  MockRepository get repository => AppScope.read(this).repository;

  /// Whether amounts must be masked. Rebuilds the caller when it changes.
  bool get hideAmounts => AppScope.of(this).hideAmounts;
}
