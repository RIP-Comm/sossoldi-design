import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// `context.l10n.settings` instead of `AppLocalizations.of(context).settings`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
