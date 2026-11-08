// Settings > Notifications: two notifications, each with an on/off switch.
// "Add transaction reminder" opens, when on, the frequency, the day (not for
// daily) and the time (always). Only stored, in memory: the prototype sends no
// notification. A screen of its own, opened with
// NotificationsSettingsScreen.route().

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../app/notification_settings.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'settings_page.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() => MaterialPageRoute<void>(
    builder: (_) => const NotificationsSettingsScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = AppScope.of(context);
    final reminder = state.transactionReminder;
    return SettingsPage(
      title: l10n.settingsNotifications,
      children: [
        // The options belong to the reminder: closer to it than the rows are
        // to each other.
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.s,
          children: [
            SossoldiSwitchRow(
              label: l10n.notificationsReminderTitle,
              description: l10n.notificationsReminderSubtitle,
              value: reminder.enabled,
              onChanged: (on) =>
                  state.setTransactionReminder(reminder.copyWith(enabled: on)),
            ),
            if (reminder.enabled)
              _ReminderOptions(
                reminder: reminder,
                onChanged: state.setTransactionReminder,
              ),
          ],
        ),
        SossoldiSwitchRow(
          label: l10n.notificationsRecurringTitle,
          description: l10n.notificationsRecurringSubtitle,
          value: state.recurringAddedNotice,
          onChanged: state.setRecurringAddedNotice,
        ),
      ],
    );
  }
}

class _ReminderOptions extends StatelessWidget {
  const _ReminderOptions({required this.reminder, required this.onChanged});

  final TransactionReminder reminder;
  final ValueChanged<TransactionReminder> onChanged;

  String _frequencyLabel(BuildContext context, ReminderFrequency f) {
    final l10n = context.l10n;
    return switch (f) {
      ReminderFrequency.daily => l10n.reminderDaily,
      ReminderFrequency.weekly => l10n.reminderWeekly,
      ReminderFrequency.biweekly => l10n.reminderBiweekly,
      ReminderFrequency.monthly => l10n.reminderMonthly,
    };
  }

  /// The weekday names in the language of the app, capitalized.
  String _weekdayLabel(String locale, int weekday) {
    // 1 January 2024 was a Monday.
    final name = DateFormat.EEEE(locale).format(DateTime(2024, 1, weekday));
    return name[0].toUpperCase() + name.substring(1);
  }

  Future<void> _pickTime(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showSossoldiTimePicker(
      context: context,
      title: l10n.notificationsTime,
      initial: reminder.time,
      closeSemanticLabel: l10n.close,
      confirmSemanticLabel: l10n.timePickerConfirm,
    );
    if (picked != null) onChanged(reminder.copyWith(time: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final time =
        '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiSelect<ReminderFrequency>(
          label: l10n.notificationsFrequency,
          value: reminder.frequency,
          onChanged: (f) => onChanged(reminder.copyWith(frequency: f)),
          items: [
            for (final f in ReminderFrequency.values)
              SossoldiSelectItem(value: f, label: _frequencyLabel(context, f)),
          ],
        ),
        if (reminder.needsWeekday)
          SossoldiSelect<int>(
            label: l10n.notificationsDay,
            value: reminder.weekday,
            onChanged: (d) => onChanged(reminder.copyWith(weekday: d)),
            items: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                SossoldiSelectItem(value: d, label: _weekdayLabel(locale, d)),
            ],
          ),
        if (reminder.needsDayOfMonth)
          SossoldiSelect<int>(
            label: l10n.notificationsDay,
            value: reminder.dayOfMonth,
            onChanged: (d) => onChanged(reminder.copyWith(dayOfMonth: d)),
            items: [
              for (var d = 1; d <= 31; d++)
                SossoldiSelectItem(value: d, label: '$d'),
            ],
          ),
        SossoldiFieldFrame(
          label: l10n.notificationsTime,
          child: SossoldiTappable(
            onTap: () => _pickTime(context),
            semanticLabel: l10n.notificationsTime,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SossoldiSpacing.m,
                vertical: SossoldiSpacing.l,
              ),
              decoration: SossoldiFieldFrame.decoration(
                context,
                SossoldiFieldFrame.borderColor(
                  context,
                  enabled: true,
                  focused: false,
                  hasValue: true,
                  isError: false,
                ),
              ),
              child: Row(
                spacing: SossoldiSpacing.s,
                children: [
                  Expanded(
                    child: Text(
                      time,
                      style: context.typography.labelLarge.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.clock,
                    size: 20,
                    color: colors.textMed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
