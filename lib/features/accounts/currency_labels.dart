import 'package:flutter/widgets.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// The name of a currency in the user's language ("Euro").
String currencyName(BuildContext context, String code) {
  final l10n = context.l10n;
  return switch (code) {
    'EUR' => l10n.currencyNameEUR,
    'USD' => l10n.currencyNameUSD,
    'GBP' => l10n.currencyNameGBP,
    'CHF' => l10n.currencyNameCHF,
    'BRL' => l10n.currencyNameBRL,
    'AED' => l10n.currencyNameAED,
    'JPY' => l10n.currencyNameJPY,
    'CAD' => l10n.currencyNameCAD,
    _ => code,
  };
}

/// "Euro €", with "(default)" after it for the currency that is preselected.
String currencyLabel(
  BuildContext context,
  String code, {
  bool isDefault = false,
}) {
  final symbol = SossoldiAmountFormat.currencySymbol(context, code);
  final label = '${currencyName(context, code)} $symbol';
  return isDefault ? '$label (${context.l10n.onboardingDefault})' : label;
}
