// Month calendar of the Recurring tab, from the "Table container" of Figma
// "2.3.0 - Finance - Recurrencies" (node 13:4341): weekday header, rows of
// 48px cells, today in a circle, and 6px dots under the days that have
// transactions (red expense, green income, blue transfer).
// Adapted: weeks start on Monday, the weekday names are localized, the days
// of the neighbouring months are dimmed and cannot be tapped, and a tapped
// day can be selected (primary fill; not in Figma).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import 'sossoldi_tappable.dart';

/// What a dot under a day stands for.
enum SossoldiCalendarDot { expense, income, transfer }

class SossoldiCalendar extends StatelessWidget {
  const SossoldiCalendar({
    super.key,
    required this.month,
    required this.today,
    this.selectedDay,
    this.dots = const {},
    this.onDayTap,
  });

  /// Any day of the month shown.
  final DateTime month;
  final DateTime today;

  /// The selected day of [month]; null: none.
  final DateTime? selectedDay;

  /// The dots of each day of [month], by day of the month (1-based).
  final Map<int, Set<SossoldiCalendarDot>> dots;

  /// Called with a day of [month]; the days of other months do not react.
  final ValueChanged<DateTime>? onDayTap;

  static const double _headerHeight = 32;
  static const double _rowHeight = 48;
  static const double _cell = 40;
  static const double _dot = 6;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final locale = Localizations.localeOf(context).toString();
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1: how many days of the previous month open the first row.
    final leading = first.weekday - 1;
    final rows = ((leading + daysInMonth) / 7).ceil();
    final selected = selectedDay == null ? null : _day(selectedDay!);
    final todayDay = _day(today);
    final l10n = MaterialLocalizations.of(context);

    // A known Monday, then the next six days.
    final monday = DateTime(2024, 1, 1);
    String weekdayName(int i) {
      final name = DateFormat.E(locale)
          .format(DateTime(monday.year, monday.month, monday.day + i));
      final short = name.length > 2 ? name.substring(0, 2) : name;
      return toBeginningOfSentenceCase(short, locale) ?? short;
    }

    Widget cell(int index, bool isFirstColumn) {
      final date = DateTime(month.year, month.month, index - leading + 1);
      final inMonth = date.month == month.month;
      final isToday = date == todayDay;
      final isSelected = inMonth && selected != null && date == selected;
      final dayDots = inMonth
          ? (dots[date.day] ?? const <SossoldiCalendarDot>{})
          : const <SossoldiCalendarDot>{};
      final textColor = isSelected
          ? colors.primary.onSurface
          : inMonth
          ? colors.textHigh
          : colors.textLow;

      Color dotColor(SossoldiCalendarDot d) => isSelected
          ? colors.primary.onSurface
          : switch (d) {
              SossoldiCalendarDot.expense => colors.expense.stroke,
              SossoldiCalendarDot.income => colors.income.stroke,
              SossoldiCalendarDot.transfer => colors.info.stroke,
            };

      final inner = Container(
        width: _cell,
        height: _cell,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.surface : null,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: colors.primary.stroke)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: dayDots.isEmpty ? 0 : 4),
              child: Text(
                '${date.day}',
                style: typography.labelMedium.copyWith(color: textColor),
              ),
            ),
            if (dayDots.isNotEmpty)
              Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    for (final d in SossoldiCalendarDot.values)
                      if (dayDots.contains(d))
                        Container(
                          key: ValueKey('dot-${d.name}'),
                          width: _dot,
                          height: _dot,
                          decoration: BoxDecoration(
                            color: dotColor(d),
                            shape: BoxShape.circle,
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      );

      final body = Container(
        height: _rowHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.strokeDefault),
            left: isFirstColumn
                ? BorderSide.none
                : BorderSide(color: colors.strokeDefault),
          ),
        ),
        child: inner,
      );
      if (!inMonth || onDayTap == null) {
        return Expanded(child: ExcludeSemantics(child: body));
      }
      return Expanded(
        child: SossoldiTappable(
          onTap: () => onDayTap!(date),
          semanticLabel: l10n.formatFullDate(date),
          selected: isSelected,
          child: body,
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
          side: BorderSide(color: colors.strokeMinus1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _headerHeight,
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekdayName(i),
                        style: typography.labelSmall.copyWith(
                          color: colors.textMed,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (var r = 0; r < rows; r++)
            Row(
              children: [for (var c = 0; c < 7; c++) cell(r * 7 + c, c == 0)],
            ),
        ],
      ),
    );
  }
}
