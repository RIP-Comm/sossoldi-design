// The onboarding: splash, welcome, step 1 (main currency and accounts) and,
// for now, a placeholder where steps 2 and 3 will go. It has a Navigator of
// its own, so the system back gesture goes to the previous screen of the flow
// with what was typed still there; from the first screen it leaves the flow
// and goes back to the app on the demo data.

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import 'onboarding_splash_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _navigator = GlobalKey<NavigatorState>();

  void _back() {
    final navigator = _navigator.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    } else {
      AppScope.read(context).loadDemoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The system back always comes here (not only when the flow can still
    // go back): from the first screen it leaves the flow.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => const OnboardingSplashScreen(),
        ),
      ),
    );
  }
}
