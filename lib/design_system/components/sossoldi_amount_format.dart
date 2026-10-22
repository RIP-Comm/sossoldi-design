// Locale-aware formatting for money and percentages, shared by every
// component that shows an amount (SossoldiAmount, SossoldiChangeTag, ...).

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

abstract final class SossoldiAmountFormat {
  /// Locale used for formatting: the app locale, English as fallback.
  static String localeOf(BuildContext context) =>
      (Localizations.maybeLocaleOf(context) ?? const Locale('en')).toString();

  /// Formats [value] in [currencyCode] (ISO 4217, e.g. "EUR").
  /// [showPlusSign] prefixes positive values with "+".
  static String money(
    BuildContext context,
    num value, {
    required String currencyCode,
    bool showPlusSign = false,
    int? decimalDigits,
  }) {
    final format = NumberFormat.simpleCurrency(
      locale: localeOf(context),
      name: currencyCode,
      decimalDigits: decimalDigits,
    );
    final text = format.format(value);
    return showPlusSign && value > 0 ? '+$text' : text;
  }

  /// Formats a percentage given as a fraction (0.0123 -> "1,23%" in it).
  static String percent(
    BuildContext context,
    num fraction, {
    bool showPlusSign = true,
  }) {
    final format = NumberFormat.decimalPercentPattern(
      locale: localeOf(context),
      decimalDigits: 2,
    );
    final text = format.format(fraction);
    return showPlusSign && fraction > 0 ? '+$text' : text;
  }

  /// Formats a plain number (e.g. a quantity) with locale separators.
  static String number(BuildContext context, num value) =>
      NumberFormat.decimalPattern(localeOf(context)).format(value);
}
