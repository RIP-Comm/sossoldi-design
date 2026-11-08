// Settings > App settings: three blocks, no group titles. Theme, language and
// main currency work; the rest opens a screen of its own (placeholders for now).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../accounts/accounts_screen.dart';
import 'authentication_settings_screen.dart';
import '../categories/categories_screen.dart';
import '../../app/app_info.dart';
import 'community_footer.dart';
import 'import_export_settings_screen.dart';
import 'info_settings_screen.dart';
import 'notifications_settings_screen.dart';
import 'settings_page.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  /// Value of the language select that follows the device.
  static const _system = 'system';

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AppSettingsScreen());

  static Widget _row(
    BuildContext context,
    String label,
    Route<void> Function() route,
  ) => SossoldiMenuItem(
    label: label,
    hasSubitems: true,
    onTap: () => Navigator.of(context).push(route()),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = AppScope.of(context);
    final locale = Localizations.localeOf(context).toString();
    return SettingsPage(
      title: l10n.settingsAppSettings,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.l,
          children: [
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
            SossoldiSelect<String>(
              label: l10n.language,
              value: state.locale?.languageCode ?? _system,
              onChanged: (code) =>
                  state.setLocale(code == _system ? null : Locale(code)),
              items: [
                SossoldiSelectItem(value: _system, label: l10n.languageSystem),
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
            SossoldiList(
              children: [
                _row(
                  context,
                  l10n.settingsAuthentication,
                  AuthenticationSettingsScreen.route,
                ),
              ],
            ),
          ],
        ),
        SossoldiList(
          children: [
            _row(context, l10n.settingsAccounts, AccountsScreen.route),
            _row(context, l10n.settingsCategories, CategoriesScreen.route),
            _row(
              context,
              l10n.settingsImportExport,
              ImportExportSettingsScreen.route,
            ),
          ],
        ),
        SossoldiList(
          children: [
            _row(
              context,
              l10n.settingsNotifications,
              NotificationsSettingsScreen.route,
            ),
            // Opens an external form: the icon says so, not a chevron.
            SossoldiMenuItem(
              label: l10n.settingsFeedback,
              trailing: Icon(
                PhosphorIconsRegular.arrowSquareOut,
                size: 20,
                color: colors.textHigh,
              ),
              onTap: () => openExternalLink(AppInfo.feedbackForm),
            ),
            _row(context, l10n.settingsInfo, InfoSettingsScreen.route),
          ],
        ),
        const CommunityFooter(),
      ],
    );
  }
}
