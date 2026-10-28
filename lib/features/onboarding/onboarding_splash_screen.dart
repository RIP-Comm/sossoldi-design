// Splash, from the Figma "Splash screen" (node 13:3323): the logo, the name and
// the line of the community. The logo fades in while it shrinks to its size,
// the text follows 200 ms later; after a second and a half everything fades
// out and, 100 ms after that, the welcome comes in.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'onboarding_welcome_screen.dart';
import 'sossoldi_logo.dart';

class OnboardingSplashScreen extends StatefulWidget {
  const OnboardingSplashScreen({super.key});

  /// How long the splash stays before it starts to go.
  static const duration = Duration(milliseconds: 1500);

  /// How long the elements take to fade out, and the pause before the welcome.
  static const exitDuration = Duration(milliseconds: 300);
  static const exitGap = Duration(milliseconds: 100);

  /// How long each element takes to come in, and the delay of the text.
  static const enterDuration = Duration(milliseconds: 800);
  static const textDelay = Duration(milliseconds: 200);

  /// The logo starts this much bigger than it ends.
  static const logoStartScale = 1.25;

  @override
  State<OnboardingSplashScreen> createState() => _OnboardingSplashScreenState();
}

class _OnboardingSplashScreenState extends State<OnboardingSplashScreen>
    with TickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1000);

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: _total,
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: OnboardingSplashScreen.exitDuration,
  );
  late final Animation<double> _logo = CurvedAnimation(
    parent: _enter,
    curve: Interval(
      0,
      OnboardingSplashScreen.enterDuration.inMilliseconds /
          _total.inMilliseconds,
      curve: Curves.easeOut,
    ),
  );
  late final Animation<double> _text = CurvedAnimation(
    parent: _enter,
    curve: Interval(
      OnboardingSplashScreen.textDelay.inMilliseconds / _total.inMilliseconds,
      (OnboardingSplashScreen.textDelay + OnboardingSplashScreen.enterDuration)
              .inMilliseconds /
          _total.inMilliseconds,
      curve: Curves.easeOut,
    ),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _enter.forward();
    _timer = Timer(OnboardingSplashScreen.duration, _leave);
  }

  Future<void> _leave() async {
    await _exit.forward();
    await Future<void>.delayed(OnboardingSplashScreen.exitGap);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => const OnboardingWelcomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.m),
          child: AnimatedBuilder(
            animation: Listenable.merge([_logo, _text, _exit]),
            builder: (context, _) {
              // Each element is as visible as it came in, less what has gone.
              final away = 1 - _exit.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 93,
                children: [
                  Opacity(
                    opacity: _logo.value * away,
                    child: Transform.scale(
                      scale:
                          OnboardingSplashScreen.logoStartScale -
                          (OnboardingSplashScreen.logoStartScale - 1) *
                              _logo.value,
                      // The logo is dark blue: on dark surfaces it takes the
                      // text color.
                      child: SossoldiLogo(
                        color: dark ? colors.textHigh : null,
                        backgroundColor: colors.surfaceMed,
                        semanticLabel: l10n.appName,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _text.value * away,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: SossoldiSpacing.m,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: SossoldiSpacing.xs,
                          children: [
                            Text(
                              l10n.onboardingSplashWelcome,
                              textAlign: TextAlign.center,
                              style: typography.labelMedium.copyWith(
                                color: colors.textMed,
                              ),
                            ),
                            Text(
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: typography.headlineLarge.copyWith(
                                color: colors.textHigh,
                              ),
                            ),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 243),
                          child: Text(
                            l10n.onboardingSplashTagline,
                            textAlign: TextAlign.center,
                            style: typography.bodyXLarge.copyWith(
                              color: colors.textMed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
