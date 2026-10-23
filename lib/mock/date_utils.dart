// Date and number helpers shared by the mock models and data generators.

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Adds [months] to [d], keeping [day] (default: the day of [d]) and
/// clamping it to the length of the target month (Jan 31 + 1 = Feb 28).
DateTime addMonths(DateTime d, int months, {int? day}) {
  final first = DateTime(d.year, d.month + months);
  final clamped = (day ?? d.day).clamp(1, daysInMonth(first.year, first.month));
  return DateTime(first.year, first.month, clamped);
}

/// First date strictly after [today] that falls on [day] of the month.
DateTime nextMonthlyOn(DateTime today, int day) {
  final thisMonth = addMonths(DateTime(today.year, today.month), 0, day: day);
  return thisMonth.isAfter(today)
      ? thisMonth
      : addMonths(thisMonth, 1, day: day);
}

/// First date strictly after [today] that falls on [weekday].
DateTime nextWeekday(DateTime today, int weekday) {
  var delta = (weekday - today.weekday) % 7;
  if (delta == 0) delta = 7;
  return today.add(Duration(days: delta));
}

bool isTradingDay(DateTime d) => d.weekday <= DateTime.friday;

double round2(double v) => (v * 100).round() / 100;
