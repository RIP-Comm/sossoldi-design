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
    // A figure that rounds to zero is zero: no "-€0.00" (negative zero, or a
    // tiny negative number).
    final digits = decimalDigits ?? format.decimalDigits ?? 2;
    final shown = num.parse(value.toStringAsFixed(digits)) == 0 ? 0 : value;
    final text = format.format(shown);
    return showPlusSign && shown > 0 ? '+$text' : text;
  }

  /// The symbol of [currencyCode] ("€" for EUR), or the code itself when it
  /// has none.
  static String currencySymbol(BuildContext context, String currencyCode) =>
      NumberFormat.simpleCurrency(
        locale: localeOf(context),
        name: currencyCode,
      ).currencySymbol;

  /// Formats a percentage given as a fraction (0.0123 -> "1,23%" in it).
  static String percent(
    BuildContext context,
    num fraction, {
    bool showPlusSign = true,
    int decimalDigits = 2,
  }) {
    final format = NumberFormat.decimalPercentPattern(
      locale: localeOf(context),
      decimalDigits: decimalDigits,
    );
    final text = format.format(fraction);
    return showPlusSign && fraction > 0 ? '+$text' : text;
  }

  /// Formats a plain number (e.g. a quantity) with locale separators.
  static String number(BuildContext context, num value) =>
      NumberFormat.decimalPattern(localeOf(context)).format(value);

  /// Formats a quantity of units with up to [maxDecimals] decimals and no
  /// trailing zeros (12, 0,00012345).
  static String quantity(
    BuildContext context,
    num value, {
    int maxDecimals = 8,
  }) => NumberFormat(
    '#,##0.${'#' * maxDecimals}',
    localeOf(context),
  ).format(value);
}
