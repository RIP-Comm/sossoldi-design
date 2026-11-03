import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/l10n.dart';
import 'app_entry.dart';
import 'app_scope.dart';
import 'app_shell.dart';
import 'app_state.dart';
import '../features/onboarding/onboarding_flow.dart';

class SossoldiApp extends StatefulWidget {
  /// [state] lets tests supply their own data; by default the app builds its own.
  const SossoldiApp({super.key, this.state, this.entry, this.builder});

  final AppState? state;

  /// Where the shell opens (Home by default).
  final AppEntry? entry;

  /// Wraps every route (the [MaterialApp.builder]): the Inspector uses it to
  /// give the app the size and safe area of the device it shows.
  final TransitionBuilder? builder;

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
          builder: widget.builder,
          home: _Root(entry: widget.entry),
        ),
      ),
    );
  }
}

/// The app, or the onboarding on the empty data of a new user. Keyed with the
/// repository, so changing it builds everything again.
class _Root extends StatelessWidget {
  const _Root({this.entry});

  final AppEntry? entry;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final generation = state.repositoryGeneration;
    return state.onboardingActive
        ? OnboardingFlow(key: ValueKey('onboarding-$generation'))
        : AppShell(key: ValueKey('shell-$generation'), entry: entry);
  }
}
