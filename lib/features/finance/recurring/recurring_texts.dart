import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../../mock/models/recurring_occurrence.dart';
import '../../../mock/models/recurring_transaction.dart';
import '../transactions/day_title.dart';

String recurrenceFrequencyLabel(BuildContext context, RecurrenceFrequency f) {
  final l10n = context.l10n;
  return switch (f) {
    RecurrenceFrequency.weekly => l10n.recurringFrequencyWeekly,
    RecurrenceFrequency.biweekly => l10n.recurringFrequencyBiweekly,
    RecurrenceFrequency.monthly => l10n.recurringFrequencyMonthly,
    RecurrenceFrequency.bimonthly => l10n.recurringFrequencyBimonthly,
    RecurrenceFrequency.quarterly => l10n.recurringFrequencyQuarterly,
    RecurrenceFrequency.semiannual => l10n.recurringFrequencySemiannual,
    RecurrenceFrequency.yearly => l10n.recurringFrequencyYearly,
  };
}

String recurringRangeLabel(BuildContext context, RecurringHistoryRange r) {
  final l10n = context.l10n;
  return switch (r) {
    RecurringHistoryRange.last3Months => l10n.recurringRangeLast3,
    RecurringHistoryRange.last6Months => l10n.recurringRangeLast6,
    RecurringHistoryRange.last12Months => l10n.recurringRangeLast12,
    RecurringHistoryRange.all => l10n.recurringRangeAll,
  };
}

/// The date chip of a row: "1st June" in English, "1 giugno" in Italian.
String recurrenceDateLabel(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  if (locale.startsWith('en')) {
    return '${date.day}${englishOrdinal(date.day)} '
        '${DateFormat('MMMM', locale).format(date)}';
  }
  return DateFormat('d MMMM', locale).format(date);
}
