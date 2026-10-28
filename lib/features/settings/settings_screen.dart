// Settings. Only the theme switch, the language and the currency exist for
// now (to try the app); the rest of the screen is not designed yet. The
// "Prototype" rows move between the demo data and the onboarding.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Value of the language select that follows the device.
  static const _system = 'system';

  /// Closes Settings (and anything above the app) and changes the data the
  /// app runs on: the app is built again on it.
  static void _switchData(
    BuildContext context,
    void Function(AppState) change,
  ) {
    final state = AppScope.read(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    change(state);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = AppScope.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SossoldiSpacing.l),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.l,
              children: [
                Row(
                  children: [
                    SossoldiHeaderButton(
                      icon: PhosphorIconsRegular.arrowLeft,
                      semanticLabel: l10n.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.settings,
                        textAlign: TextAlign.center,
                        style: context.typography.titleMedium.copyWith(
                          color: colors.textHigh,
                        ),
                      ),
                    ),
                    // Keeps the title centered.
                    const SizedBox(width: SossoldiHeaderButton.size),
                  ],
                ),
                SossoldiList(
                  children: [
                    SossoldiMenuItem(
                      label: l10n.darkMode,
                      leading: Icon(
                        PhosphorIconsRegular.moon,
                        size: 24,
                        color: colors.textHigh,
                      ),
                      trailing: SossoldiSwitch(
                        value: isDark,
                        semanticLabel: l10n.darkMode,
                        onChanged: state.setDarkMode,
                      ),
                    ),
                  ],
                ),
                // Language and currency are here to try the app in each of them.
                SossoldiSelect<String>(
                  label: l10n.language,
                  value: state.locale?.languageCode ?? _system,
                  onChanged: (code) =>
                      state.setLocale(code == _system ? null : Locale(code)),
                  items: [
                    SossoldiSelectItem(
                      value: _system,
                      label: l10n.languageSystem,
                    ),
                    // Languages are named in their own language.
                    const SossoldiSelectItem(value: 'en', label: 'English'),
                    const SossoldiSelectItem(value: 'it', label: 'Italiano'),
                  ],
                ),
                SossoldiSelect<String>(
                  label: l10n.currency,
                  value: state.mainCurrency,
                  onChanged: state.setMainCurrency,
                  items: [
                    for (final code in state.repository.supportedCurrencies)
                      SossoldiSelectItem(
                        value: code,
                        label:
                            '$code · ${NumberFormat.simpleCurrency(locale: locale, name: code).currencySymbol}',
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: SossoldiSpacing.s,
                  children: [
                    Text(
                      l10n.settingsPrototype,
                      style: context.typography.labelMedium.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                    SossoldiList(
                      children: [
                        SossoldiMenuItem(
                          label: l10n.settingsRestartOnboarding,
                          leading: Icon(
                            PhosphorIconsRegular.arrowCounterClockwise,
                            size: 24,
                            color: colors.textHigh,
                          ),
                          onTap: () =>
                              _switchData(context, (s) => s.startOnboarding()),
                        ),
                        SossoldiMenuItem(
                          label: l10n.settingsLoadDemo,
                          leading: Icon(
                            PhosphorIconsRegular.database,
                            size: 24,
                            color: colors.textHigh,
                          ),
                          onTap: () =>
                              _switchData(context, (s) => s.loadDemoData()),
                        ),
                      ],
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
