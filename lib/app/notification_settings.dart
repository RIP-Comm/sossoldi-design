// Settings > Notifications: what the user chose. Only stored, in memory (the
// prototype sends no notification), like the budgets' "Limit reach alert".

import 'package:flutter/material.dart';

enum ReminderFrequency { daily, weekly, biweekly, monthly }

/// The reminder to add a transaction. [weekday] (1 Monday to 7 Sunday) is used
/// by weekly and biweekly, [dayOfMonth] (1-31; on shorter months the last day)
/// by monthly; daily has no day. The time is always asked.
@immutable
class TransactionReminder {
  const TransactionReminder({
    this.enabled = false,
    this.frequency = ReminderFrequency.daily,
    this.weekday = DateTime.monday,
    this.dayOfMonth = 1,
    this.time = const TimeOfDay(hour: 9, minute: 0),
  });

  final bool enabled;
  final ReminderFrequency frequency;
  final int weekday;
  final int dayOfMonth;
  final TimeOfDay time;

  bool get needsWeekday =>
      frequency == ReminderFrequency.weekly ||
      frequency == ReminderFrequency.biweekly;
  bool get needsDayOfMonth => frequency == ReminderFrequency.monthly;

  TransactionReminder copyWith({
    bool? enabled,
    ReminderFrequency? frequency,
    int? weekday,
    int? dayOfMonth,
    TimeOfDay? time,
  }) => TransactionReminder(
    enabled: enabled ?? this.enabled,
    frequency: frequency ?? this.frequency,
    weekday: weekday ?? this.weekday,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    time: time ?? this.time,
  );
}
