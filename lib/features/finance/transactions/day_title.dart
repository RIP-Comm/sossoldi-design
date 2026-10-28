import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// "Saturday, June 27th" in English, "Sabato 27 giugno" in Italian.
String dayTitle(BuildContext context, DateTime day) {
  final locale = Localizations.localeOf(context).toString();
  if (locale.startsWith('en')) {
    return '${DateFormat('EEEE, MMMM d', locale).format(day)}'
        '${englishOrdinal(day.day)}';
  }
  return toBeginningOfSentenceCase(
        DateFormat('EEEE d MMMM', locale).format(day),
        locale,
      ) ??
      '';
}

/// "st", "nd", "rd" or "th" for a day of the month.
String englishOrdinal(int day) {
  if (day >= 11 && day <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
