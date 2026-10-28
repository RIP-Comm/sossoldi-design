import 'package:flutter/material.dart';

import '../mock/mock_repository.dart';

/// App-wide state: the data source (the demo data, or the empty one of a new
/// user going through the onboarding), the language, the "hide amounts"
/// switch (which applies to every screen, not just the Dashboard) and the
/// theme mode.
class AppState extends ChangeNotifier {
  /// [repository] is the data the app starts on (the demo data by default);
  /// [demoRepository] makes the data that "Load demo data" goes back to.
  AppState({
    MockRepository? repository,
    MockRepository Function()? demoRepository,
  }) : _repository = repository ?? MockRepository() {
    _demoFactory =
        demoRepository ?? (() => MockRepository(now: _repository.now));
    // A new main currency changes every amount: tell the screens.
    _repository.addListener(notifyListeners);
  }

  late final MockRepository Function() _demoFactory;
  MockRepository _repository;
  int _generation = 0;
  bool _onboarding = false;

  /// The data source in use.
  MockRepository get repository => _repository;

  /// Grows each time the data source is replaced: what is keyed with it is
  /// built again from scratch, with no leftover of the previous data.
  int get repositoryGeneration => _generation;

  /// Whether the onboarding is showing, on the empty data of a new user.
  bool get onboardingActive => _onboarding;

  void _use(MockRepository next, {required bool onboarding}) {
    // The old one is not disposed: the screens being replaced still hold it
    // until they are, and detach themselves then.
    _repository.removeListener(notifyListeners);
    _repository = next..addListener(notifyListeners);
    _onboarding = onboarding;
    _generation++;
    notifyListeners();
  }

  /// Opens the onboarding on an empty repository (a new user).
  void startOnboarding() =>
      _use(MockRepository.newUser(now: _repository.now), onboarding: true);

  /// Ends the onboarding: the app opens (on its first tab) on the data of
  /// the new user, which stay. The onboarding is gone from the stack, so the
  /// system back gesture cannot return to it.
  void finishOnboarding() {
    if (!_onboarding) return;
    _onboarding = false;
    _generation++;
    notifyListeners();
  }

  /// Goes back to the app on the full demo data.
  void loadDemoData() => _use(_demoFactory(), onboarding: false);

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  bool _hideAmounts = false;

  /// When true every amount is shown masked (components' `masked`).
  bool get hideAmounts => _hideAmounts;

  void toggleHideAmounts() {
    _hideAmounts = !_hideAmounts;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;

  /// Follows the device until the user picks light or dark in Settings.
  ThemeMode get themeMode => _themeMode;

  void setDarkMode(bool dark) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  Locale? _locale;

  /// The language chosen in Settings; null follows the device.
  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// The main currency (kept by the repository, which converts the data).
  String get mainCurrency => repository.mainCurrency;

  void setMainCurrency(String currency) => repository.setMainCurrency(currency);
}
