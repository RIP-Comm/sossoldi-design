// The date fields of the Add sheet, shared by the transaction and the
// movement: three chips (Today, Yesterday, Other date) and a field that
// opens the calendar.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/date_utils.dart';

/// Opens the calendar of the design system for one day.
Future<DateTime?> pickDate(
  BuildContext context, {
  required String title,
  required DateTime lastDate,
  DateTime? firstDate,
  DateTime? selected,
}) {
  final l10n = context.l10n;
  return showSossoldiDatePicker(
    context: context,
    title: title,
    lastDate: lastDate,
    firstDate: firstDate,
    selected: selected,
    closeSemanticLabel: l10n.close,
    previousMonthSemanticLabel: l10n.previousMonth,
    nextMonthSemanticLabel: l10n.nextMonth,
  );
}

/// "Today", "Yesterday" and "Other date" (which opens the calendar and then
/// shows the day chosen). [lastDate] is the latest day that can be chosen.
class DateChipsField extends StatelessWidget {
  const DateChipsField({
    super.key,
    required this.label,
    required this.date,
    required this.today,
    required this.lastDate,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final DateTime date;
  final DateTime today;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final isToday = date == today;
    final isYesterday = date == addDays(today, -1);
    return SossoldiFieldFrame(
      label: label,
      helperText: errorText,
      isError: errorText != null,
      child: Wrap(
        spacing: SossoldiSpacing.s,
        runSpacing: SossoldiSpacing.s,
        children: [
          SossoldiUnitNavigator(
            label: l10n.txToday,
            selected: isToday,
            onTap: () => onChanged(today),
          ),
          SossoldiUnitNavigator(
            label: l10n.txYesterday,
            selected: isYesterday,
            onTap: () => onChanged(addDays(today, -1)),
          ),
          SossoldiUnitNavigator(
            label: isToday || isYesterday
                ? l10n.txOtherDate
                : DateFormat.yMMMd(locale).format(date),
            icon: PhosphorIconsRegular.calendarBlank,
            selected: !isToday && !isYesterday,
            onTap: () async {
              final picked = await pickDate(
                context,
                title: label,
                lastDate: lastDate,
                selected: date,
              );
              if (picked != null) onChanged(dateOnly(picked));
            },
          ),
        ],
      ),
    );
  }
}

/// A field showing one day that opens the calendar when tapped.
class DateButtonField extends StatelessWidget {
  const DateButtonField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.placeholder,
    this.errorText,
  });

  final String label;
  final DateTime? date;
  final String? placeholder;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final border = SossoldiFieldFrame.borderColor(
      context,
      enabled: true,
      focused: false,
      hasValue: date != null,
      isError: errorText != null,
    );
    return SossoldiFieldFrame(
      label: label,
      helperText: errorText,
      isError: errorText != null,
      child: SossoldiTappable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SossoldiSpacing.m,
            vertical: SossoldiSpacing.l,
          ),
          decoration: SossoldiFieldFrame.decoration(context, border),
          child: Row(
            spacing: SossoldiSpacing.s,
            children: [
              Expanded(
                child: Text(
                  date == null
                      ? (placeholder ?? '')
                      : DateFormat.yMMMMd(locale).format(date!),
                  style: context.typography.labelLarge.copyWith(
                    color: date == null ? colors.textMed : colors.textHigh,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.calendarBlank,
                size: 20,
                color: colors.textMed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
