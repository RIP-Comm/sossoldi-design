import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/l10n.dart';
import 'app_scope.dart';
import 'app_shell.dart';
import 'app_state.dart';
import '../features/onboarding/onboarding_flow.dart';

class SossoldiApp extends StatefulWidget {
  /// [state] lets tests supply their own data; by default the app builds its own.
  const SossoldiApp({super.key, this.state});

  final AppState? state;

  @override
  State<SossoldiApp> createState() => _SossoldiAppState();
}

class _SossoldiAppState extends State<SossoldiApp> {
  late final AppState _state = widget.state ?? AppState();

  @override
  void dispose() {
    if (widget.state == null) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SossoldiTheme.light,
          darkTheme: SossoldiTheme.dark,
          themeMode: _state.themeMode,
          locale: _state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _Root(),
        ),
      ),
    );
  }
}

/// The app, or the onboarding on the empty data of a new user. Keyed with the
/// repository, so changing it builds everything again.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final generation = state.repositoryGeneration;
    return state.onboardingActive
        ? OnboardingFlow(key: ValueKey('onboarding-$generation'))
        : AppShell(key: ValueKey('shell-$generation'));
  }
}
