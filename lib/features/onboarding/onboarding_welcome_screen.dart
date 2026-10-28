// Welcome, from the Figma "Onboarding 0.0.0" (node 13:3351): title, the open
// vault, the choice of language and the way to start the setup or to import
// the data of another app.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/placeholder_screen.dart';
import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'onboarding_accounts_screen.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  /// The languages of the app, each named in its own language.
  static const languages = {'en': 'English', 'it': 'Italiano'};

  /// The language of the device when the app has it, else English.
  static String deviceLanguage() {
    final supported = AppLocalizations.supportedLocales.map(
      (l) => l.languageCode,
    );
    for (final locale in WidgetsBinding.instance.platformDispatcher.locales) {
      if (supported.contains(locale.languageCode)) return locale.languageCode;
    }
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final state = AppScope.of(context);
    final device = deviceLanguage();
    final current =
        state.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SossoldiSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 80,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 40,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 46,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: SossoldiSpacing.m,
                          children: [
                            Text(
                              l10n.onboardingWelcomeTitle,
                              textAlign: TextAlign.center,
                              style: typography.headlineMedium.copyWith(
                                color: colors.textHigh,
                              ),
                            ),
                            Text(
                              l10n.onboardingWelcomeSubtitle,
                              textAlign: TextAlign.center,
                              style: typography.bodyLarge.copyWith(
                                color: colors.textMed,
                              ),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/images/open_vault.svg',
                          width: 198,
                          height: 214,
                          excludeFromSemantics: true,
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: SossoldiSelect<String>(
                        label: l10n.onboardingChooseLanguage,
                        value: current,
                        onChanged: (code) => state.setLocale(Locale(code)),
                        items: [
                          for (final entry in languages.entries)
                            SossoldiSelectItem(
                              value: entry.key,
                              label: entry.key == device
                                  ? '${entry.value} (${l10n.onboardingDefault})'
                                  : entry.value,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 11,
                  children: [
                    SossoldiButton(
                      label: l10n.onboardingStartSetup,
                      size: SossoldiButtonSize.large,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const OnboardingAccountsScreen(),
                        ),
                      ),
                    ),
                    Text(
                      l10n.onboardingOr,
                      style: typography.labelMedium.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                    SossoldiButton(
                      label: l10n.onboardingImport,
                      type: SossoldiButtonType.ghost,
                      size: SossoldiButtonSize.large,
                      iconRight: PhosphorIconsRegular.uploadSimple,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PlaceholderScreen(
                            title: l10n.onboardingImportTitle,
                            showBack: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
